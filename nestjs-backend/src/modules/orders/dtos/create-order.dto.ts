import {
  IsString,
  IsNumber,
  IsOptional,
  IsArray,
  ValidateNested,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class CreateOrderDetailDto {
  @ApiProperty({
    description: 'ID của sản phẩm',
    example: 1,
  })
  @IsNumber()
  @Min(1)
  product_id: number;

  @ApiProperty({
    description: 'Số lượng sản phẩm',
    example: 2,
  })
  @IsNumber()
  @Min(1)
  quantity: number;
}

export class CreateOrderDto {
  @ApiProperty({
    description: 'ID của người dùng',
    example: 1,
    required: false,
  })
  @IsNumber()
  @IsOptional()
  @Min(1)
  user_id?: number;

  @ApiProperty({
    description: 'Tên khách hàng',
    example: 'Nguyễn Văn A',
  })
  @IsString()
  customer_name: string;

  @ApiProperty({
    description: 'Số điện thoại khách hàng',
    example: '0123456789',
  })
  @IsString()
  customer_phone: string;

  @ApiProperty({
    description: 'Địa chỉ khách hàng',
    example: '123 Đường ABC, Quận XYZ, TP.HCM',
  })
  @IsString()
  customer_address: string;

  @ApiProperty({
    description: 'Danh sách sản phẩm trong đơn hàng',
    type: [CreateOrderDetailDto],
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderDetailDto)
  order_details: CreateOrderDetailDto[];
}
