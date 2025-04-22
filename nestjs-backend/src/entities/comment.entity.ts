import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { Product } from './product.entity';

@Entity('comments')
export class Comment {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  product_id: number;

  @Column({ nullable: true, length: 100 })
  customer_name: string;

  @Column('text')
  content: string;

  @Column('decimal', { precision: 2, scale: 1, nullable: true })
  rating: number;

  @CreateDateColumn()
  created_at: Date;

  @Column({ type: 'tinyint', default: 1 })
  status: number;

  @ManyToOne(() => Product, (product) => product.comments)
  @JoinColumn({ name: 'product_id' })
  product: Product;
}
