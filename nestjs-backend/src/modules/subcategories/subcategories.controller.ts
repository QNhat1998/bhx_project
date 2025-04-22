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
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SubcategoriesService } from './subcategories.service';
import { ProductsService } from '../products/products.service';
import { CreateSubcategoryDto } from './dtos/create-subcategory.dto';
import { UpdateSubcategoryDto } from './dtos/update-subcategory.dto';
import { Subcategory } from '../../entities/subcategory.entity';
import { Product } from '../../entities/product.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Public } from '../auth/decorators/public.decorator';

@Controller('subcategories')
export class SubcategoriesController {
  constructor(
    private readonly subcategoriesService: SubcategoriesService,
    private readonly productsService: ProductsService,
    @InjectRepository(Subcategory)
    private readonly subcategoryRepository: Repository<Subcategory>,
  ) {}

  @Public()
  @Get()
  findAll(): Promise<Subcategory[]> {
    return this.subcategoryRepository.find({
      relations: ['category'],
    });
  }

  @Public()
  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number): Promise<Subcategory> {
    const subcategory = await this.subcategoryRepository.findOne({
      where: { id },
      relations: ['category'],
    });
    if (!subcategory) {
      throw new NotFoundException(`Subcategory with ID ${id} not found`);
    }
    return subcategory;
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Post()
  @Roles('super_admin', 'admin')
  create(
    @Body() createSubcategoryDto: CreateSubcategoryDto,
  ): Promise<Subcategory> {
    return this.subcategoriesService.create(
      createSubcategoryDto.category_id,
      createSubcategoryDto,
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Put(':id')
  @Roles('super_admin', 'admin')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateSubcategoryDto: UpdateSubcategoryDto,
  ): Promise<Subcategory> {
    const subcategory = await this.subcategoryRepository.findOne({
      where: { id },
      relations: ['category'],
    });
    if (!subcategory) {
      throw new NotFoundException(`Subcategory with ID ${id} not found`);
    }
    return this.subcategoriesService.update(
      subcategory.category.id,
      id,
      updateSubcategoryDto,
    );
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Delete(':id')
  @Roles('super_admin')
  async remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    const subcategory = await this.subcategoryRepository.findOne({
      where: { id },
      relations: ['category'],
    });
    if (!subcategory) {
      throw new NotFoundException(`Subcategory with ID ${id} not found`);
    }
    return this.subcategoriesService.remove(subcategory.category.id, id);
  }

  @Public()
  @Get(':id/products')
  async findAllProducts(
    @Param('id', ParseIntPipe) id: number,
  ): Promise<Product[]> {
    const subcategory = await this.subcategoryRepository.findOne({
      where: { id },
      relations: ['category'],
    });
    if (!subcategory) {
      throw new NotFoundException(`Subcategory with ID ${id} not found`);
    }
    return this.productsService.findAllBySubcategory(
      subcategory.category.id,
      id,
    );
  }
}
