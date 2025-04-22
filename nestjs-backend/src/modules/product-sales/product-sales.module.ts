import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProductSalesController } from './product-sales.controller';
import { ProductSalesService } from './product-sales.service';
import { ProductSale } from '../../entities/product-sale.entity';
import { Product } from '../../entities/product.entity';
import { ProductSaleSubscriber } from '../../subscribers/product-sale.subscriber';

@Module({
  imports: [TypeOrmModule.forFeature([ProductSale, Product])],
  controllers: [ProductSalesController],
  providers: [ProductSalesService, ProductSaleSubscriber],
  exports: [ProductSalesService],
})
export class ProductSalesModule {}
