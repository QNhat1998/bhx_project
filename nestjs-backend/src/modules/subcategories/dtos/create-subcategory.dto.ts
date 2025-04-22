import { IsString, Length, IsNumber } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateSubcategoryDto {
  @ApiProperty({ description: 'ID danh mục cha', example: 1 })
  @IsNumber()
  category_id: number;

  @ApiProperty({ description: 'Tên danh mục con', example: 'iPhone' })
  @IsString()
  @Length(1, 100)
  name: string;

  @ApiProperty({ description: 'Đường dẫn URL', example: 'iphone' })
  @IsString()
  @Length(1, 100)
  url: string;

  @IsString()
  @Length(1, 255)
  img: string;
}
