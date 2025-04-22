import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Order } from '../../entities/order.entity';
import { OrderDetail } from '../../entities/order-detail.entity';
import { Payment } from '../../entities/payment.entity';
import { CreateOrderDto } from './dtos/create-order.dto';
import { UpdateOrderDto, OrderStatus } from './dtos/update-order.dto';
import { PaymentStatus } from '../payments/dtos/create-payment.dto';

@Injectable()
export class OrdersService {
  constructor(
    private dataSource: DataSource,
    @InjectRepository(Order)
    private orderRepository: Repository<Order>,
    @InjectRepository(OrderDetail)
    private orderDetailRepository: Repository<OrderDetail>,
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
  ) {}

  async findAll() {
    return await this.orderRepository.find({
      relations: ['user', 'order_details', 'order_details.product', 'payments'],
    });
  }

  async findOne(id: number) {
    const order = await this.orderRepository.findOne({
      where: { id },
      relations: ['user', 'order_details', 'order_details.product', 'payments'],
    });
    if (!order) {
      throw new NotFoundException(`Order with ID ${id} not found`);
    }
    return order;
  }

  async findByUserId(userId: number) {
    return await this.orderRepository.find({
      where: { user_id: userId },
      relations: ['order_details', 'order_details.product', 'payments'],
      order: {
        created_at: 'DESC', // Sắp xếp theo thời gian tạo mới nhất
      },
    });
  }

  async create(createOrderDto: CreateOrderDto) {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Tạo đơn hàng
      const order = this.orderRepository.create({
        user_id: createOrderDto.user_id,
        customer_name: createOrderDto.customer_name,
        customer_phone: createOrderDto.customer_phone,
        customer_address: createOrderDto.customer_address,
        total_amount: 0,
        status: OrderStatus.PENDING,
      });
      await queryRunner.manager.save(order);

      // Tạo chi tiết đơn hàng
      let totalAmount = 0;
      for (const detail of createOrderDto.order_details) {
        const orderDetail = this.orderDetailRepository.create({
          order_id: order.id,
          product_id: detail.product_id,
          quantity: detail.quantity,
          // Lấy giá sản phẩm từ bảng products
          price: await this.getProductPrice(detail.product_id),
        });
        await queryRunner.manager.save(orderDetail);
        totalAmount += orderDetail.price * orderDetail.quantity;
      }

      // Cập nhật tổng tiền đơn hàng
      order.total_amount = totalAmount;
      await queryRunner.manager.save(order);

      await queryRunner.commitTransaction();
      return order;
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw err;
    } finally {
      await queryRunner.release();
    }
  }

  async update(id: number, updateOrderDto: UpdateOrderDto) {
    const order = await this.findOne(id);

    // Nếu trạng thái được cập nhật thành completed
    if (updateOrderDto.status === OrderStatus.COMPLETED) {
      // Tạo payment mới
      const payment = this.paymentRepository.create({
        order_id: order.id,
        payment_method_id: 1, // Default payment method (COD)
        amount: order.total_amount,
        status: PaymentStatus.PAID,
        paid_at: new Date(),
      });
      await this.paymentRepository.save(payment);
    }

    // Cập nhật order
    this.orderRepository.merge(order, updateOrderDto);
    return await this.orderRepository.save(order);
  }

  async remove(id: number) {
    const order = await this.findOne(id);
    return await this.orderRepository.remove(order);
  }

  private async getProductPrice(productId: number): Promise<number> {
    const product = await this.dataSource
      .getRepository('Product')
      .findOne({ where: { id: productId } });
    if (!product) {
      throw new NotFoundException(`Product with ID ${productId} not found`);
    }
    return parseFloat(product.price);
  }
}
