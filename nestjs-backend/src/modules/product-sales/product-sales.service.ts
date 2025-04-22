import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import {
  ProductSale,
  ProductSaleStatus,
} from '../../entities/product-sale.entity';
import { Product } from '../../entities/product.entity';
import { CreateProductSaleDto } from './dtos/create-product-sale.dto';
import { UpdateProductSaleDto } from './dtos/update-product-sale.dto';

@Injectable()
export class ProductSalesService {
  private readonly logger = new Logger(ProductSalesService.name);

  constructor(
    @InjectRepository(ProductSale)
    private readonly productSaleRepository: Repository<ProductSale>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
  ) {}

  async findAll(): Promise<ProductSale[]> {
    this.logger.log('Fetching all product sales');
    const sales = await this.productSaleRepository.find({
      relations: ['product'],
    });
    this.logger.log(`Found ${sales.length} product sales`);
    return sales;
  }

  async findActive(): Promise<ProductSale[]> {
    this.logger.log('Fetching active product sales');
    const currentDate = new Date();
    const sales = await this.productSaleRepository.find({
      where: {
        status: ProductSaleStatus.ACTIVE,
        start_date: LessThanOrEqual(currentDate),
        end_date: MoreThanOrEqual(currentDate),
      },
      relations: ['product'],
    });
    this.logger.log(`Found ${sales.length} active product sales`);
    return sales;
  }

  async findOne(id: number): Promise<ProductSale> {
    this.logger.log(`Finding product sale with ID: ${id}`);
    const sale = await this.productSaleRepository.findOne({
      where: { id },
      relations: ['product'],
    });
    if (!sale) {
      this.logger.warn(`Product sale not found with ID: ${id}`);
      throw new NotFoundException(`Product sale with ID ${id} not found`);
    }
    this.logger.log(`Found product sale with ID: ${id}`);
    return sale;
  }

  async findByProduct(productId: number): Promise<ProductSale[]> {
    this.logger.log(`Finding sales for product ID: ${productId}`);
    const sales = await this.productSaleRepository.find({
      where: { product_id: productId },
      relations: ['product'],
    });
    this.logger.log(`Found ${sales.length} sales for product ID: ${productId}`);
    return sales;
  }

  async create(
    createProductSaleDto: CreateProductSaleDto,
  ): Promise<ProductSale> {
    this.logger.log(
      `Creating new product sale for product ID: ${createProductSaleDto.product_id}`,
    );

    // Verify product exists
    const product = await this.productRepository.findOne({
      where: { id: createProductSaleDto.product_id },
    });
    if (!product) {
      throw new NotFoundException(
        `Product with ID ${createProductSaleDto.product_id} not found`,
      );
    }

    const sale = this.productSaleRepository.create(createProductSaleDto);
    const savedSale = await this.productSaleRepository.save(sale);
    this.logger.log(`Created new product sale with ID: ${savedSale.id}`);
    return this.findOne(savedSale.id);
  }

  async update(
    id: number,
    updateProductSaleDto: UpdateProductSaleDto,
  ): Promise<ProductSale> {
    this.logger.log(`Updating product sale with ID: ${id}`);
    const sale = await this.findOne(id);

    if (updateProductSaleDto.product_id) {
      const product = await this.productRepository.findOne({
        where: { id: updateProductSaleDto.product_id },
      });
      if (!product) {
        throw new NotFoundException(
          `Product with ID ${updateProductSaleDto.product_id} not found`,
        );
      }
    }

    Object.assign(sale, updateProductSaleDto);
    const updatedSale = await this.productSaleRepository.save(sale);
    this.logger.log(`Successfully updated product sale with ID: ${id}`);
    return this.findOne(updatedSale.id);
  }

  async remove(id: number): Promise<void> {
    this.logger.log(`Attempting to remove product sale with ID: ${id}`);
    const sale = await this.findOne(id);
    await this.productSaleRepository.remove(sale);
    this.logger.log(`Successfully removed product sale with ID: ${id}`);
  }
}
