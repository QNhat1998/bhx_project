import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Product } from './product.entity';

export enum ProductSaleStatus {
  ACTIVE = 'active',
  SCHEDULED = 'scheduled',
  EXPIRED = 'expired',
}

@Entity('product_sales')
export class ProductSale {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  product_id: number;

  @Column('decimal', { precision: 14, scale: 2 })
  sale_price: number;

  @Column('decimal', { precision: 14, scale: 2, nullable: true })
  original_price: number;

  @Column('tinyint', { unsigned: true, nullable: true })
  discount_pct: number;

  @Column()
  start_date: Date;

  @Column()
  end_date: Date;

  @Column({
    type: 'enum',
    enum: ProductSaleStatus,
    default: ProductSaleStatus.SCHEDULED,
  })
  status: ProductSaleStatus;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @ManyToOne(() => Product, (product) => product.sales, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'product_id' })
  product: Product;
}
