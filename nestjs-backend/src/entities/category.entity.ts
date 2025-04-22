import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from 'typeorm';
import { Subcategory } from './subcategory.entity';
import { Product } from './product.entity';

@Entity('categories')
export class Category {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  name: string;

  @OneToMany(() => Subcategory, (subcategory) => subcategory.category)
  subcategories: Subcategory[];

  @OneToMany(() => Product, (product) => product.category)
  products: Product[];
}
