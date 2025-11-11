export interface SignupDto {
  email: string;
  phone: string;
  name: string;
}

export interface VerifySignupOtpDto {
  userId: string;
  otp: string;
}

export interface LoginDto {
  email?: string;
  phone?: string;
}

export interface VerifyLoginOtpDto {
  userId: string;
  otp: string;
}

export interface SetMpinDto {
  userId: string;
  mpin: string;
}

export interface LoginWithMpinDto {
  email?: string;
  phone?: string;
  mpin: string;
}

export interface AuthResponse {
  message: string;
  token?: string;
  user?: {
    id: string;
    email: string;
    name: string;
    mpinSet?: boolean;
  };
  userId?: string;
  mpinSet?: boolean;
}

export interface JwtPayload {
  userId: string;
  email: string;
}

