import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, length: 255 })
  email: string;

  @Column({ unique: true, length: 20 })
  phone: string;

  @Column({ length: 255 })
  name: string;

  @Column({ nullable: true, length: 6 })
  otp: string | null;

  @Column({ nullable: true, type: 'datetime' })
  otpExpiry: Date | null;

  @Column({ nullable: true, length: 255 })
  mpin: string | null;

  @Column({ default: false })
  mpinSet: boolean;

  @Column({ default: false })
  isVerified: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
