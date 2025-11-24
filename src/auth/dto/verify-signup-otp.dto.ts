import { IsNotEmpty, IsString, Length, Matches } from 'class-validator';

export class VerifySignupOtpDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+?[1-9]\d{1,14}$/, { message: 'phone must be a valid phone number in E.164 format' })
  phone: string;

  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/)
  otp: string;
}

