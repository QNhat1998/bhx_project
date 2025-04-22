import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { Category } from './category.entity';
import { Product } from './product.entity';

@Entity('subcategories')
export class Subcategory {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Category, (category) => category.subcategories)
  @JoinColumn({ name: 'category_id' })
  category: Category;

  @Column({ length: 100 })
  name: string;

  @Column({ length: 100, nullable: true })
  img: string;

  @Column({ length: 100, nullable: true })
  url: string;

  @OneToMany(() => Product, (product) => product.subcategory)
  products: Product[];
}
