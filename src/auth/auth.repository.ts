import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './auth.model';

@Injectable()
export class AuthRepository {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async create(userData: Partial<User>): Promise<User> {
    const user = this.userRepository.create(userData);
    return this.userRepository.save(user);
  }

  async findById(userId: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id: userId } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { email: email.toLowerCase() },
    });
  }

  async findByPhone(phone: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { phone } });
  }

  async findByEmailOrPhone(email?: string, phone?: string): Promise<User | null> {
    if (email) {
      return this.userRepository.findOne({
        where: { email: email.toLowerCase() },
      });
    }
    if (phone) {
      return this.userRepository.findOne({ where: { phone } });
    }
    return null;
  }

  async findExistingUser(email: string, phone: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: [
        { email: email.toLowerCase() },
        { phone },
      ],
    });
  }

  async updateOtp(userId: string, otp: string, otpExpiry: Date): Promise<void> {
    await this.userRepository.update(userId, {
      otp,
      otpExpiry,
    });
  }

  async clearOtp(userId: string): Promise<void> {
    await this.userRepository.update(userId, {
      otp: null,
      otpExpiry: null,
    });
  }

  async updateMpin(userId: string, hashedMpin: string): Promise<void> {
    await this.userRepository.update(userId, {
      mpin: hashedMpin,
      mpinSet: true,
    });
  }

  async markAsVerified(userId: string): Promise<void> {
    await this.userRepository.update(userId, {
      isVerified: true,
    });
  }
}
