import { IsNotEmpty, IsString, Length, Matches } from 'class-validator';

export class VerifySignupOtpDto {
  @IsString()
  @IsNotEmpty()
  userId: string;

  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/)
  otp: string;
}

