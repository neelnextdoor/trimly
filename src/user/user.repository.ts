import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.model';

@Injectable()
export class UserRepository {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async findById(userId: number): Promise<User | null> {
    return this.userRepository.findOne({
      where: { id: userId },
    });
  }

  async updateProfile(userId: number, updateData: Partial<User>): Promise<User | null> {
    // If email is being updated, check if it's already taken
    if (updateData.email) {
      const existingUser = await this.userRepository.findOne({
        where: { email: updateData.email.toLowerCase() },
      });
      if (existingUser && existingUser.id !== userId) {
        throw new BadRequestException('Email already exists');
      }
      updateData.email = updateData.email.toLowerCase();
    }

    // Convert dob string to Date if provided
    if (updateData.dob && typeof updateData.dob === 'string') {
      updateData.dob = new Date(updateData.dob);
    }

    await this.userRepository.update(userId, updateData);
    const updated = await this.findById(userId);
    if (!updated) {
      return null;
    }
    return updated;
  }
}

