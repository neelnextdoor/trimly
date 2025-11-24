import { Injectable, BadRequestException, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { AuthRepository } from './auth.repository';
import { SignupDto } from './dto/signup.dto';
import { VerifySignupOtpDto } from './dto/verify-signup-otp.dto';
import { LoginDto } from './dto/login.dto';
import { VerifyLoginOtpDto } from './dto/verify-login-otp.dto';
import { SetMpinDto } from './dto/set-mpin.dto';
import { LoginWithMpinDto } from './dto/login-with-mpin.dto';
import { CompleteProfileDto } from './dto/complete-profile.dto';
import { AuthResponse, JwtPayload } from './auth.types';

@Injectable()
export class AuthService {
  constructor(
    private readonly authRepository: AuthRepository,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * Generate a 6-digit OTP
   */
  private generateOTP(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  /**
   * Send OTP to user (SMS)
   * In production, integrate with SMS service like Twilio, AWS SNS, etc.
   */
  private async sendOTP(phone: string, otp: string): Promise<void> {
    // TODO: Integrate with actual SMS service
    console.log(`OTP for ${phone}: ${otp}`);
    // For now, we'll just log it. In production, use:
    // - SMS: Twilio, AWS SNS, etc.
  }

  /**
   * Save OTP to OTP table
   */
  private async saveOTP(phoneNumber: string, otp: string): Promise<void> {
    const otpExpiryMinutes = parseInt(this.configService.get('OTP_EXPIRY_MINUTES') || '10');
    const otpExpiry = new Date();
    otpExpiry.setMinutes(otpExpiry.getMinutes() + otpExpiryMinutes);

    await this.authRepository.createOtp(phoneNumber, otp, otpExpiry);
  }

  /**
   * Verify OTP from OTP table
   */
  private async verifyOTP(phoneNumber: string, otp: string): Promise<boolean> {
    const otpRecord = await this.authRepository.findActiveOtp(phoneNumber, otp);
    
    if (!otpRecord) {
      return false;
    }

    // Check if OTP is expired
    if (new Date() > otpRecord.expiryAt) {
      return false;
    }

    // Mark OTP as consumed
    await this.authRepository.consumeOtp(otpRecord.id);

    return true;
  }

  /**
   * Generate JWT token
   */
  private generateToken(payload: JwtPayload): string {
    return this.jwtService.sign(payload);
  }

  /**
   * Signup - Send OTP (only phone number required)
   */
  async signup(signupDto: SignupDto): Promise<AuthResponse> {
    const { phone } = signupDto;

    // Check if user already exists with this phone
    const existingUser = await this.authRepository.findByPhone(phone);
    if (existingUser) {
      throw new BadRequestException('User already exists with this phone number');
    }

    // Generate and send OTP
    const otp = this.generateOTP();
    await this.saveOTP(phone, otp);
    await this.sendOTP(phone, otp);

    return {
      message: 'OTP sent successfully to your phone number',
    };
  }

  /**
   * Verify OTP and create user account
   */
  async verifySignupOtp(verifyDto: VerifySignupOtpDto): Promise<AuthResponse> {
    const { phone, otp } = verifyDto;

    // Verify OTP
    const isValid = await this.verifyOTP(phone, otp);
    if (!isValid) {
      throw new BadRequestException('Invalid or expired OTP');
    }

    // Check if user already exists
    const existingUser = await this.authRepository.findByPhone(phone);
    if (existingUser) {
      throw new BadRequestException('User already exists with this phone number');
    }

    // Create user account with minimal data (phone number only)
    // User will complete profile in next step
    // Using temporary placeholder values for required fields
    const tempEmail = `temp_${phone.replace(/\D/g, '')}@temp.barber`;
    const user = await this.authRepository.create({
      phoneNumber: phone,
      firstName: 'Temp', // Will be updated in complete profile
      lastName: 'User', // Will be updated in complete profile
      email: tempEmail, // Will be updated in complete profile
      isActive: true,
    });

    // Generate JWT token for profile completion
    const token = this.generateToken({
      userId: user.id.toString(),
      email: '',
    });

    return {
      message: 'Account created successfully. Please complete your profile.',
      token,
      userId: user.id.toString(),
    };
  }

  /**
   * Complete user profile after signup
   */
  async completeProfile(userId: number, profileDto: CompleteProfileDto): Promise<AuthResponse> {
    const user = await this.authRepository.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check if email is already taken by another user
    if (profileDto.email) {
      const existingUserWithEmail = await this.authRepository.findByEmail(profileDto.email);
      if (existingUserWithEmail && existingUserWithEmail.id !== userId) {
        throw new BadRequestException('Email already exists');
      }
    }

    // Update user profile
    await this.authRepository.updateProfile(userId, {
      email: profileDto.email.toLowerCase(),
      firstName: profileDto.firstName,
      lastName: profileDto.lastName,
      country: profileDto.country || null,
      state: profileDto.state || null,
      city: profileDto.city || null,
      dob: profileDto.dob ? new Date(profileDto.dob) : null,
      picUrl: profileDto.picUrl || null,
    });

    const updatedUser = await this.authRepository.findById(userId);

    return {
      message: 'Profile completed successfully',
      user: {
        id: updatedUser!.id.toString(),
        email: updatedUser!.email,
        name: updatedUser!.name,
      },
    };
  }

  /**
   * Login - Send OTP
   */
  async login(loginDto: LoginDto): Promise<AuthResponse> {
    const { email, phone } = loginDto;

    if (!email && !phone) {
      throw new BadRequestException('Email or phone is required');
    }

    // Find user
    const user = await this.authRepository.findByEmailOrPhone(email, phone);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (!user.isActive) {
      throw new BadRequestException('User account is not active');
    }

    // Generate and send OTP
    const otp = this.generateOTP();
    await this.saveOTP(user.phoneNumber, otp);
    await this.sendOTP(user.phoneNumber, otp);

    return {
      message: 'OTP sent successfully',
      userId: user.id.toString(),
    };
  }

  /**
   * Verify OTP and generate JWT token
   */
  async verifyLoginOtp(verifyDto: VerifyLoginOtpDto): Promise<AuthResponse> {
    const { userId, otp } = verifyDto;

    const user = await this.authRepository.findById(parseInt(userId));
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Verify OTP
    const isValid = await this.verifyOTP(user.phoneNumber, otp);
    if (!isValid) {
      throw new BadRequestException('Invalid or expired OTP');
    }

    // Generate JWT token
    const token = this.generateToken({
      userId: user.id.toString(),
      email: user.email,
    });

    return {
      message: 'Login successful',
      token,
      user: {
        id: user.id.toString(),
        email: user.email,
        name: user.name,
        mpinSet: user.mpinSet,
      },
    };
  }

  /**
   * Set MPIN (after signup)
   */
  async setMpin(setMpinDto: SetMpinDto): Promise<AuthResponse> {
    const { userId, mpin } = setMpinDto;

    if (mpin.length !== 4 || !/^\d{4}$/.test(mpin)) {
      throw new BadRequestException('MPIN must be a 4-digit number');
    }

    const user = await this.authRepository.findById(parseInt(userId));
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (!user.isActive) {
      throw new BadRequestException('User account is not active');
    }

    // Hash MPIN
    const hashedMPIN = await bcrypt.hash(mpin, 10);
    await this.authRepository.updateMpin(user.id, hashedMPIN);

    return {
      message: 'MPIN set successfully',
    };
  }

  /**
   * Login with MPIN
   */
  async loginWithMpin(loginDto: LoginWithMpinDto): Promise<AuthResponse> {
    const { email, phone, mpin } = loginDto;

    if ((!email && !phone) || !mpin) {
      throw new BadRequestException('Email/phone and MPIN are required');
    }

    // Find user
    const user = await this.authRepository.findByEmailOrPhone(email, phone);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (!user.mpinSet || !user.mpinHash) {
      throw new BadRequestException('MPIN not set. Please set MPIN first');
    }

    // Verify MPIN
    const isValid = await bcrypt.compare(mpin, user.mpinHash);
    if (!isValid) {
      throw new UnauthorizedException('Invalid MPIN');
    }

    // Generate JWT token
    const token = this.generateToken({
      userId: user.id.toString(),
      email: user.email,
    });

    return {
      message: 'Login successful',
      token,
      user: {
        id: user.id.toString(),
        email: user.email,
        name: user.name,
      },
    };
  }

  /**
   * Validate JWT token and return user
   */
  async validateUser(userId: string): Promise<any> {
    const user = await this.authRepository.findById(parseInt(userId));
    if (!user) {
      return null;
    }
    return {
      userId: user.id.toString(),
      email: user.email,
    };
  }
}

