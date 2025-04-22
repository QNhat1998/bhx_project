// src/users/dto/update-user.dto.ts
import { IsString, IsOptional, Length, IsInt, Min } from 'class-validator';

export class UpdateUserDto {
  @IsString()
  @IsOptional()
  @Length(1, 255)
  full_name?: string;

  @IsString()
  @IsOptional()
  @Length(6, 255)
  password?: string;

  @IsString()
  @IsOptional()
  @Length(1, 500)
  address?: string;

  @IsString()
  @IsOptional()
  @Length(1, 500)
  avatar?: string;

  @IsInt()
  @Min(1)
  @IsOptional()
  role_id?: number;
}
