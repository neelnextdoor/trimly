import { IsNotEmpty, IsString, Matches } from 'class-validator';

export class SignupDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+?[1-9]\d{1,14}$/, { message: 'phone must be a valid phone number in E.164 format' })
  phone: string;
}

