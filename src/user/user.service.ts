import { Injectable, NotFoundException } from '@nestjs/common';
import { UserRepository } from './user.repository';
import { UserProfileResponse } from './user.types';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UserService {
  constructor(private readonly userRepository: UserRepository) {}

  async getProfile(userId: string): Promise<UserProfileResponse> {
    const user = await this.userRepository.findById(parseInt(userId));
    
    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      id: user.id.toString(),
      email: user.email,
      phoneNumber: user.phoneNumber,
      firstName: user.firstName,
      lastName: user.lastName,
      name: user.name,
      country: user.country || undefined,
      state: user.state || undefined,
      city: user.city || undefined,
      dob: user.dob || undefined,
      picUrl: user.picUrl || undefined,
      mpinSet: user.mpinSet,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }

  async updateProfile(userId: string, updateDto: UpdateProfileDto): Promise<UserProfileResponse> {
    // Convert dob string to Date if provided
    const updateData: any = { ...updateDto };
    if (updateDto.dob) {
      updateData.dob = new Date(updateDto.dob);
    }
    
    const user = await this.userRepository.updateProfile(parseInt(userId), updateData);
    
    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      id: user.id.toString(),
      email: user.email,
      phoneNumber: user.phoneNumber,
      firstName: user.firstName,
      lastName: user.lastName,
      name: user.name,
      country: user.country || undefined,
      state: user.state || undefined,
      city: user.city || undefined,
      dob: user.dob || undefined,
      picUrl: user.picUrl || undefined,
      mpinSet: user.mpinSet,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }
}

