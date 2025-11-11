import { IsNotEmpty, IsString, Length, Matches } from 'class-validator';

export class SetMpinDto {
  @IsString()
  @IsNotEmpty()
  userId: string;

  @IsString()
  @Length(4, 4)
  @Matches(/^\d{4}$/)
  mpin: string;
}

