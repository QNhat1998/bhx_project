import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from '../../entities/product.entity';
import { Category } from '../../entities/category.entity';
import { Subcategory } from '../../entities/subcategory.entity';
import { CreateProductDto } from './dtos/create-product.dto';
import { UpdateProductDto } from './dtos/update-product.dto';

@Injectable()
export class ProductsService {
  private readonly logger = new Logger(ProductsService.name);

  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    @InjectRepository(Category)
    private readonly categoryRepository: Repository<Category>,
    @InjectRepository(Subcategory)
    private readonly subcategoryRepository: Repository<Subcategory>,
  ) {}

  async findAll(): Promise<Product[]> {
    this.logger.log('Fetching all products');
    const products = await this.productRepository.find({
      relations: ['category', 'subcategory'],
    });
    this.logger.log(`Found ${products.length} products`);
    return products;
  }

  async findAllByCategory(categoryId: number): Promise<Product[]> {
    this.logger.log(`Fetching all products for category ID: ${categoryId}`);
    const products = await this.productRepository.find({
      where: { category_id: categoryId },
      relations: ['category', 'subcategory'],
    });
    this.logger.log(
      `Found ${products.length} products for category ID: ${categoryId}`,
    );
    return products;
  }

  async findAllBySubcategory(
    categoryId: number,
    subcategoryId: number,
  ): Promise<Product[]> {
    this.logger.log(
      `Fetching products for category ID: ${categoryId} and subcategory ID: ${subcategoryId}`,
    );
    const products = await this.productRepository.find({
      where: {
        category_id: categoryId,
        subcategory_id: subcategoryId,
      },
      relations: ['category', 'subcategory'],
    });
    this.logger.log(`Found ${products.length} products`);
    return products;
  }

  async findOne(
    id: number,
    includeComments: boolean = false,
  ): Promise<Product> {
    this.logger.log(`Finding product with ID: ${id}`);

    const relations = ['category', 'subcategory'];
    if (includeComments) {
      relations.push('comments');
    }

    const product = await this.productRepository.findOne({
      where: { id },
      relations: relations,
      order: includeComments
        ? {
            comments: {
              created_at: 'DESC',
            },
          }
        : undefined,
    });

    if (!product) {
      this.logger.warn(`Product with ID ${id} not found`);
      throw new NotFoundException(`Product with ID ${id} not found`);
    }

    this.logger.log(`Found product with ID: ${id}`);
    return product;
  }

  async create(createProductDto: CreateProductDto): Promise<Product> {
    this.logger.log(`Creating new product: ${createProductDto.product_name}`);

    // Verify category exists
    const category = await this.categoryRepository.findOne({
      where: { id: createProductDto.category_id },
    });
    if (!category) {
      throw new NotFoundException(
        `Category with ID ${createProductDto.category_id} not found`,
      );
    }

    // Verify subcategory exists and belongs to the category
    const subcategory = await this.subcategoryRepository.findOne({
      where: {
        id: createProductDto.subcategory_id,
        category: { id: createProductDto.category_id },
      },
    });
    if (!subcategory) {
      throw new NotFoundException(
        `Subcategory with ID ${createProductDto.subcategory_id} not found in category ${createProductDto.category_id}`,
      );
    }

    const product = this.productRepository.create(createProductDto);
    const savedProduct = await this.productRepository.save(product);
    this.logger.log(`Created new product with ID: ${savedProduct.id}`);
    return this.findOne(savedProduct.id);
  }

  async update(
    id: number,
    updateProductDto: UpdateProductDto,
  ): Promise<Product> {
    this.logger.log(`Updating product with ID: ${id}`);
    const product = await this.findOne(id);

    if (updateProductDto.category_id) {
      const category = await this.categoryRepository.findOne({
        where: { id: updateProductDto.category_id },
      });
      if (!category) {
        throw new NotFoundException(
          `Category with ID ${updateProductDto.category_id} not found`,
        );
      }
    }

    if (updateProductDto.subcategory_id) {
      const subcategory = await this.subcategoryRepository.findOne({
        where: {
          id: updateProductDto.subcategory_id,
          category: { id: updateProductDto.category_id || product.category_id },
        },
      });
      if (!subcategory) {
        throw new NotFoundException(
          `Subcategory with ID ${updateProductDto.subcategory_id} not found in category`,
        );
      }
    }

    Object.assign(product, updateProductDto);
    await this.productRepository.save(product);
    this.logger.log(`Successfully updated product with ID: ${id}`);
    return this.findOne(id);
  }

  async remove(id: number): Promise<void> {
    this.logger.log(`Removing product with ID: ${id}`);
    const product = await this.findOne(id);
    await this.productRepository.remove(product);
    this.logger.log(`Successfully removed product with ID: ${id}`);
  }
}
