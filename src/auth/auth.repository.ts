import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './auth.model';
import { OTP } from './otp.model';

@Injectable()
export class AuthRepository {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(OTP)
    private otpRepository: Repository<OTP>,
  ) {}

  async create(userData: Partial<User>): Promise<User> {
    const user = this.userRepository.create(userData);
    return this.userRepository.save(user);
  }

  async findById(userId: number): Promise<User | null> {
    return this.userRepository.findOne({ where: { id: userId } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { email: email.toLowerCase() },
    });
  }

  async findByPhone(phoneNumber: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { phoneNumber } });
  }

  async findByEmailOrPhone(email?: string, phoneNumber?: string): Promise<User | null> {
    if (email) {
      return this.userRepository.findOne({
        where: { email: email.toLowerCase() },
      });
    }
    if (phoneNumber) {
      return this.userRepository.findOne({ where: { phoneNumber } });
    }
    return null;
  }

  async findExistingUser(email: string, phoneNumber: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: [
        { email: email.toLowerCase() },
        { phoneNumber },
      ],
    });
  }

  async createOtp(phoneNumber: string, otpCode: string, expiryAt: Date, meta?: any): Promise<OTP> {
    const otp = this.otpRepository.create({
      phoneNumber,
      otpCode,
      expiryAt,
      meta: meta || {},
    });
    return this.otpRepository.save(otp);
  }

  async findActiveOtp(phoneNumber: string, otpCode: string): Promise<OTP | null> {
    return this.otpRepository.findOne({
      where: {
        phoneNumber,
        otpCode,
        consumedAt: null,
      },
      order: { expiryAt: 'DESC' },
    });
  }

  async consumeOtp(otpId: number): Promise<void> {
    await this.otpRepository.update(otpId, {
      consumedAt: new Date(),
    });
  }

  async updateMpin(userId: number, hashedMpin: string): Promise<void> {
    await this.userRepository.update(userId, {
      mpinHash: hashedMpin,
    });
  }

  async updateProfile(userId: number, profileData: Partial<User>): Promise<void> {
    await this.userRepository.update(userId, profileData);
  }
}
