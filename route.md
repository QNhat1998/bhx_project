# 🛍️ Ecommerce API Routes Design

## 1. Categories
| Method | Route | Description |
|:--|:--|:--|
| GET    | `/categories` | Lấy danh sách categories |
| POST   | `/categories` | Thêm mới category |
| GET    | `/categories/:id` | Lấy chi tiết 1 category |
| PUT    | `/categories/:id` | Cập nhật category |
| DELETE | `/categories/:id` | Xóa category |

---

## 2. Subcategories
| Method | Route | Description |
|:--|:--|:--|
| GET    | `/subcategories` | Lấy danh sách subcategories |
| POST   | `/subcategories` | Thêm mới subcategory |
| GET    | `/subcategories/:id` | Lấy chi tiết 1 subcategory |
| PUT    | `/subcategories/:id` | Cập nhật subcategory |
| DELETE | `/subcategories/:id` | Xóa subcategory |

---

## 3. Brands
| Method | Route | Description |
|:--|:--|:--|
| GET    | `/brands` | Lấy danh sách brands |
| POST   | `/brands` | Thêm mới brand |
| GET    | `/brands/:id` | Lấy chi tiết brand |
| PUT    | `/brands/:id` | Cập nhật brand |
| DELETE | `/brands/:id` | Xóa brand |

---

## 4. Products
| Method | Route | Description |
|:--|:--|:--|
| GET    | `/products` | Lấy danh sách sản phẩm |
| POST   | `/products` | Thêm mới sản phẩm |
| GET    | `/products/:id` | Chi tiết sản phẩm |
| PUT    | `/products/:id` | Cập nhật sản phẩm |
| DELETE | `/products/:id` | Xóa sản phẩm |

### Bonus
- GET `/products/:id/comments` → lấy comment sản phẩm
- GET `/products/:id/sale` → lấy thông tin giảm giá

---

## 5. Promotions
| Method | Route | Description |
|:--|:--|:--|
| GET    | `/promotions` | Lấy danh sách khuyến mãi |
| POST   | `/promotions` | Thêm mới khuyến mãi |
| GET    | `/promotions/:id` | Chi tiết khuyến mãi |
| PUT    | `/promotions/:id` | Cập nhật khuyến mãi |
| DELETE | `/promotions/:id` | Xóa khuyến mãi |

---

## 6. Banners
| Method | Route | Description |
|:--|:--|:--|
| GET    | `/banners` | Lấy danh sách banners |
| POST   | `/banners` | Thêm mới banner |
| GET    | `/banners/:id` | Chi tiết banner |
| PUT    | `/banners/:id` | Cập nhật banner |
| DELETE | `/banners/:id` | Xóa banner |

---

## 7. Users & Auth
| Method | Route | Description |
|:--|:--|:--|
| GET    | `/users` | Lấy danh sách users |
| POST   | `/users` | Đăng ký user mới |
| GET    | `/users/:id` | Chi tiết user |
| PUT    | `/users/:id` | Cập nhật user |
| DELETE | `/users/:id` | Xóa user |

### Auth
- POST `/auth/login` → Đăng nhập
- POST `/auth/logout` → Đăng xuất

---

## 8. Orders
| Method | Route | Description |
|:--|:--|:--|
| GET    | `/orders` | Lấy danh sách đơn hàng |
| POST   | `/orders` | Tạo đơn hàng |
| GET    | `/orders/:id` | Chi tiết đơn hàng |
| PUT    | `/orders/:id` | Cập nhật đơn hàng |
| DELETE | `/orders/:id` | Hủy đơn hàng |

### Bonus
- GET `/users/:user_id/orders` → Lịch sử đơn hàng của user

---

## 9. Order Details
| Method | Route | Description |
|:--|:--|:--|
| GET    | `/orders/:order_id/details` | Lấy sản phẩm trong đơn hàng |

---

## 10. Comments
| Method | Route | Description |
|:--|:--|:--|
| POST   | `/products/:product_id/comments` | Thêm bình luận |
| GET    | `/products/:product_id/comments` | Lấy comment |
| DELETE | `/comments/:id` | Xóa comment |

---

## 📢 Home APIs
| API | Ý nghĩa |
|:--|:--|
| GET `/home/banners` | Lấy banner show homepage |
| GET `/home/promotions` | Lấy chương trình khuyến mãi |
| GET `/home/products?limit=10` | Lấy sản phẩm nổi bật |
| GET `/home/categories` | Lấy menu danh mục |

---

# 📦 Summary (API Groups)
| Nhóm | Prefix |
|:--|:--|
| Categories | `/categories` |
| Subcategories | `/subcategories` |
| Brands | `/brands` |
| Products | `/products` |
| Promotions | `/promotions` |
| Banners | `/banners` |
| Users/Auth | `/users`, `/auth` |
| Orders | `/orders` |
| Comments | `/comments` |

