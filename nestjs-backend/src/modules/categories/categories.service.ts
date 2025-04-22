import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Category } from '../../entities/category.entity';
import { CreateCategoryDto } from './dtos/create-category.dto';
import { UpdateCategoryDto } from './dtos/update-category.dto';

@Injectable()
export class CategoriesService {
  private readonly logger = new Logger(CategoriesService.name);

  constructor(
    @InjectRepository(Category)
    private readonly categoryRepository: Repository<Category>,
  ) {}

  async findAll(): Promise<Category[]> {
    this.logger.log('Fetching all categories');
    const categories = await this.categoryRepository.find();
    this.logger.log(`Found ${categories.length} categories`);
    return categories;
  }

  async findAllWithSubcategories(): Promise<Category[]> {
    this.logger.log('Fetching all categories with subcategories');
    const categories = await this.categoryRepository.find({
      relations: ['subcategories'],
      order: {
        id: 'ASC',
        subcategories: {
          id: 'ASC',
        },
      },
    });
    this.logger.log(
      `Found ${categories.length} categories with their subcategories`,
    );
    return categories;
  }

  async findOne(id: number): Promise<Category> {
    this.logger.log(`Finding category with ID: ${id}`);
    const category = await this.categoryRepository.findOne({ where: { id } });
    if (!category) {
      this.logger.warn(`Category not found with ID: ${id}`);
      throw new NotFoundException(`Category with ID ${id} not found`);
    }
    this.logger.log(`Found category with ID: ${id}`);
    return category;
  }

  async create(createCategoryDto: CreateCategoryDto): Promise<Category> {
    this.logger.log(
      `Creating new category with name: ${createCategoryDto.name}`,
    );
    const category = this.categoryRepository.create(createCategoryDto);
    const savedCategory = await this.categoryRepository.save(category);
    this.logger.log(`Created new category with ID: ${savedCategory.id}`);
    return savedCategory;
  }

  async update(
    id: number,
    updateCategoryDto: UpdateCategoryDto,
  ): Promise<Category> {
    this.logger.log(`Updating category with ID: ${id}`);
    const category = await this.findOne(id);
    Object.assign(category, updateCategoryDto);
    const updatedCategory = await this.categoryRepository.save(category);
    this.logger.log(`Successfully updated category with ID: ${id}`);
    return updatedCategory;
  }

  async remove(id: number): Promise<void> {
    this.logger.log(`Attempting to remove category with ID: ${id}`);
    const category = await this.findOne(id);
    await this.categoryRepository.remove(category);
    this.logger.log(`Successfully removed category with ID: ${id}`);
  }
}
