import {
  IsString,
  IsNumber,
  IsOptional,
  Min,
  Max,
  Length,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCommentDto {
  @ApiProperty({ description: 'ID sản phẩm', example: 1 })
  @IsNumber()
  product_id: number;

  @ApiProperty({ description: 'Tên khách hàng', required: false, example: 'Nguyễn Văn A' })
  @IsString()
  @IsOptional()
  @Length(1, 100)
  customer_name?: string;

  @ApiProperty({ description: 'Nội dung bình luận', example: 'Sản phẩm rất tốt!' })
  @IsString()
  @Length(1, 1000)
  content: string;

  @ApiProperty({ description: 'Đánh giá sao', minimum: 0, maximum: 5, required: false, example: 5 })
  @IsNumber()
  @IsOptional()
  @Min(0)
  @Max(5)
  rating?: number;

  @ApiProperty({ description: 'Trạng thái bình luận', required: false, default: 1, example: 1 })
  @IsNumber()
  @IsOptional()
  status?: number = 1;
}
