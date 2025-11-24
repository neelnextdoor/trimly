import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  Index,
} from 'typeorm';

@Entity('OTP')
@Index(['phoneNumber', 'expiryAt'])
export class OTP {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'phone_number', length: 20 })
  phoneNumber: string;

  @Column({ name: 'otp_code', length: 10 })
  otpCode: string;

  @Column({ name: 'expiry_at', type: 'datetime' })
  expiryAt: Date;

  @Column({ name: 'consumed_at', nullable: true, type: 'datetime' })
  consumedAt: Date | null;

  @Column({ name: 'meta', type: 'json', nullable: true })
  meta: any;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

