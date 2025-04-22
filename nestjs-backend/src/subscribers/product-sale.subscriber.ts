import {
  EntitySubscriberInterface,
  EventSubscriber,
  InsertEvent,
  UpdateEvent,
  RemoveEvent,
  DataSource,
} from 'typeorm';
import {
  ProductSale,
  ProductSaleStatus,
} from '../entities/product-sale.entity';
import { Product } from '../entities/product.entity';
import { Injectable } from '@nestjs/common';
import { LessThanOrEqual, MoreThanOrEqual } from 'typeorm';

@Injectable()
@EventSubscriber()
export class ProductSaleSubscriber
  implements EntitySubscriberInterface<ProductSale>
{
  constructor(dataSource: DataSource) {
    dataSource.subscribers.push(this);
  }

  listenTo() {
    return ProductSale;
  }

  private async updateProductPrice(productId: number, dataSource: DataSource) {
    const productRepository = dataSource.getRepository(Product);
    const productSaleRepository = dataSource.getRepository(ProductSale);

    // Tìm sale đang active cho sản phẩm
    const currentDate = new Date();
    const activeSale = await productSaleRepository.findOne({
      where: {
        product_id: productId,
        status: ProductSaleStatus.ACTIVE,
        start_date: LessThanOrEqual(currentDate),
        end_date: MoreThanOrEqual(currentDate),
      },
      order: {
        sale_price: 'ASC', // Lấy giá sale thấp nhất nếu có nhiều
      },
    });

    // Cập nhật giá sản phẩm
    const product = await productRepository.findOne({
      where: { id: productId },
    });

    if (product && activeSale) {
      // Nếu có sale active, cập nhật giá sale
      product.price = activeSale.sale_price.toString();
      await productRepository.save(product);
    }
  }

  async afterInsert(event: InsertEvent<ProductSale>) {
    await this.updateProductPrice(event.entity.product_id, event.connection);
  }

  async afterUpdate(event: UpdateEvent<ProductSale>) {
    if (event.entity) {
      await this.updateProductPrice(event.entity.product_id, event.connection);
    }
  }

  async afterRemove(event: RemoveEvent<ProductSale>) {
    if (event.entity) {
      await this.updateProductPrice(event.entity.product_id, event.connection);
    }
  }
}
