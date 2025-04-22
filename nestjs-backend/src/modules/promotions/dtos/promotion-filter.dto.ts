import {
  IsOptional,
  IsBoolean,
  IsString,
  IsDateString,
  IsNumber,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class PromotionFilterDto {
  @ApiProperty({
    description: 'Từ khóa tìm kiếm',
    required: false,
    example: 'giảm giá',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiProperty({
    description: 'Trạng thái khuyến mãi',
    required: false,
    example: true,
  })
  @IsOptional()
  @IsBoolean()
  @Type(() => Boolean)
  status?: boolean;

  @ApiProperty({
    description: 'Ngày bắt đầu',
    required: false,
    example: '2024-03-01',
  })
  @IsOptional()
  @IsDateString()
  fromDate?: string;

  @ApiProperty({
    description: 'Ngày kết thúc',
    required: false,
    example: '2024-03-31',
  })
  @IsOptional()
  @IsDateString()
  toDate?: string;

  @ApiProperty({
    description: 'URL khuyến mãi',
    required: false,
    example: 'giam-gia-mua-he',
  })
  @IsOptional()
  @IsString()
  url?: string;

  @ApiProperty({
    description: 'Mã khuyến mãi',
    required: false,
    example: 'SUMMER2024',
  })
  @IsOptional()
  @IsString()
  code?: string;

  @ApiProperty({
    description: 'Mức giảm giá tối thiểu',
    required: false,
    minimum: 0,
    example: 10,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  minDiscount?: number;

  @ApiProperty({
    description: 'Mức giảm giá tối đa',
    required: false,
    minimum: 0,
    example: 50,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  maxDiscount?: number;

  @ApiProperty({
    description: 'Số trang',
    required: false,
    minimum: 1,
    default: 1,
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  page?: number = 1;

  @ApiProperty({
    description: 'Số bản ghi trên một trang',
    required: false,
    minimum: 1,
    default: 10,
    example: 10,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  limit?: number = 10;

  @ApiProperty({
    description: 'Sắp xếp theo trường',
    required: false,
    default: 'sort_order',
    example: 'sort_order',
  })
  @IsOptional()
  @IsString()
  sortBy?: string = 'sort_order';

  @ApiProperty({
    description: 'Thứ tự sắp xếp',
    required: false,
    enum: ['ASC', 'DESC'],
    default: 'ASC',
    example: 'ASC',
  })
  @IsOptional()
  @IsString()
  sortOrder?: 'ASC' | 'DESC' = 'ASC';
}
