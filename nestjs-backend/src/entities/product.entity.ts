// src/products/entities/product.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { Category } from './category.entity'; // Import Category entity
import { Subcategory } from './subcategory.entity'; // Import Subcategory entity
import { Comment } from './comment.entity';
import { OrderDetail } from './order-detail.entity';
import { ProductSale } from './product-sale.entity';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 255 })
  product_name: string;

  @Column({ type: 'varchar', length: 255 })
  price: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  img: string;

  @Column({ type: 'varchar', length: 255, unique: true })
  url: string;

  @Column({ type: 'int', default: 0 })
  stock: number;

  @Column({ type: 'decimal', precision: 2, scale: 1, default: 0 })
  rating: number;

  @Column({ type: 'boolean', default: true })
  status: boolean;

  @Column()
  category_id: number;

  @Column()
  subcategory_id: number;

  // Relationship with Category
  @ManyToOne(() => Category, (category) => category.products)
  @JoinColumn({ name: 'category_id' })
  category: Category;

  // Relationship with Subcategory
  @ManyToOne(() => Subcategory, (subcategory) => subcategory.products)
  @JoinColumn({ name: 'subcategory_id' })
  subcategory: Subcategory;

  @OneToMany(() => Comment, (comment) => comment.product)
  comments: Comment[];

  @OneToMany(() => OrderDetail, (orderDetail) => orderDetail.product)
  order_details: OrderDetail[];

  @OneToMany(() => ProductSale, (sale) => sale.product)
  sales: ProductSale[];
}
