import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Order } from './order.entity';
import { PaymentMethod } from './payment-method.entity';

@Entity('payments')
export class Payment {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  order_id: number;

  @Column()
  payment_method_id: number;

  @Column({ nullable: true })
  transaction_id: string;

  @Column('decimal', { precision: 14, scale: 2 })
  amount: number;

  @Column({
    type: 'enum',
    enum: ['pending', 'paid', 'failed', 'cancelled'],
    default: 'pending',
  })
  status: string;

  @Column({ type: 'datetime', nullable: true })
  paid_at: Date;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @ManyToOne(() => Order, (order) => order.payments)
  @JoinColumn({ name: 'order_id' })
  order: Order;

  @ManyToOne(() => PaymentMethod, (method) => method.payments)
  @JoinColumn({ name: 'payment_method_id' })
  payment_method: PaymentMethod;
}
