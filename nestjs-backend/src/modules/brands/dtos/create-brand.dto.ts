import { IsString, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateBrandDto {
  @ApiProperty({ description: 'Tên thương hiệu', example: 'Apple' })
  @IsString()
  @Length(1, 255)
  name: string;

  @ApiProperty({ description: 'Đường dẫn URL', example: 'apple' })
  @IsString()
  @Length(1, 255)
  url: string;

  @ApiProperty({
    description: 'Đường dẫn hình ảnh',
    example: 'https://example.com/apple-logo.png',
  })
  @IsString()
  @Length(1, 255)
  img: string;
}
