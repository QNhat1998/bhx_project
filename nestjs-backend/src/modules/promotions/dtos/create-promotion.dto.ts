import {
  IsString,
  IsDateString,
  IsBoolean,
  IsOptional,
  Length,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreatePromotionDto {
  @ApiProperty({
    description: 'Tiêu đề khuyến mãi',
    example: 'Giảm giá mùa hè',
  })
  @IsString()
  @Length(1, 255)
  title: string;

  @ApiProperty({
    description: 'Đường dẫn hình ảnh',
    required: false,
    example: 'promotions/summer-sale.jpg',
  })
  @IsString()
  @IsOptional()
  @Length(1, 512)
  img_path?: string;

  @ApiProperty({
    description: 'Đường dẫn URL',
    example: 'giam-gia-mua-he',
  })
  @IsString()
  @Length(1, 255)
  url: string;

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
    description: 'Trạng thái khuyến mãi',
    default: true,
    required: false,
    example: true,
  })
  @IsBoolean()
  @IsOptional()
  status?: boolean = true;
}
