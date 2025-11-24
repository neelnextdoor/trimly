export interface UserProfileResponse {
  id: string;
  email: string;
  phoneNumber: string;
  firstName: string;
  lastName: string;
  name: string; // Full name for backward compatibility
  country?: string;
  state?: string;
  city?: string;
  dob?: Date;
  picUrl?: string;
  mpinSet: boolean;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

