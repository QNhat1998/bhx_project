import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PaymentMethod } from '../../entities/payment-method.entity';
import { CreatePaymentMethodDto } from './dtos/create-payment-method.dto';
import { UpdatePaymentMethodDto } from './dtos/update-payment-method.dto';

@Injectable()
export class PaymentMethodsService {
  constructor(
    @InjectRepository(PaymentMethod)
    private paymentMethodRepository: Repository<PaymentMethod>,
  ) {}

  async findAll() {
    return await this.paymentMethodRepository.find();
  }

  async findActive() {
    return await this.paymentMethodRepository.find({
      where: { active: true },
    });
  }

  async findOne(id: number) {
    const paymentMethod = await this.paymentMethodRepository.findOne({
      where: { id },
    });
    if (!paymentMethod) {
      throw new NotFoundException(`Payment method with ID ${id} not found`);
    }
    return paymentMethod;
  }

  async create(createPaymentMethodDto: CreatePaymentMethodDto) {
    const paymentMethod = this.paymentMethodRepository.create(
      createPaymentMethodDto,
    );
    return await this.paymentMethodRepository.save(paymentMethod);
  }

  async update(id: number, updatePaymentMethodDto: UpdatePaymentMethodDto) {
    const paymentMethod = await this.findOne(id);
    this.paymentMethodRepository.merge(paymentMethod, updatePaymentMethodDto);
    return await this.paymentMethodRepository.save(paymentMethod);
  }

  async remove(id: number) {
    const paymentMethod = await this.findOne(id);
    return await this.paymentMethodRepository.remove(paymentMethod);
  }
}
