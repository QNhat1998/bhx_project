import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Brand } from '../../entities/brand.entity';
import { BrandsController } from './brands.controller';
import { Role } from 'src/entities/role.entity';
import { BrandsService } from './brands.service';

@Module({
  imports: [TypeOrmModule.forFeature([Brand, Role])],
  controllers: [BrandsController],
  providers: [BrandsService],
})
export class BrandsModule {}
