import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Subcategory } from '../../entities/subcategory.entity';
import { Category } from '../../entities/category.entity';
import { CreateSubcategoryDto } from './dtos/create-subcategory.dto';
import { UpdateSubcategoryDto } from './dtos/update-subcategory.dto';

@Injectable()
export class SubcategoriesService {
  private readonly logger = new Logger(SubcategoriesService.name);

  constructor(
    @InjectRepository(Subcategory)
    private readonly subcategoryRepository: Repository<Subcategory>,
    @InjectRepository(Category)
    private readonly categoryRepository: Repository<Category>,
  ) {}

  async findAllByCategory(categoryId: number): Promise<Subcategory[]> {
    this.logger.log(
      `Fetching all subcategories for category ID: ${categoryId}`,
    );
    const subcategories = await this.subcategoryRepository.find({
      where: { category: { id: categoryId } },
    });
    this.logger.log(
      `Found ${subcategories.length} subcategories for category ID: ${categoryId}`,
    );
    return subcategories;
  }

  async findOne(categoryId: number, id: number): Promise<Subcategory> {
    this.logger.log(
      `Finding subcategory with ID: ${id} in category ID: ${categoryId}`,
    );
    const subcategory = await this.subcategoryRepository.findOne({
      where: { id, category: { id: categoryId } },
    });
    if (!subcategory) {
      this.logger.warn(
        `Subcategory not found with ID: ${id} in category ID: ${categoryId}`,
      );
      throw new NotFoundException(
        `Subcategory with ID ${id} not found in category ${categoryId}`,
      );
    }
    this.logger.log(`Found subcategory with ID: ${id}`);
    return subcategory;
  }

  async create(
    categoryId: number,
    createSubcategoryDto: CreateSubcategoryDto,
  ): Promise<Subcategory> {
    this.logger.log(`Creating new subcategory in category ID: ${categoryId}`);

    // Verify category exists
    const category = await this.categoryRepository.findOne({
      where: { id: categoryId },
    });
    if (!category) {
      this.logger.warn(`Category not found with ID: ${categoryId}`);
      throw new NotFoundException(`Category with ID ${categoryId} not found`);
    }

    const subcategory = this.subcategoryRepository.create({
      ...createSubcategoryDto,
      category,
    });

    const savedSubcategory = await this.subcategoryRepository.save(subcategory);
    this.logger.log(`Created new subcategory with ID: ${savedSubcategory.id}`);
    return savedSubcategory;
  }

  async update(
    categoryId: number,
    id: number,
    updateSubcategoryDto: UpdateSubcategoryDto,
  ): Promise<Subcategory> {
    this.logger.log(
      `Updating subcategory with ID: ${id} in category ID: ${categoryId}`,
    );
    const subcategory = await this.findOne(categoryId, id);
    Object.assign(subcategory, updateSubcategoryDto);
    const updatedSubcategory =
      await this.subcategoryRepository.save(subcategory);
    this.logger.log(`Successfully updated subcategory with ID: ${id}`);
    return updatedSubcategory;
  }

  async remove(categoryId: number, id: number): Promise<void> {
    this.logger.log(
      `Attempting to remove subcategory with ID: ${id} from category ID: ${categoryId}`,
    );
    const subcategory = await this.findOne(categoryId, id);
    await this.subcategoryRepository.remove(subcategory);
    this.logger.log(`Successfully removed subcategory with ID: ${id}`);
  }
}
