import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import { CategoriesService } from './categories.service';
import { SubcategoriesService } from '../subcategories/subcategories.service';
import { ProductsService } from '../products/products.service';
import { CreateCategoryDto } from './dtos/create-category.dto';
import { UpdateCategoryDto } from './dtos/update-category.dto';
import { CreateSubcategoryDto } from '../subcategories/dtos/create-subcategory.dto';
import { UpdateSubcategoryDto } from '../subcategories/dtos/update-subcategory.dto';
import { Category } from '../../entities/category.entity';
import { Subcategory } from '../../entities/subcategory.entity';
import { Product } from '../../entities/product.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Public } from '../auth/decorators/public.decorator';

@Controller('categories')
export class CategoriesController {
  constructor(
    private readonly categoriesService: CategoriesService,
    private readonly subcategoriesService: SubcategoriesService,
    private readonly productsService: ProductsService,
  ) {}

  @Public()
  @Get()
  findAll(): Promise<Category[]> {
    return this.categoriesService.findAll();
  }

  @Public()
  @Get('subcategories')
  findAllWithSubcategories(): Promise<Category[]> {
    return this.categoriesService.findAllWithSubcategories();
  }

  @Public()
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number): Promise<Category> {
    return this.categoriesService.findOne(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Post()
  @Roles('super_admin', 'admin')
  create(@Body() createCategoryDto: CreateCategoryDto): Promise<Category> {
    return this.categoriesService.create(createCategoryDto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Put(':id')
  @Roles('super_admin', 'admin')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateCategoryDto: UpdateCategoryDto,
  ): Promise<Category> {
    return this.categoriesService.update(id, updateCategoryDto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Delete(':id')
  @Roles('super_admin')
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.categoriesService.remove(id);
  }

  // Subcategory routes
  @Public()
  @Get(':categoryId/subcategories')
  findAllSubcategories(
    @Param('categoryId', ParseIntPipe) categoryId: number,
  ): Promise<Subcategory[]> {
    return this.subcategoriesService.findAllByCategory(categoryId);
  }

  @Public()
  @Get(':categoryId/subcategories/:id')
  findOneSubcategory(
    @Param('categoryId', ParseIntPipe) categoryId: number,
    @Param('id', ParseIntPipe) id: number,
  ): Promise<Subcategory> {
    return this.subcategoriesService.findOne(categoryId, id);
  }

  // Product routes
  @Public()
  @Get(':categoryId/products')
  findAllProducts(
    @Param('categoryId', ParseIntPipe) categoryId: number,
  ): Promise<Product[]> {
    return this.productsService.findAllByCategory(categoryId);
  }
}
