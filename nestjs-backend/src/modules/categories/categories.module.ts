import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CategoriesController } from './categories.controller';
import { CategoriesService } from './categories.service';
import { SubcategoriesService } from '../subcategories/subcategories.service';
import { ProductsService } from '../products/products.service';
import { Category } from '../../entities/category.entity';
import { Subcategory } from '../../entities/subcategory.entity';
import { Product } from '../../entities/product.entity';
import { Role } from 'src/entities/role.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Category, Subcategory, Product, Role])],
  controllers: [CategoriesController],
  providers: [CategoriesService, SubcategoriesService, ProductsService],
  exports: [CategoriesService],
})
export class CategoriesModule {}
