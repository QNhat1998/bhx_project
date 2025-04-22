import { IsOptional, IsNumber, Min, IsString } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class CommentFilterDto {
  @ApiProperty({
    description: 'ID sản phẩm để lọc bình luận',
    required: false,
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  product_id?: number;

  @ApiProperty({
    description: 'Từ khóa tìm kiếm trong nội dung hoặc tên khách hàng',
    required: false,
    example: 'tốt',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiProperty({
    description: 'Trạng thái bình luận',
    required: false,
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  status?: number;

  @ApiProperty({
    description: 'Lọc theo số sao đánh giá',
    required: false,
    minimum: 0,
    example: 5,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  rating?: number;

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
    default: 'created_at',
    example: 'created_at',
  })
  @IsOptional()
  @IsString()
  sortBy?: string = 'created_at';

  @ApiProperty({
    description: 'Thứ tự sắp xếp',
    required: false,
    enum: ['ASC', 'DESC'],
    default: 'DESC',
    example: 'DESC',
  })
  @IsOptional()
  @IsString()
  sortOrder?: 'ASC' | 'DESC' = 'DESC';
}
