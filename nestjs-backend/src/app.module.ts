import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Category } from './entities/category.entity';
import { Brand } from './entities/brand.entity';
import { Role } from './entities/role.entity';
import { Subcategory } from './entities/subcategory.entity';
import { Promotion } from './entities/promotion.entity';
import { PaymentMethod } from './entities/payment-method.entity';
import { User } from './entities/user.entity';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { CategoriesModule } from './modules/categories/categories.module';
import { BrandsModule } from './modules/brands/brands.module';
import { PromotionsModule } from './modules/promotions/promotions.module';
import { SubcategoriesModule } from './modules/subcategories/subcategories.module';
import { ProductsModule } from './modules/products/products.module';
import { UsersModule } from './modules/users/users.module';
import { OrdersModule } from './modules/orders/orders.module';
import { databaseConfig } from './config/database.config';
import { Product } from './entities/product.entity';
import { Order } from './entities/order.entity';
import { AuthModule } from './modules/auth/auth.module';
import { CommentsModule } from './modules/comments/comments.module';
import { Comment } from './entities/comment.entity';
import { ProductSale } from './entities/product-sale.entity';
import { ProductSalesModule } from './modules/product-sales/product-sales.module';
import { PaymentMethodsModule } from './modules/payment-methods/payment-methods.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { Payment } from './entities/payment.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) =>
        databaseConfig(configService),
      inject: [ConfigService],
    }),
    TypeOrmModule.forFeature([
      Category,
      Brand,
      Role,
      Subcategory,
      Promotion,
      PaymentMethod,
      User,
      Product,
      Order,
      Comment,
      ProductSale,
      Payment,
      PaymentMethod,
    ]),
    CategoriesModule,
    BrandsModule,
    PromotionsModule,
    SubcategoriesModule,
    ProductsModule,
    UsersModule,
    OrdersModule,
    AuthModule,
    CommentsModule,
    ProductSalesModule,
    PaymentMethodsModule,
    PaymentsModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
