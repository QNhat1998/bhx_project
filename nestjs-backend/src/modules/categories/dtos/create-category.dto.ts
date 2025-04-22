import { IsString, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCategoryDto {
  @ApiProperty({ description: 'Tên danh mục', example: 'Điện thoại' })
  @IsString()
  @Length(1, 100)
  name: string;
}
