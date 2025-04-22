import { IsString, IsBoolean, IsOptional, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreatePaymentMethodDto {
  @ApiProperty({
    description: 'Tên phương thức thanh toán',
    example: 'Thanh toán khi nhận hàng (COD)',
  })
  @IsString()
  @Length(1, 100)
  name: string;

  @ApiProperty({
    description: 'Khóa định danh phương thức thanh toán',
    example: 'cod',
  })
  @IsString()
  @Length(1, 50)
  method_key: string;

  @ApiProperty({
    description: 'URL logo của phương thức thanh toán',
    example: 'https://example.com/cod-logo.png',
    required: false,
  })
  @IsString()
  @IsOptional()
  @Length(1, 255)
  logo?: string;

  @ApiProperty({
    description: 'Mô tả phương thức thanh toán',
    example: 'Thanh toán tiền mặt khi nhận hàng',
    required: false,
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'Trạng thái kích hoạt',
    example: true,
    default: true,
  })
  @IsBoolean()
  @IsOptional()
  active?: boolean;
}
