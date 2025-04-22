import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import { ProductSalesService } from './product-sales.service';
import { CreateProductSaleDto } from './dtos/create-product-sale.dto';
import { UpdateProductSaleDto } from './dtos/update-product-sale.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Public } from '../auth/decorators/public.decorator';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('Product Sales')
@Controller('product-sales')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ProductSalesController {
  constructor(private readonly productSalesService: ProductSalesService) {}

  @Get()
  @Public()
  findAll() {
    return this.productSalesService.findAll();
  }

  @Get('active')
  @Public()
  findActive() {
    return this.productSalesService.findActive();
  }

  @Public()
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.productSalesService.findOne(id);
  }

  @Post()
  @ApiBearerAuth()
  @Roles('super_admin', 'admin')
  create(@Body() createProductSaleDto: CreateProductSaleDto) {
    return this.productSalesService.create(createProductSaleDto);
  }

  @Put(':id')
  @ApiBearerAuth()
  @Roles('super_admin', 'admin')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateProductSaleDto: UpdateProductSaleDto,
  ) {
    return this.productSalesService.update(id, updateProductSaleDto);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @Roles('super_admin', 'admin')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.productSalesService.remove(id);
  }
}
