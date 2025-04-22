import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Brand } from '../../entities/brand.entity';
import { CreateBrandDto } from './dtos/create-brand.dto';
import { UpdateBrandDto } from './dtos/update-brand.dto';

@Injectable()
export class BrandsService {
  private readonly logger = new Logger(BrandsService.name);

  constructor(
    @InjectRepository(Brand)
    private readonly brandRepository: Repository<Brand>,
  ) {}

  // Lấy tất cả thương hiệu
  async findAll(): Promise<Brand[]> {
    this.logger.log('Fetching all brands');
    const brands = await this.brandRepository.find();
    this.logger.log(`Found ${brands.length} brands`);
    return brands;
  }

  // Lấy thương hiệu theo ID
  async findOne(id: number): Promise<Brand> {
    this.logger.log(`Finding brand with ID: ${id}`);
    const brand = await this.brandRepository.findOne({ where: { id } });
    if (!brand) {
      this.logger.warn(`Brand not found with ID: ${id}`);
      throw new NotFoundException(`Brand with ID ${id} not found`);
    }
    this.logger.log(`Found brand with ID: ${id}`);
    return brand;
  }

  // Tạo thương hiệu mới
  async create(createBrandDto: CreateBrandDto): Promise<Brand> {
    this.logger.log(`Creating new brand with name: ${createBrandDto.name}`);
    const brand = this.brandRepository.create(createBrandDto);
    const savedBrand = await this.brandRepository.save(brand);
    this.logger.log(`Created new brand with ID: ${savedBrand.id}`);
    return savedBrand;
  }

  // Cập nhật thương hiệu
  async update(id: number, updateBrandDto: UpdateBrandDto): Promise<Brand> {
    this.logger.log(`Updating brand with ID: ${id}`);
    const brand = await this.findOne(id);
    Object.assign(brand, updateBrandDto);
    const updatedBrand = await this.brandRepository.save(brand);
    this.logger.log(`Successfully updated brand with ID: ${id}`);
    return updatedBrand;
  }

  // Xóa thương hiệu
  async remove(id: number): Promise<void> {
    this.logger.log(`Attempting to remove brand with ID: ${id}`);
    const brand = await this.findOne(id);
    await this.brandRepository.remove(brand);
    this.logger.log(`Successfully removed brand with ID: ${id}`);
  }
}
