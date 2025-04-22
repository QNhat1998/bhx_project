import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Payment } from './payment.entity';

@Entity('payment_methods')
export class PaymentMethod {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  name: string;

  @Column({ length: 50, unique: true })
  method_key: string;

  @Column({ length: 255, nullable: true })
  logo: string;

  @Column('text', { nullable: true })
  description: string;

  @Column({ type: 'tinyint', default: 1 })
  active: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @OneToMany(() => Payment, (payment) => payment.payment_method)
  payments: Payment[];
}
