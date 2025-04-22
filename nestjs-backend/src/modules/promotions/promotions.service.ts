import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import {
  Repository,
  LessThanOrEqual,
  MoreThanOrEqual,
  Like,
  Brackets,
  Between,
} from 'typeorm';
import { Promotion } from '../../entities/promotion.entity';
import { CreatePromotionDto } from './dtos/create-promotion.dto';
import { UpdatePromotionDto } from './dtos/update-promotion.dto';
import { PromotionFilterDto } from './dtos/promotion-filter.dto';

@Injectable()
export class PromotionsService {
  private readonly logger = new Logger(PromotionsService.name);

  constructor(
    @InjectRepository(Promotion)
    private readonly promotionRepository: Repository<Promotion>,
  ) {}

  private generateUrl(title: string): string {
    return title
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[đĐ]/g, 'd')
      .replace(/[^a-z0-9\s]/g, '')
      .replace(/\s+/g, '-');
  }

  async findAll(): Promise<Promotion[]> {
    this.logger.log('Fetching all promotions');
    const promotions = await this.promotionRepository.find();
    this.logger.log(`Found ${promotions.length} promotions`);
    return promotions;
  }

  async findActive(): Promise<Promotion[]> {
    this.logger.log('Fetching active promotions');
    const currentDate = new Date();
    const promotions = await this.promotionRepository.find({
      where: {
        status: true,
        start_date: LessThanOrEqual(currentDate),
        end_date: MoreThanOrEqual(currentDate),
      },
      order: { id: 'ASC' },
    });
    this.logger.log(`Found ${promotions.length} active promotions`);
    return promotions;
  }

  async findWithFilters(filterDto: PromotionFilterDto) {
    const {
      search,
      status,
      fromDate,
      toDate,
      code,
      minDiscount,
      maxDiscount,
      page = 1,
      limit = 10,
      sortBy,
      sortOrder,
    } = filterDto;
    const queryBuilder =
      this.promotionRepository.createQueryBuilder('promotion');

    // Tìm kiếm theo title hoặc description
    if (search) {
      queryBuilder.andWhere(
        new Brackets((qb) => {
          qb.where('promotion.title LIKE :search', {
            search: `%${search}%`,
          }).orWhere('promotion.description LIKE :search', {
            search: `%${search}%`,
          });
        }),
      );
    }

    // Lọc theo trạng thái
    if (status !== undefined) {
      queryBuilder.andWhere('promotion.status = :status', { status });
    }

    // Lọc theo mã khuyến mãi
    if (code) {
      queryBuilder.andWhere('promotion.code LIKE :code', { code: `%${code}%` });
    }

    // Lọc theo khoảng thời gian
    if (fromDate && toDate) {
      queryBuilder.andWhere(
        new Brackets((qb) => {
          qb.where(
            '(promotion.start_date <= :toDate AND promotion.end_date >= :fromDate)',
            { fromDate, toDate },
          );
        }),
      );
    }

    // Lọc theo khoảng giảm giá
    if (minDiscount !== undefined) {
      queryBuilder.andWhere(
        new Brackets((qb) => {
          qb.where('promotion.discount_amount >= :minDiscount', {
            minDiscount,
          }).orWhere('promotion.discount_percent >= :minDiscount', {
            minDiscount,
          });
        }),
      );
    }

    if (maxDiscount !== undefined) {
      queryBuilder.andWhere(
        new Brackets((qb) => {
          qb.where('promotion.discount_amount <= :maxDiscount', {
            maxDiscount,
          }).orWhere('promotion.discount_percent <= :maxDiscount', {
            maxDiscount,
          });
        }),
      );
    }

    // Sắp xếp
    if (sortBy && this.isSortColumnValid(sortBy)) {
      queryBuilder.orderBy(`promotion.${sortBy}`, sortOrder);
    } else {
      queryBuilder.orderBy('promotion.created_at', 'ASC');
    }

    // Phân trang
    const skip = (page - 1) * limit;
    queryBuilder.skip(skip).take(limit);

    const [promotions, total] = await queryBuilder.getManyAndCount();

    return {
      items: promotions,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  private isSortColumnValid(column: string): boolean {
    const validColumns = [
      'id',
      'title',
      'start_date',
      'end_date',
      'status',
      'created_at',
      'updated_at',
    ];
    return validColumns.includes(column);
  }

  async findOne(id: number): Promise<Promotion> {
    this.logger.log(`Finding promotion with ID: ${id}`);
    const promotion = await this.promotionRepository.findOne({ where: { id } });
    if (!promotion) {
      this.logger.warn(`Promotion not found with ID: ${id}`);
      throw new NotFoundException(`Promotion with ID ${id} not found`);
    }
    this.logger.log(`Found promotion with ID: ${id}`);
    return promotion;
  }

  async create(createPromotionDto: CreatePromotionDto): Promise<Promotion> {
    this.logger.log(`Creating new promotion: ${createPromotionDto.title}`);

    // Tự động tạo URL từ title nếu không được cung cấp
    if (!createPromotionDto.url) {
      createPromotionDto.url = this.generateUrl(createPromotionDto.title);
    }

    const promotion = this.promotionRepository.create(createPromotionDto);
    const savedPromotion = await this.promotionRepository.save(promotion);
    this.logger.log(`Created new promotion with ID: ${savedPromotion.id}`);
    return savedPromotion;
  }

  async update(
    id: number,
    updatePromotionDto: UpdatePromotionDto,
  ): Promise<Promotion> {
    this.logger.log(`Updating promotion with ID: ${id}`);
    const promotion = await this.findOne(id);

    // Tự động cập nhật URL nếu title thay đổi và URL không được cung cấp
    if (updatePromotionDto.title && !updatePromotionDto.url) {
      updatePromotionDto.url = this.generateUrl(updatePromotionDto.title);
    }

    Object.assign(promotion, updatePromotionDto);
    const updatedPromotion = await this.promotionRepository.save(promotion);
    this.logger.log(`Successfully updated promotion with ID: ${id}`);
    return updatedPromotion;
  }

  async remove(id: number): Promise<void> {
    this.logger.log(`Attempting to remove promotion with ID: ${id}`);
    const promotion = await this.findOne(id);
    await this.promotionRepository.remove(promotion);
    this.logger.log(`Successfully removed promotion with ID: ${id}`);
  }
}
