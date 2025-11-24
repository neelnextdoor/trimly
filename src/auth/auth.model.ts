import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';

@Entity('User')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'first_name', length: 255 })
  firstName: string;

  @Column({ name: 'last_name', length: 255 })
  lastName: string;

  @Column({ name: 'email', unique: true, length: 255 })
  email: string;

  @Column({ name: 'phone_number', unique: true, length: 20 })
  phoneNumber: string;

  @Column({ name: 'mpin_hash', nullable: true, length: 255 })
  mpinHash: string | null;

  @Column({ name: 'dob', nullable: true, type: 'date' })
  dob: Date | null;

  @Column({ name: 'pic_url', nullable: true, length: 500 })
  picUrl: string | null;

  @Column({ name: 'country', nullable: true, length: 100 })
  country: string | null;

  @Column({ name: 'state', nullable: true, length: 100 })
  state: string | null;

  @Column({ name: 'city', nullable: true, length: 100 })
  city: string | null;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @Column({ name: 'created_by', nullable: true })
  createdBy: number | null;

  @Column({ name: 'updated_by', nullable: true })
  updatedBy: number | null;

  @Column({ name: 'role_id', nullable: true })
  roleId: number | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Helper getter for full name (backward compatibility)
  get name(): string {
    return `${this.firstName} ${this.lastName}`.trim();
  }

  // Helper getter for phone (backward compatibility)
  get phone(): string {
    return this.phoneNumber;
  }

  // Helper getter for mpinSet (check if mpinHash exists)
  get mpinSet(): boolean {
    return !!this.mpinHash;
  }

  // Helper getter for mpin (backward compatibility)
  get mpin(): string | null {
    return this.mpinHash;
  }
}
