export interface UserProfileResponse {
  id: string;
  email: string;
  phone: string;
  name: string;
  mpinSet: boolean;
  isVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface UpdateProfileDto {
  name?: string;
}

