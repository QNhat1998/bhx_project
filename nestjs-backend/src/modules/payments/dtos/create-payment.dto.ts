import { IsNumber, IsString, IsOptional, IsEnum, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum PaymentStatus {
  PENDING = 'pending',
  PAID = 'paid',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}

export class CreatePaymentDto {
  @ApiProperty({
    description: 'ID của đơn hàng',
    example: 1,
  })
  @IsNumber()
  @Min(1)
  order_id: number;

  @ApiProperty({
    description: 'ID của phương thức thanh toán',
    example: 1,
  })
  @IsNumber()
  @Min(1)
  payment_method_id: number;

  @ApiProperty({
    description: 'Mã giao dịch',
    example: 'TXN123456',
    required: false,
  })
  @IsString()
  @IsOptional()
  transaction_id?: string;

  @ApiProperty({
    description: 'Số tiền thanh toán',
    example: 1000000,
  })
  @IsNumber()
  @Min(0)
  amount: number;

  @ApiProperty({
    description: 'Trạng thái thanh toán',
    enum: PaymentStatus,
    example: PaymentStatus.PENDING,
  })
  @IsEnum(PaymentStatus)
  @IsOptional()
  status?: PaymentStatus;

  @ApiProperty({
    description: 'Thời gian thanh toán',
    required: false,
  })
  @IsOptional()
  paid_at?: Date;
}
