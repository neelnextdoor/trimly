import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { SignupDto } from './dto/signup.dto';
import { VerifySignupOtpDto } from './dto/verify-signup-otp.dto';
import { LoginDto } from './dto/login.dto';
import { VerifyLoginOtpDto } from './dto/verify-login-otp.dto';
import { SetMpinDto } from './dto/set-mpin.dto';
import { LoginWithMpinDto } from './dto/login-with-mpin.dto';
import { CompleteProfileDto } from './dto/complete-profile.dto';
import { UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from './jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('signup')
  @HttpCode(HttpStatus.OK)
  async signup(@Body() signupDto: SignupDto) {
    return this.authService.signup(signupDto);
  }

  @Post('signup/verify')
  @HttpCode(HttpStatus.OK)
  async verifySignupOtp(@Body() verifyDto: VerifySignupOtpDto) {
    return this.authService.verifySignupOtp(verifyDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Post('login/verify')
  @HttpCode(HttpStatus.OK)
  async verifyLoginOtp(@Body() verifyDto: VerifyLoginOtpDto) {
    return this.authService.verifyLoginOtp(verifyDto);
  }

  @Post('mpin/set')
  @HttpCode(HttpStatus.OK)
  async setMpin(@Body() setMpinDto: SetMpinDto) {
    return this.authService.setMpin(setMpinDto);
  }

  @Post('mpin/login')
  @HttpCode(HttpStatus.OK)
  async loginWithMpin(@Body() loginDto: LoginWithMpinDto) {
    return this.authService.loginWithMpin(loginDto);
  }

  @Post('signup/complete')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async completeProfile(@Request() req, @Body() completeProfileDto: CompleteProfileDto) {
    return this.authService.completeProfile(parseInt(req.user.userId), completeProfileDto);
  }
}

