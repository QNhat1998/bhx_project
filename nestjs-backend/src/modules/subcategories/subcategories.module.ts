import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SubcategoriesController } from './subcategories.controller';
import { SubcategoriesService } from './subcategories.service';
import { ProductsService } from '../products/products.service';
import { Category } from '../../entities/category.entity';
import { Subcategory } from '../../entities/subcategory.entity';
import { Product } from '../../entities/product.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Category, Subcategory, Product])],
  controllers: [SubcategoriesController],
  providers: [SubcategoriesService, ProductsService],
  exports: [SubcategoriesService],
})
export class SubcategoriesModule {}
