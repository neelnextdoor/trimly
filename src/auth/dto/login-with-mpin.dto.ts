import { IsEmail, IsMobilePhone, IsNotEmpty, IsString, Length, Matches, ValidateIf } from 'class-validator';

export class LoginWithMpinDto {
  @ValidateIf((o) => !o.phone)
  @IsEmail()
  email?: string;

  @ValidateIf((o) => !o.email)
  @IsMobilePhone()
  phone?: string;

  @IsString()
  @IsNotEmpty()
  @Length(4, 4)
  @Matches(/^\d{4}$/)
  mpin: string;
}

