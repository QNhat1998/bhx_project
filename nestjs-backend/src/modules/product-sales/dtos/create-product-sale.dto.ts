import {
  IsNumber,
  IsDateString,
  IsEnum,
  IsOptional,
  Min,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { ProductSaleStatus } from '../../../entities/product-sale.entity';

export class CreateProductSaleDto {
  @ApiProperty({
    description: 'ID sản phẩm',
    example: 1,
  })
  @IsNumber()
  @Min(1)
  product_id: number;

  @ApiProperty({
    description: 'Giá bán khuyến mãi',
    example: 990000,
  })
  @IsNumber()
  @Min(0)
  sale_price: number;

  @ApiProperty({
    description: 'Giá gốc',
    required: false,
    example: 1200000,
  })
  @IsNumber()
  @IsOptional()
  @Min(0)
  original_price?: number;

  @ApiProperty({
    description: 'Phần trăm giảm giá',
    required: false,
    example: 20,
  })
  @IsNumber()
  @IsOptional()
  @Min(0)
  discount_pct?: number;

  @ApiProperty({
    description: 'Ngày bắt đầu',
    example: '2024-03-01T00:00:00Z',
  })
  @IsDateString()
  start_date: Date;

  @ApiProperty({
    description: 'Ngày kết thúc',
    example: '2024-03-31T23:59:59Z',
  })
  @IsDateString()
  end_date: Date;

  @ApiProperty({
    description: 'Trạng thái',
    enum: ProductSaleStatus,
    default: ProductSaleStatus.SCHEDULED,
    example: ProductSaleStatus.SCHEDULED,
  })
  @IsEnum(ProductSaleStatus)
  @IsOptional()
  status?: ProductSaleStatus = ProductSaleStatus.SCHEDULED;
}
