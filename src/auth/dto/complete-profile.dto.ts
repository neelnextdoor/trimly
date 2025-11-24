import { IsString, IsNotEmpty, IsOptional, IsEmail, IsDateString, IsUrl } from 'class-validator';

export class CompleteProfileDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  firstName: string;

  @IsString()
  @IsNotEmpty()
  lastName: string;

  @IsString()
  @IsOptional()
  country?: string;

  @IsString()
  @IsOptional()
  state?: string;

  @IsString()
  @IsOptional()
  city?: string;

  @IsDateString()
  @IsOptional()
  dob?: string;

  @IsUrl()
  @IsOptional()
  picUrl?: string;
}

