import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { Category } from '../entities/category.entity';
import { Brand } from '../entities/brand.entity';
import { Role } from '../entities/role.entity';
import { Subcategory } from '../entities/subcategory.entity';
import { Promotion } from '../entities/promotion.entity';
import { PaymentMethod } from '../entities/payment-method.entity';
import { User } from '../entities/user.entity';
import { Product } from '../entities/product.entity';
import { Order } from '../entities/order.entity';
import { OrderDetail } from 'src/entities/order-detail.entity';
import { Payment } from 'src/entities/payment.entity';
import { Comment } from 'src/entities/comment.entity';
import { RefreshToken } from 'src/entities/refresh-token.entity';

export const databaseConfig = (
  configService: ConfigService,
): TypeOrmModuleOptions => ({
  type: 'mysql',
  driver: require('mysql2'),
  host: configService.get('DATABASE_HOST'),
  port: configService.get<number>('DATABASE_PORT'),
  username: configService.get('DATABASE_USER'),
  password: configService.get('DATABASE_PASSWORD'),
  database: configService.get('DATABASE_NAME'),
  entities: [
    Category,
    Brand,
    Role,
    Subcategory,
    Promotion,
    PaymentMethod,
    User,
    Product,
    Order,
    Payment,
    OrderDetail,
    Comment,
    RefreshToken,
  ],
  synchronize: true,
});
