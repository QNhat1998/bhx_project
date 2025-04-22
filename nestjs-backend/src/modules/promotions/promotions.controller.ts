import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  ParseIntPipe,
  UseGuards,
  Query,
} from '@nestjs/common';
import { PromotionsService } from './promotions.service';
import { CreatePromotionDto } from './dtos/create-promotion.dto';
import { UpdatePromotionDto } from './dtos/update-promotion.dto';
import { PromotionFilterDto } from './dtos/promotion-filter.dto';
import { Promotion } from '../../entities/promotion.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Public } from '../auth/decorators/public.decorator';

@Controller('promotions')
export class PromotionsController {
  constructor(private readonly promotionsService: PromotionsService) {}

  @Public()
  @Get()
  findAll(): Promise<Promotion[]> {
    return this.promotionsService.findAll();
  }

  @Public()
  @Get('search')
  search(@Query() filterDto: PromotionFilterDto) {
    return this.promotionsService.findWithFilters(filterDto);
  }

  @Public()
  @Get('active')
  findActive(): Promise<Promotion[]> {
    return this.promotionsService.findActive();
  }

  @Public()
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number): Promise<Promotion> {
    return this.promotionsService.findOne(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Post()
  @Roles('super_admin', 'admin')
  create(@Body() createPromotionDto: CreatePromotionDto): Promise<Promotion> {
    return this.promotionsService.create(createPromotionDto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Put(':id')
  @Roles('super_admin', 'admin')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updatePromotionDto: UpdatePromotionDto,
  ): Promise<Promotion> {
    return this.promotionsService.update(id, updatePromotionDto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Delete(':id')
  @Roles('super_admin')
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.promotionsService.remove(id);
  }
}
