import {
  IsString,
  IsNumber,
  IsUrl,
  Min,
  Length,
  IsBoolean,
  IsOptional,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProductDto {
  @ApiProperty({ description: 'Tên sản phẩm', example: 'iPhone 14 Pro Max' })
  @IsString()
  @Length(1, 255)
  product_name: string;

  @ApiProperty({ description: 'Giá sản phẩm', example: '27990000' })
  @IsString()
  price: string;

  @ApiProperty({
    description: 'Đường dẫn hình ảnh',
    required: false,
    example: 'https://example.com/iphone.jpg',
  })
  @IsString()
  @IsOptional()
  @Length(1, 255)
  img: string;

  @ApiProperty({
    description: 'Đường dẫn URL sản phẩm',
    example: 'iphone-14-pro-max',
  })
  @IsString()
  @Length(1, 255)
  url: string;

  @ApiProperty({ description: 'Số lượng tồn kho', minimum: 0, example: 100 })
  @IsNumber()
  @Min(0)
  stock: number;

  @ApiProperty({ description: 'Đánh giá sản phẩm', minimum: 0, example: 4.5 })
  @IsNumber()
  @Min(0)
  rating: number;

  @ApiProperty({ description: 'Trạng thái sản phẩm', example: true })
  @IsBoolean()
  status: boolean;

  @ApiProperty({ description: 'ID danh mục', example: 1 })
  @IsNumber()
  category_id: number;

  @ApiProperty({ description: 'ID danh mục con', example: 1 })
  @IsNumber()
  subcategory_id: number;
}
