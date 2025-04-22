import {
  IsString,
  IsEmail,
  Length,
  IsOptional,
  MinLength,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ description: 'Họ và tên', example: 'Nguyễn Văn A' })
  @IsString()
  @Length(1, 255)
  full_name: string;

  @ApiProperty({ description: 'Email đăng ký', example: 'user@example.com' })
  @IsEmail()
  @Length(1, 255)
  email: string;

  @ApiProperty({ description: 'Số điện thoại', example: '0123456789' })
  @IsString()
  @Length(10, 11)
  phone: string;

  @ApiProperty({ description: 'Mật khẩu', minLength: 6, example: '123456' })
  @IsString()
  @MinLength(6)
  password: string;

  @ApiProperty({
    description: 'Địa chỉ',
    required: false,
    example: '123 Đường ABC, Quận 1, TP.HCM',
  })
  @IsString()
  @IsOptional()
  @Length(1, 500)
  address?: string;

  @IsString()
  @IsOptional()
  @Length(1, 500)
  avatar?: string;
}
