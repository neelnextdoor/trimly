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
   * Send OTP to user (email or SMS)
   * In production, integrate with SMS service like Twilio, AWS SNS, etc.
   */
  private async sendOTP(email: string, phone: string, otp: string): Promise<void> {
    // TODO: Integrate with actual SMS/Email service
    console.log(`OTP for ${email} (${phone}): ${otp}`);
    // For now, we'll just log it. In production, use:
    // - SMS: Twilio, AWS SNS, etc.
    // - Email: Nodemailer, SendGrid, etc.
  }

  /**
   * Save OTP to user document
   */
  private async saveOTP(userId: string, otp: string): Promise<void> {
    const otpExpiryMinutes = parseInt(this.configService.get('OTP_EXPIRY_MINUTES') || '10');
    const otpExpiry = new Date();
    otpExpiry.setMinutes(otpExpiry.getMinutes() + otpExpiryMinutes);

    await this.authRepository.updateOtp(userId, otp, otpExpiry);
  }

  /**
   * Verify OTP
   */
  private async verifyOTP(userId: string, otp: string): Promise<boolean> {
    const user = await this.authRepository.findById(userId);
    
    if (!user || !user.otp || !user.otpExpiry) {
      return false;
    }

    // Check if OTP is expired
    if (new Date() > user.otpExpiry) {
      return false;
    }

    // Check if OTP matches
    if (user.otp !== otp) {
      return false;
    }

    // Clear OTP after successful verification
    await this.authRepository.clearOtp(userId);

    return true;
  }

  /**
   * Generate JWT token
   */
  private generateToken(payload: JwtPayload): string {
    return this.jwtService.sign(payload);
  }

  /**
   * Signup - Send OTP
   */
  async signup(signupDto: SignupDto): Promise<AuthResponse> {
    const { email, phone, name } = signupDto;

    // Check if user already exists
    const existingUser = await this.authRepository.findExistingUser(email, phone);
    if (existingUser) {
      throw new BadRequestException('User already exists with this email or phone');
    }

    // Create user (not verified yet)
    const user = await this.authRepository.create({
      email,
      phone,
      name,
      isVerified: false,
    });

    // Generate and send OTP
    const otp = this.generateOTP();
    await this.saveOTP(user.id, otp);
    await this.sendOTP(email, phone, otp);

    return {
      message: 'OTP sent successfully',
      userId: user.id,
    };
  }

  /**
   * Verify OTP and complete signup
   */
  async verifySignupOtp(verifyDto: VerifySignupOtpDto): Promise<AuthResponse> {
    const { userId, otp } = verifyDto;

    const user = await this.authRepository.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Verify OTP
    const isValid = await this.verifyOTP(userId, otp);
    if (!isValid) {
      throw new BadRequestException('Invalid or expired OTP');
    }

    // Mark user as verified
    await this.authRepository.markAsVerified(userId);

    return {
      message: 'Signup verified successfully',
      userId: user.id,
      mpinSet: user.mpinSet,
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

    if (!user.isVerified) {
      throw new BadRequestException('User not verified. Please complete signup first');
    }

    // Generate and send OTP
    const otp = this.generateOTP();
    await this.saveOTP(user.id, otp);
    await this.sendOTP(user.email, user.phone, otp);

    return {
      message: 'OTP sent successfully',
      userId: user.id,
    };
  }

  /**
   * Verify OTP and generate JWT token
   */
  async verifyLoginOtp(verifyDto: VerifyLoginOtpDto): Promise<AuthResponse> {
    const { userId, otp } = verifyDto;

    const user = await this.authRepository.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Verify OTP
    const isValid = await this.verifyOTP(userId, otp);
    if (!isValid) {
      throw new BadRequestException('Invalid or expired OTP');
    }

    // Generate JWT token
    const token = this.generateToken({
      userId: user.id,
      email: user.email,
    });

    return {
      message: 'Login successful',
      token,
      user: {
        id: user.id,
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

    const user = await this.authRepository.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (!user.isVerified) {
      throw new BadRequestException('User must be verified before setting MPIN');
    }

    // Hash MPIN
    const hashedMPIN = await bcrypt.hash(mpin, 10);
    await this.authRepository.updateMpin(userId, hashedMPIN);

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

    if (!user.mpinSet || !user.mpin) {
      throw new BadRequestException('MPIN not set. Please set MPIN first');
    }

    // Verify MPIN
    const isValid = await bcrypt.compare(mpin, user.mpin);
    if (!isValid) {
      throw new UnauthorizedException('Invalid MPIN');
    }

    // Generate JWT token
    const token = this.generateToken({
      userId: user.id,
      email: user.email,
    });

    return {
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    };
  }

  /**
   * Validate JWT token and return user
   */
  async validateUser(userId: string): Promise<any> {
    const user = await this.authRepository.findById(userId);
    if (!user) {
      return null;
    }
    return {
      userId: user.id,
      email: user.email,
    };
  }
}

