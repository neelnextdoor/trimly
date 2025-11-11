import { IsNotEmpty, IsString, Length, Matches } from 'class-validator';

export class VerifyLoginOtpDto {
  @IsString()
  @IsNotEmpty()
  userId: string;

  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/)
  otp: string;
}

