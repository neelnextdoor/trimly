import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.model';

@Injectable()
export class UserRepository {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async findById(userId: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { id: userId },
      select: ['id', 'email', 'phone', 'name', 'mpinSet', 'isVerified', 'createdAt', 'updatedAt'],
    });
  }

  async updateProfile(userId: string, updateData: { name?: string }): Promise<User | null> {
    await this.userRepository.update(userId, updateData);
    const updated = await this.findById(userId);
    if (!updated) {
      return null;
    }
    return updated;
  }
}
