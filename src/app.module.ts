import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { User } from './auth/auth.model';
import { OTP } from './auth/otp.model';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => {
        const password = configService.get<string>('DB_PASS');
        // If password is explicitly set to empty string or undefined, use empty string
        // Otherwise use the provided password
        const dbPassword = password === undefined || password === null ? '' : password;
        
        return {
          type: 'mysql',
          host: configService.get<string>('DB_HOST') || configService.get<string>('HOST') || 'localhost',
          port: parseInt(configService.get<string>('DB_PORT') || '3306', 10),
          username: configService.get<string>('DB_USER') || 'root',
          password: dbPassword,
          database: configService.get<string>('DB_NAME') || 'barber',
          entities: [User, OTP],
          synchronize: configService.get<string>('NODE_ENV') !== 'production', // Auto-sync schema in dev
          logging: configService.get<string>('NODE_ENV') === 'development',
        };
      },
      inject: [ConfigService],
    }),
    AuthModule,
    UserModule,
  ],
})
export class AppModule {}
