CREATE DATABASE ecommerce_db
USE ecommerce_db

SET GLOBAL event_scheduler = ON;

CREATE TABLE categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE brands (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  url VARCHAR(255) NOT NULL UNIQUE,
  img VARCHAR(255) NOT NULL
);

CREATE TABLE roles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) UNIQUE NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE subcategories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  category_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  img VARCHAR(100) NULL,
  url VARCHAR(100) NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE promotions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    img_path VARCHAR(512) NULL,
    url VARCHAR(255) UNIQUE NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE payment_methods (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL, 
  method_key VARCHAR(50) NOT NULL UNIQUE,
  logo VARCHAR(255) NULL,
  description TEXT NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE banners (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NULL,         -- Tên mô tả (nếu cần)
  image VARCHAR(512) NOT NULL, -- Đường dẫn ảnh banner
  sort_order INT DEFAULT 0,        -- Thứ tự hiển thị (càng nhỏ càng ưu tiên)
  start_date DATETIME NULL,        -- Thời gian bắt đầu hiển thị
  end_date DATETIME NULL,          -- Thời gian kết thúc hiển thị
  status BOOLEAN DEFAULT TRUE      -- Active / Inactive
);

CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  address VARCHAR(500),
  avatar VARCHAR(500),
  role_id INT NOT NULL DEFAULT 1,
--   email_verified BOOLEAN DEFAULT FALSE,
--   phone_verified BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  
  product_name VARCHAR(255) NOT NULL,
  price DECIMAL(14,2) NOT NULL,
  img VARCHAR(255),
  url VARCHAR(255) NOT NULL UNIQUE,
  stock INT DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 0,
  status BOOLEAN DEFAULT TRUE,

  category_id INT NOT NULL,
  subcategory_id INT NOT NULL,

  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
  FOREIGN KEY (subcategory_id) REFERENCES subcategories(id) ON DELETE CASCADE
);

CREATE TABLE product_sales (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  sale_price DECIMAL(14,2) NOT NULL,          
  original_price DECIMAL(14,2) NULL,          
  discount_pct TINYINT UNSIGNED NULL,         
  start_date DATETIME NOT NULL,               
  end_date DATETIME NOT NULL,              
  status ENUM('active', 'scheduled', 'expired') NOT NULL DEFAULT 'scheduled',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_product_sale_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);


CREATE TABLE comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  
  product_id INT NOT NULL,
  customer_name VARCHAR(100) NULL, 
  content TEXT NOT NULL,            
  rating DECIMAL(2,1) NULL,          
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status TINYINT(1) NOT NULL DEFAULT 1, 

  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NULL,
  customer_name VARCHAR(100) NOT NULL,
  customer_phone VARCHAR(20) NOT NULL,
  customer_address VARCHAR(255) NOT NULL,
  total_amount DECIMAL(14,2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending', -- pending, shipped, completed
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE order_details (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  price DECIMAL(14,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,              
  payment_method_id INT NOT NULL,        
  transaction_id VARCHAR(255) NULL,        
  amount DECIMAL(14,2) NOT NULL,           
  status ENUM('pending', 'paid', 'failed', 'cancelled') NOT NULL DEFAULT 'pending',
  paid_at DATETIME NULL,              
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
);

CREATE EVENT IF NOT EXISTS expire_product_sales
ON SCHEDULE EVERY 1 DAY STARTS CURRENT_TIMESTAMP
DO
  UPDATE product_sales
  SET status = 'expired'
  WHERE end_date < NOW() AND status != 'expired';

INSERT INTO roles (id, name) VALUES
(1, 'super_admin'),
(2, 'admin'),
(3, 'staff'),
(4, 'support'),
(5, 'editor'),
(6, 'marketing'),
(7, 'accountant'),
(8, 'vip_customer'),
(9, 'delivery'),
(10, 'merchant'),
(11, 'customer');


INSERT INTO payment_methods (name, method_key, logo, description, active) VALUES
('Thanh toán khi nhận hàng (COD)', 'cod', 'images/payment_methods/cod.png', 'Thanh toán trực tiếp khi giao hàng.', 1),
('Ví điện tử MoMo', 'momo', 'images/payment_methods/momo.png', 'Thanh toán bằng ví MoMo nhanh chóng và tiện lợi.', 1),
('Chuyển khoản ngân hàng', 'bank_transfer', 'images/payment_methods/bank_transfer.png', 'Chuyển khoản trực tiếp đến tài khoản ngân hàng của chúng tôi.', 1),
('Thẻ tín dụng/Ghi nợ (Visa, MasterCard)', 'credit_card', 'images/payment_methods/credit_card.png', 'Thanh toán qua thẻ Visa, MasterCard, JCB nhanh chóng và an toàn.', 1),
('Ví điện tử ZaloPay', 'zalopay', 'images/payment_methods/zalopay.png', 'Thanh toán bằng ví ZaloPay tiện lợi, bảo mật.', 1),
('Ví ShopeePay', 'shopeepay', 'images/payment_methods/shopeepay.png', 'Thanh toán bằng ví ShopeePay, áp dụng nhiều ưu đãi.', 1);


INSERT INTO promotions (title, img_path, url, start_date, end_date, status)
VALUES
('LỄ VÔ LO', 'images/banners/freecompress-hero-banner_202504100951370509.png', 'le-vo-lo', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('OMO', 'images/banners/freecompress-1800x480-2_202504181603149153.jpg', 'omo', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('Sữa Các Loại', 'images/banners/freecompress-hero-banner-pc_202504181036599398.jpg', 'sua-cac-loai', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('SỮA CHUA', 'images/banners/freecompress-1800x480_202504171549381971.png', 'sua-chua', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('LIVESTREAM', 'images/banners/freecompress-1800x480_202502190847402842.jpg', 'livestream', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('TÍCH LŨY FRESH', 'images/banners/freecompress-trang-chu-pc-moi_202504021420028239.png', 'tich-luy-fresh', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('ĐÔNG MÁT', 'images/banners/freecompress-pc-1800x480_202504010845298741.png', 'ong-mat', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('CHỢ ĐÊM', 'images/banners/freecompress-pc-1800x480-2_202503061602312848.jpg', 'cho-em', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('Uni', 'images/banners/freecompress-main_202504191151003763.png', 'uni', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('TÍCH LŨY ULV', 'images/banners/freecompress-1800x480-1_202503312131076341.png', 'tich-luy-ulv', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('GAME VINAMILKv T4', 'images/banners/freecompress-trang-chu-moi-1800x480_202503311028234339.png', 'game-vinamilkv-t4', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('TÍCH LŨY COCA', 'images/banners/freecompress-1800x480px_202504151055301979.jpg', 'tich-luy-coca', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('chợ đêm', 'images/banners/freecompress-trang-cate-pc-2_202503052041090001.jpg', 'cho-em', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('CHẤT LƯỢNG THỊT HEO', 'images/banners/freecompress-trang-cate-pc-1_202503171027529777.jpg', 'chat-luong-thit-heo', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('TRẢ CHẬM', 'images/banners/trang-chu-cate-pc_202502271442362219.jpg', 'tra-cham', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('Trái cây giảm sốc', 'images/banners/trang-cate-pc_202504171334113738.jpg', 'trai-cay-giam-soc', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1),
('CAM SÀNH VẮT NƯỚC', 'images/banners/freecompress-trang-cate-pc_202503260903327417.png', 'cam-sanh-vat-nuoc', '2025-04-20 23:39:23', '2026-04-20 23:39:23', 1);

INSERT INTO brands (name, url, img) VALUES ('Bách hoá XANH', 'brands/bach-hoa-xanh-1504202116252', 'images/brands/bach-hoa-xanh-1504202116252.jpeg');
INSERT INTO brands (name, url, img) VALUES ('Ngọc Tú', 'brands/ngoc-tu-26042024121530', 'images/brands/ngoc-tu-26042024121530.jpg');
INSERT INTO brands (name, url, img) VALUES ('ACE FOODS', 'brands/untitled-1_202502251402390044', 'images/brands/untitled-1_202502251402390044.jpg');
INSERT INTO brands (name, url, img) VALUES ('Gofood', 'brands/kuikiku_202502241610559129', 'images/brands/kuikiku_202502241610559129.jpg');
INSERT INTO brands (name, url, img) VALUES ('Kiwifood', 'brands/gr_202502251528287051', 'images/brands/gr_202502251528287051.jpg');
INSERT INTO brands (name, url, img) VALUES ('MVP', 'brands/mvp-04042021231531', 'images/brands/mvp-04042021231531.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tam Nông', 'brands/tam-nong-2506202415250', 'images/brands/tam-nong-2506202415250.jpg');
INSERT INTO brands (name, url, img) VALUES ('Trần Gia', 'brands/tran-gia-13052021145626', 'images/brands/tran-gia-13052021145626.jpg');
INSERT INTO brands (name, url, img) VALUES ('Meito', 'brands/meito-20122023141013', 'images/brands/meito-20122023141013.jpg');
INSERT INTO brands (name, url, img) VALUES ('Le Mejor', 'brands/thuong-hieu_202411221451522516', 'images/brands/thuong-hieu_202411221451522516.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tiger', 'brands/tiger-05042021152840', 'images/brands/tiger-05042021152840.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sài Gòn', 'brands/sai-gon-05042021222144', 'images/brands/sai-gon-05042021222144.jpg');
INSERT INTO brands (name, url, img) VALUES ('Heineken', 'brands/heineken-260920209475', 'images/brands/heineken-260920209475.png');
INSERT INTO brands (name, url, img) VALUES ('Bia Việt', 'brands/bia-viet-1403202121846', 'images/brands/bia-viet-1403202121846.jpg');
INSERT INTO brands (name, url, img) VALUES ('Budweiser', 'brands/budweiser-19082022225154', 'images/brands/budweiser-19082022225154.jpg');
INSERT INTO brands (name, url, img) VALUES ('333', 'brands/333-2109202085448', 'images/brands/333-2109202085448.png');
INSERT INTO brands (name, url, img) VALUES ('Corona', 'brands/corona-14032021215213', 'images/brands/corona-14032021215213.jpg');
INSERT INTO brands (name, url, img) VALUES ('StrongBow', 'brands/strongbow-0504202111231', 'images/brands/strongbow-0504202111231.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hoegaarden', 'brands/hoegaarden-060420210319', 'images/brands/hoegaarden-060420210319.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ruby', 'brands/ruby-22122021195522', 'images/brands/ruby-22122021195522.jpg');
INSERT INTO brands (name, url, img) VALUES ('Huda', 'brands/huda-060420210132', 'images/brands/huda-060420210132.jpg');
INSERT INTO brands (name, url, img) VALUES ('Larue', 'brands/larue-26092020203821', 'images/brands/larue-26092020203821.png');
INSERT INTO brands (name, url, img) VALUES ('Sapporo', 'brands/sapporo-1810202117451', 'images/brands/sapporo-1810202117451.jpg');
INSERT INTO brands (name, url, img) VALUES ('Kronenbourg 1664 Blanc', 'brands/kronenbourg-1664-blanc-0604202113346', 'images/brands/kronenbourg-1664-blanc-0604202113346.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lạc Việt', 'brands/lac-viet-15042022163641', 'images/brands/lac-viet-15042022163641.png');
INSERT INTO brands (name, url, img) VALUES ('Somersby', 'brands/somersby-0111202211932', 'images/brands/somersby-0111202211932.jpg');
INSERT INTO brands (name, url, img) VALUES ('San Miguel', 'brands/san-miguel-0504202192733', 'images/brands/san-miguel-0504202192733.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tuborg', 'brands/tuborg-13032021145421', 'images/brands/tuborg-13032021145421.jpg');
INSERT INTO brands (name, url, img) VALUES ('Chill', 'brands/chill-20092022105552', 'images/brands/chill-20092022105552.jpg');
INSERT INTO brands (name, url, img) VALUES ('Edelweiss', 'brands/edelweiss-12092022105420', 'images/brands/edelweiss-12092022105420.jpg');
INSERT INTO brands (name, url, img) VALUES ('-196', 'brands/gfd_202409110921032380', 'images/brands/gfd_202409110921032380.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tea Plus', 'brands/frame-2_202504161354106667', 'images/brands/frame-2_202504161354106667.jpg');
INSERT INTO brands (name, url, img) VALUES ('Dr.Thanh', 'brands/drthanh-0504202113325', 'images/brands/drthanh-0504202113325.jpg');
INSERT INTO brands (name, url, img) VALUES ('Không Độ', 'brands/khong-do-0604202113025', 'images/brands/khong-do-0604202113025.jpg');
INSERT INTO brands (name, url, img) VALUES ('C2', 'brands/c2-14032021212318', 'images/brands/c2-14032021212318.jpg');
INSERT INTO brands (name, url, img) VALUES ('Fuze Tea', 'brands/fuze-tea-0504202115310', 'images/brands/fuze-tea-0504202115310.jpg');
INSERT INTO brands (name, url, img) VALUES ('Wonderfarm', 'brands/wonderfarm-05042021173431', 'images/brands/wonderfarm-05042021173431.jpg');
INSERT INTO brands (name, url, img) VALUES ('Cozy', 'brands/cozy-14032021215252', 'images/brands/cozy-14032021215252.jpg');
INSERT INTO brands (name, url, img) VALUES ('Kirin', 'brands/kirin-140320210131', 'images/brands/kirin-140320210131.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tea365', 'brands/tea365-08042024164443', 'images/brands/tea365-08042024164443.jpg');
INSERT INTO brands (name, url, img) VALUES ('Boncha', 'brands/38142-id_202503251036372570', 'images/brands/38142-id_202503251036372570.jpg');
INSERT INTO brands (name, url, img) VALUES ('Coca Cola', 'brands/coca-cola-2309202010534', 'images/brands/coca-cola-2309202010534.png');
INSERT INTO brands (name, url, img) VALUES ('Pepsi', 'brands/pepsi-2307202415540', 'images/brands/pepsi-2307202415540.png');
INSERT INTO brands (name, url, img) VALUES ('Fanta', 'brands/fanta-15032021112040', 'images/brands/fanta-15032021112040.jpg');
INSERT INTO brands (name, url, img) VALUES ('7 Up', 'brands/frame-2_202503121056045336', 'images/brands/frame-2_202503121056045336.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sprite', 'brands/sprite-24092020111818', 'images/brands/sprite-24092020111818.png');
INSERT INTO brands (name, url, img) VALUES ('Schweppes', 'brands/schweppes-0504202194054', 'images/brands/schweppes-0504202194054.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mirinda', 'brands/mirinda_202411270859187901', 'images/brands/mirinda_202411270859187901.jpg');
INSERT INTO brands (name, url, img) VALUES ('Chương Dương', 'brands/chuong-duong-1403202121425', 'images/brands/chuong-duong-1403202121425.jpg');
INSERT INTO brands (name, url, img) VALUES ('Redbull', 'brands/redbull-04042021224712', 'images/brands/redbull-04042021224712.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sting', 'brands/sting-1509202216502', 'images/brands/sting-1509202216502.jpg');
INSERT INTO brands (name, url, img) VALUES ('Warrior', 'brands/warrior-12032021211057', 'images/brands/warrior-12032021211057.jpg');
INSERT INTO brands (name, url, img) VALUES ('Pocari Sweat', 'brands/pocari-sweat-04042021233757', 'images/brands/pocari-sweat-04042021233757.jpg');
INSERT INTO brands (name, url, img) VALUES ('Revive', 'brands/revice_202411270902102658', 'images/brands/revice_202411270902102658.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lipovitan', 'brands/lipovitan-0404202118632', 'images/brands/lipovitan-0404202118632.jpg');
INSERT INTO brands (name, url, img) VALUES ('Monster Energy', 'brands/monster-energy-14032021225816', 'images/brands/monster-energy-14032021225816.jpg');
INSERT INTO brands (name, url, img) VALUES ('Aquarius', 'brands/aquarius-06092021114343', 'images/brands/aquarius-06092021114343.jpg');
INSERT INTO brands (name, url, img) VALUES ('Carabao', 'brands/carabao-1403202121270', 'images/brands/carabao-1403202121270.jpg');
INSERT INTO brands (name, url, img) VALUES ('Rockstar', 'brands/rockstar_202411270906252354', 'images/brands/rockstar_202411270906252354.jpg');
INSERT INTO brands (name, url, img) VALUES ('Rồng Đỏ', 'brands/rong-do-130320211799', 'images/brands/rong-do-130320211799.jpg');
INSERT INTO brands (name, url, img) VALUES ('Number1', 'brands/number1-150320219153', 'images/brands/number1-150320219153.jpg');
INSERT INTO brands (name, url, img) VALUES ('Muaythai', 'brands/muaythai-04042021234145', 'images/brands/muaythai-04042021234145.jpg');
INSERT INTO brands (name, url, img) VALUES ('Thums Up Charged', 'brands/thums-up-1605202394113', 'images/brands/thums-up-1605202394113.jpg');
INSERT INTO brands (name, url, img) VALUES ('Aquafina', 'brands/aquafina-15092022164854', 'images/brands/aquafina-15092022164854.jpg');
INSERT INTO brands (name, url, img) VALUES ('La Vie', 'brands/la-vie-16012023163848', 'images/brands/la-vie-16012023163848.jpg');
INSERT INTO brands (name, url, img) VALUES ('I-on Life', 'brands/i-on-life-0604202101746', 'images/brands/i-on-life-0604202101746.jpg');
INSERT INTO brands (name, url, img) VALUES ('Dasani', 'brands/dasani-0404202118112', 'images/brands/dasani-0404202118112.jpg');
INSERT INTO brands (name, url, img) VALUES ('Vĩnh Hảo', 'brands/vinh-hao-0504202117741', 'images/brands/vinh-hao-0504202117741.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lama', 'brands/lama-03042021111439', 'images/brands/lama-03042021111439.jpeg');
INSERT INTO brands (name, url, img) VALUES ('Vikoda', 'brands/vikoda-11062021154949', 'images/brands/vikoda-11062021154949.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tavi', 'brands/tavi-29062021105025', 'images/brands/tavi-29062021105025.jpg');
INSERT INTO brands (name, url, img) VALUES ('Đảnh Thạnh', 'brands/danh-thanh-07072021154027', 'images/brands/danh-thanh-07072021154027.jpg');
INSERT INTO brands (name, url, img) VALUES ('Jovita', 'brands/jovita-04102021112510', 'images/brands/jovita-04102021112510.jpg');
INSERT INTO brands (name, url, img) VALUES ('Good Mood', 'brands/good-mood-15092022164718', 'images/brands/good-mood-15092022164718.jpg');
INSERT INTO brands (name, url, img) VALUES ('Khánh Hòa', 'brands/khanh-hoa-0604202103456', 'images/brands/khanh-hoa-0604202103456.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sài Gòn Anpha', 'brands/sai-gon-anpha-0504202191210', 'images/brands/sai-gon-anpha-0504202191210.jpg');
INSERT INTO brands (name, url, img) VALUES ('BestNest', 'brands/38769-id_202503251046350283', 'images/brands/38769-id_202503251046350283.jpg');
INSERT INTO brands (name, url, img) VALUES ('Song Yến', 'brands/song-yen-13032021151130', 'images/brands/song-yen-13032021151130.jpg');
INSERT INTO brands (name, url, img) VALUES ('Green Bird', 'brands/green-bird-05042021133923', 'images/brands/green-bird-05042021133923.jpg');
INSERT INTO brands (name, url, img) VALUES ('Win''snest', 'brands/winsnest-05042021173323', 'images/brands/winsnest-05042021173323.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nunest', 'brands/nunest-1503202191439', 'images/brands/nunest-1503202191439.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nest Gold', 'brands/bg_202410281412240955', 'images/brands/bg_202410281412240955.jpg');
INSERT INTO brands (name, url, img) VALUES ('Red Nest', 'brands/red-nest-271020239317', 'images/brands/red-nest-271020239317.jpg');
INSERT INTO brands (name, url, img) VALUES ('Twister', 'brands/twister_202411270859599776', 'images/brands/twister_202411270859599776.jpg');
INSERT INTO brands (name, url, img) VALUES ('Jele X', 'brands/jele-x-11072024144346', 'images/brands/jele-x-11072024144346.jpg');
INSERT INTO brands (name, url, img) VALUES ('Daiya Fancy', 'brands/daiya-fancy-10072024141239', 'images/brands/daiya-fancy-10072024141239.jpg');
INSERT INTO brands (name, url, img) VALUES ('Vinamilk', 'brands/vinamilk-12072023161451', 'images/brands/vinamilk-12072023161451.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ice+', 'brands/ice-060420210170', 'images/brands/ice-060420210170.jpg');
INSERT INTO brands (name, url, img) VALUES ('Juss', 'brands/juss-0604202114949', 'images/brands/juss-0604202114949.jpg');
INSERT INTO brands (name, url, img) VALUES ('Jele', 'brands/jele-0604202103444', 'images/brands/jele-0604202103444.jpg');
INSERT INTO brands (name, url, img) VALUES ('Yeos', 'brands/yeos-05042021174653', 'images/brands/yeos-05042021174653.jpg');
INSERT INTO brands (name, url, img) VALUES ('Teppy', 'brands/teppy-230920209348', 'images/brands/teppy-230920209348.png');
INSERT INTO brands (name, url, img) VALUES ('A1 Food', 'brands/a1-food-2010202162610', 'images/brands/a1-food-2010202162610.jpg');
INSERT INTO brands (name, url, img) VALUES ('Minute Maid', 'brands/minute-maid-1403202122447', 'images/brands/minute-maid-1403202122447.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mogu Mogu', 'brands/mogu-mogu-14032021223718', 'images/brands/mogu-mogu-14032021223718.jpg');
INSERT INTO brands (name, url, img) VALUES ('OKF', 'brands/okf-1503202194124', 'images/brands/okf-1503202194124.jpg');
INSERT INTO brands (name, url, img) VALUES ('Pororo', 'brands/pororo-04042021225855', 'images/brands/pororo-04042021225855.jpg');
INSERT INTO brands (name, url, img) VALUES ('Deedo Fruitku', 'brands/deedo-fruitku-1503202122850', 'images/brands/deedo-fruitku-1503202122850.jpg');
INSERT INTO brands (name, url, img) VALUES ('Malee', 'brands/malee-13032021234455', 'images/brands/malee-13032021234455.jpg');
INSERT INTO brands (name, url, img) VALUES ('Woongjin', 'brands/woongjin-05042021173535', 'images/brands/woongjin-05042021173535.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tipco', 'brands/tipco-05042021153116', 'images/brands/tipco-05042021153116.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nutriboost', 'brands/nutriboost-12032021113715', 'images/brands/nutriboost-12032021113715.jpg');
INSERT INTO brands (name, url, img) VALUES ('YoMost', 'brands/yomost-0504202122036', 'images/brands/yomost-0504202122036.jpg');
INSERT INTO brands (name, url, img) VALUES ('Oggi', 'brands/thiet-ke-chua-co-ten-2025-03-18t101304016_202503181013127329', 'images/brands/thiet-ke-chua-co-ten-2025-03-18t101304016_202503181013127329.jpg');
INSERT INTO brands (name, url, img) VALUES ('Kun', 'brands/23201-id_202501171604047009', 'images/brands/23201-id_202501171604047009.jpg');
INSERT INTO brands (name, url, img) VALUES ('Heejin', 'brands/bgf_202408221544179870', 'images/brands/bgf_202408221544179870.jpg');
INSERT INTO brands (name, url, img) VALUES ('Chumchurum', 'brands/chumchurum-2304202110837', 'images/brands/chumchurum-2304202110837.jpg');
INSERT INTO brands (name, url, img) VALUES ('Jinro', 'brands/jinro-2304202193822', 'images/brands/jinro-2304202193822.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sài Gòn Superior', 'brands/hgf202408271128276744_202409061035579359', 'images/brands/hgf202408271128276744_202409061035579359.jpg');
INSERT INTO brands (name, url, img) VALUES ('Passion', 'brands/passion-2304202114313', 'images/brands/passion-2304202114313.jpg');
INSERT INTO brands (name, url, img) VALUES ('Good Day', 'brands/good-day-03082021132826', 'images/brands/good-day-03082021132826.jpg');
INSERT INTO brands (name, url, img) VALUES ('MG Spirit', 'brands/mg-spirit-19052021152259', 'images/brands/mg-spirit-19052021152259.jpg');
INSERT INTO brands (name, url, img) VALUES ('Korice', 'brands/korice-23042021134911', 'images/brands/korice-23042021134911.jpg');
INSERT INTO brands (name, url, img) VALUES ('Rice+', 'brands/rice-08122023134310', 'images/brands/rice-08122023134310.jpg');
INSERT INTO brands (name, url, img) VALUES ('NesCafé', 'brands/nescafe-14032021235351', 'images/brands/nescafe-14032021235351.jpg');
INSERT INTO brands (name, url, img) VALUES ('VinaCafe', 'brands/vinacafe-13032021142756', 'images/brands/vinacafe-13032021142756.jpg');
INSERT INTO brands (name, url, img) VALUES ('G7', 'brands/g7-05042021145038', 'images/brands/g7-05042021145038.jpg');
INSERT INTO brands (name, url, img) VALUES ('Wake Up', 'brands/wake-up-1503202185914', 'images/brands/wake-up-1503202185914.jpg');
INSERT INTO brands (name, url, img) VALUES ('Trung Nguyên', 'brands/trung-nguyen-0504202116614', 'images/brands/trung-nguyen-0504202116614.jpg');
INSERT INTO brands (name, url, img) VALUES ('MacCoffee', 'brands/maccoffee-13032021225237', 'images/brands/maccoffee-13032021225237.jpg');
INSERT INTO brands (name, url, img) VALUES ('K Coffee', 'brands/k-coffee-k-coffee-26092020155639', 'images/brands/k-coffee-k-coffee-26092020155639.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ông Bầu', 'brands/ong-bau-22032021132457', 'images/brands/ong-bau-22032021132457.jpg');
INSERT INTO brands (name, url, img) VALUES ('Phúc Long', 'brands/phuc-long-1904202411755', 'images/brands/phuc-long-1904202411755.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lipton', 'brands/lipton_202411270903428461', 'images/brands/lipton_202411270903428461.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nestea', 'brands/nestea-14032021235237', 'images/brands/nestea-14032021235237.jpg');
INSERT INTO brands (name, url, img) VALUES ('Blendy', 'brands/blendy-14032021211539', 'images/brands/blendy-14032021211539.jpg');
INSERT INTO brands (name, url, img) VALUES ('Đại Gia', 'brands/dai-gia-0604202195845', 'images/brands/dai-gia-0604202195845.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hillway', 'brands/hillway-060420210026', 'images/brands/hillway-060420210026.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hùng Thái', 'brands/hung-thai-0604202101346', 'images/brands/hung-thai-0604202101346.jpg');
INSERT INTO brands (name, url, img) VALUES ('Bắc Thái', 'brands/bac-thai-040420210294', 'images/brands/bac-thai-040420210294.jpg');
INSERT INTO brands (name, url, img) VALUES ('Cầu Tre', 'brands/cau-tre-14032021212842', 'images/brands/cau-tre-14032021212842.jpg');
INSERT INTO brands (name, url, img) VALUES ('LadoActiso', 'brands/ladoactiso-04042021184213', 'images/brands/ladoactiso-04042021184213.jpg');
INSERT INTO brands (name, url, img) VALUES ('Wangcha', 'brands/wangcha-05042021172431', 'images/brands/wangcha-05042021172431.jpg');
INSERT INTO brands (name, url, img) VALUES ('Wil', 'brands/wil-05042021173222', 'images/brands/wil-05042021173222.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ban Milk Tea', 'brands/ban-milk-tea-22032024133010', 'images/brands/ban-milk-tea-22032024133010.jpg');
INSERT INTO brands (name, url, img) VALUES ('Just Viet', 'brands/just-viet-16012024143246', 'images/brands/just-viet-16012024143246.jpg');
INSERT INTO brands (name, url, img) VALUES ('Deli', 'brands/deli-04042021185252', 'images/brands/deli-04042021185252.jpg');
INSERT INTO brands (name, url, img) VALUES ('Highlands', 'brands/highlands-060420210018', 'images/brands/highlands-060420210018.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mê Trang', 'brands/me-trang-0404202123439', 'images/brands/me-trang-0404202123439.jpg');
INSERT INTO brands (name, url, img) VALUES ('Phương Vy', 'brands/phuong-vy-2509202014570', 'images/brands/phuong-vy-2509202014570.png');
INSERT INTO brands (name, url, img) VALUES ('Boss', 'brands/boss-1503202122656', 'images/brands/boss-1503202122656.jpg');
INSERT INTO brands (name, url, img) VALUES ('TH true MILK', 'brands/th-true-milk-05042021144849', 'images/brands/th-true-milk-05042021144849.jpg');
INSERT INTO brands (name, url, img) VALUES ('Dutch Lady', 'brands/dutch-lady-090320211139', 'images/brands/dutch-lady-090320211139.jpg');
INSERT INTO brands (name, url, img) VALUES ('Dalat Milk', 'brands/dalat-milk-05092023143114', 'images/brands/dalat-milk-05092023143114.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lothamilk', 'brands/lothamilk-0604202110337', 'images/brands/lothamilk-0604202110337.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nutimilk', 'brands/nutimilk-12032021114533', 'images/brands/nutimilk-12032021114533.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nuvi', 'brands/nuvi-1512202183028', 'images/brands/nuvi-1512202183028.jpg');
INSERT INTO brands (name, url, img) VALUES ('Milo', 'brands/milo-0110202091150', 'images/brands/milo-0110202091150.png');
INSERT INTO brands (name, url, img) VALUES ('TH True Chocomalt', 'brands/th-true-chocomalt-28042023133010', 'images/brands/th-true-chocomalt-28042023133010.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ovaltine', 'brands/ovaltine-01102020144338', 'images/brands/ovaltine-01102020144338.png');
INSERT INTO brands (name, url, img) VALUES ('Lof Kun', 'brands/23201-id_202501211317132279', 'images/brands/23201-id_202501211317132279.jpg');
INSERT INTO brands (name, url, img) VALUES ('BFAST', 'brands/bfast-29052021163819', 'images/brands/bfast-29052021163819.jpg');
INSERT INTO brands (name, url, img) VALUES ('LOF', 'brands/33544-id-2_202501171605588063', 'images/brands/33544-id-2_202501171605588063.jpg');
INSERT INTO brands (name, url, img) VALUES ('TH True Yogurt', 'brands/th-true-yogurt-0504202114513', 'images/brands/th-true-yogurt-0504202114513.jpg');
INSERT INTO brands (name, url, img) VALUES ('Fristi', 'brands/fristi-05042021144222', 'images/brands/fristi-05042021144222.jpg');
INSERT INTO brands (name, url, img) VALUES ('SuSu', 'brands/susu-05042021113854', 'images/brands/susu-05042021113854.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nestlé', 'brands/nestle-15032021162752', 'images/brands/nestle-15032021162752.jpg');
INSERT INTO brands (name, url, img) VALUES ('Abbott', 'brands/abbott-2908202293315', 'images/brands/abbott-2908202293315.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ensure', 'brands/ensure-13032023112110', 'images/brands/ensure-13032023112110.png');
INSERT INTO brands (name, url, img) VALUES ('Glucerna', 'brands/glucerna-0511202294659', 'images/brands/glucerna-0511202294659.png');
INSERT INTO brands (name, url, img) VALUES ('NutiFood', 'brands/nutifood-1503202192547', 'images/brands/nutifood-1503202192547.jpg');
INSERT INTO brands (name, url, img) VALUES ('PediaSure', 'brands/pediasure-03082022111344', 'images/brands/pediasure-03082022111344.jpg');
INSERT INTO brands (name, url, img) VALUES ('Fami', 'brands/fami-1503202111205', 'images/brands/fami-1503202111205.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nuti', 'brands/nuti-040420212369', 'images/brands/nuti-040420212369.jpg');
INSERT INTO brands (name, url, img) VALUES ('TH True Oat', 'brands/th-true-oat-25102023131023', 'images/brands/th-true-oat-25102023131023.jpg');
INSERT INTO brands (name, url, img) VALUES ('Việt Ngũ Cốc', 'brands/viet-ngu-coc-05042021164833', 'images/brands/viet-ngu-coc-05042021164833.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ichiban', 'brands/ichiban-0604202191022', 'images/brands/ichiban-0604202191022.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ông Thọ', 'brands/ong-tho-11032021224144', 'images/brands/ong-tho-11032021224144.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ngôi sao Phương Nam', 'brands/ngoi-sao-phuong-nam-08042021125435', 'images/brands/ngoi-sao-phuong-nam-08042021125435.png');
INSERT INTO brands (name, url, img) VALUES ('Hoàn Hảo', 'brands/hoan-hao-060420210153', 'images/brands/hoan-hao-060420210153.jpg');
INSERT INTO brands (name, url, img) VALUES ('Vega', 'brands/vega-3010202114321', 'images/brands/vega-3010202114321.jpg');
INSERT INTO brands (name, url, img) VALUES ('LAMOSA', 'brands/lamosa-22032021152322', 'images/brands/lamosa-22032021152322.jpg');
INSERT INTO brands (name, url, img) VALUES ('Yumfood', 'brands/yumfood-050420212257', 'images/brands/yumfood-050420212257.jpg');
INSERT INTO brands (name, url, img) VALUES ('Calsome', 'brands/calsome-15032021221549', 'images/brands/calsome-15032021221549.jpg');
INSERT INTO brands (name, url, img) VALUES ('MacCereal', 'brands/maccereal-0404202123643', 'images/brands/maccereal-0404202123643.jpg');
INSERT INTO brands (name, url, img) VALUES ('Xuân An', 'brands/xuan-an-05042021173921', 'images/brands/xuan-an-05042021173921.jpg');
INSERT INTO brands (name, url, img) VALUES ('Best Choice', 'brands/best-choice-22092020105712', 'images/brands/best-choice-22092020105712.png');
INSERT INTO brands (name, url, img) VALUES ('Vinh Hiển', 'brands/vinh-hien-21072022145433', 'images/brands/vinh-hien-21072022145433.jpg');
INSERT INTO brands (name, url, img) VALUES ('Vua Gạo', 'brands/vua-gao-05042021172031', 'images/brands/vua-gao-05042021172031.jpg');
INSERT INTO brands (name, url, img) VALUES ('Neptune', 'brands/neptune-1008202213754', 'images/brands/neptune-1008202213754.png');
INSERT INTO brands (name, url, img) VALUES ('A An', 'brands/a-an-04042021182050', 'images/brands/a-an-04042021182050.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ông Cụ', 'brands/22067-id_202503241619322089', 'images/brands/22067-id_202503241619322089.jpg');
INSERT INTO brands (name, url, img) VALUES ('Meizan', 'brands/meizan-06052022115439', 'images/brands/meizan-06052022115439.png');
INSERT INTO brands (name, url, img) VALUES ('Thiên Nhật', 'brands/thien-nhat-10062022104658', 'images/brands/thien-nhat-10062022104658.jpg');
INSERT INTO brands (name, url, img) VALUES ('C.P', 'brands/cp-14032021212030', 'images/brands/cp-14032021212030.jpg');
INSERT INTO brands (name, url, img) VALUES ('Vissan', 'brands/vissan-05042021232643', 'images/brands/vissan-05042021232643.jpg');
INSERT INTO brands (name, url, img) VALUES ('Heo Cao Bồi', 'brands/heo-cao-boi-05042021235847', 'images/brands/heo-cao-boi-05042021235847.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ponnie', 'brands/ponnie-0404202122598', 'images/brands/ponnie-0404202122598.jpg');
INSERT INTO brands (name, url, img) VALUES ('LC FOODS', 'brands/lc-foods-04042021181055', 'images/brands/lc-foods-04042021181055.jpeg');
INSERT INTO brands (name, url, img) VALUES ('3 Cô Gái', 'brands/3-co-gai-14032021193146', 'images/brands/3-co-gai-14032021193146.png');
INSERT INTO brands (name, url, img) VALUES ('Tuna Việt Nam', 'brands/tuna-viet-nam-05042021161239', 'images/brands/tuna-viet-nam-05042021161239.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sea Crown', 'brands/sea-crown-0504202194412', 'images/brands/sea-crown-0504202194412.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lilly', 'brands/lilly-2006202292838', 'images/brands/lilly-2006202292838.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tulip', 'brands/tulip-04042021221611', 'images/brands/tulip-04042021221611.jpg');
INSERT INTO brands (name, url, img) VALUES ('WYN', 'brands/wyn-27112021135628', 'images/brands/wyn-27112021135628.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hạ Long', 'brands/ha-long-060420211547', 'images/brands/ha-long-060420211547.jpg');
INSERT INTO brands (name, url, img) VALUES ('Cây thị', 'brands/cay-thi-04042021183320', 'images/brands/cay-thi-04042021183320.jpg');
INSERT INTO brands (name, url, img) VALUES ('Masan', 'brands/masan-1403202103234', 'images/brands/masan-1403202103234.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hormel Foods', 'brands/hormel-foods-0604202111434', 'images/brands/hormel-foods-0604202111434.jpg');
INSERT INTO brands (name, url, img) VALUES ('Humanwell', 'brands/humanwell-0604202101339', 'images/brands/humanwell-0604202101339.jpg');
INSERT INTO brands (name, url, img) VALUES ('Choi Gang', 'brands/c_202409111055267922', 'images/brands/c_202409111055267922.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sea -Việt', 'brands/sea-viet_202412031322008605', 'images/brands/sea-viet_202412031322008605.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tao Kae Noi', 'brands/tao-kae-noi-05042021143111', 'images/brands/tao-kae-noi-05042021143111.jpg');
INSERT INTO brands (name, url, img) VALUES ('Green World', 'brands/green-world-25092020114713', 'images/brands/green-world-25092020114713.png');
INSERT INTO brands (name, url, img) VALUES ('Miwon', 'brands/miwon-14032021224227', 'images/brands/miwon-14032021224227.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ock Dong Ja', 'brands/ock-dong-ja-1503202193042', 'images/brands/ock-dong-ja-1503202193042.jpg');
INSERT INTO brands (name, url, img) VALUES ('Bibigo', 'brands/bibigo-1703202217552', 'images/brands/bibigo-1703202217552.png');
INSERT INTO brands (name, url, img) VALUES ('O''food', 'brands/ofood-08042021124923', 'images/brands/ofood-08042021124923.png');
INSERT INTO brands (name, url, img) VALUES ('Top Food', 'brands/top-food-14072021141733', 'images/brands/top-food-14072021141733.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ottogi', 'brands/ottogi-1503202110581', 'images/brands/ottogi-1503202110581.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tohogenkai', 'brands/tohogenkai-1512202113379', 'images/brands/tohogenkai-1512202113379.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tasami', 'brands/tasami-1711202183420', 'images/brands/tasami-1711202183420.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hương Vị', 'brands/huong-vi-19072024155554', 'images/brands/huong-vi-19072024155554.jpg');
INSERT INTO brands (name, url, img) VALUES ('An Nhiên', 'brands/an-nhien-14032021202239', 'images/brands/an-nhien-14032021202239.jpg');
INSERT INTO brands (name, url, img) VALUES ('Vietfresh', 'brands/vietfresh-05042021165140', 'images/brands/vietfresh-05042021165140.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nguyên Bảo', 'brands/nguyen-bao-200420219925', 'images/brands/nguyen-bao-200420219925.jpeg');
INSERT INTO brands (name, url, img) VALUES ('Tường An', 'brands/tuong-an-0504202116136', 'images/brands/tuong-an-0504202116136.jpg');
INSERT INTO brands (name, url, img) VALUES ('Simply', 'brands/simply-06052022122049', 'images/brands/simply-06052022122049.png');
INSERT INTO brands (name, url, img) VALUES ('Cái Lân', 'brands/cai-lan-22062022115940', 'images/brands/cai-lan-22062022115940.png');
INSERT INTO brands (name, url, img) VALUES ('Nakydaco', 'brands/nakydaco-1503202116401', 'images/brands/nakydaco-1503202116401.jpg');
INSERT INTO brands (name, url, img) VALUES ('Bếp Hồng', 'brands/38259-id_202503251101384190', 'images/brands/38259-id_202503251101384190.jpg');
INSERT INTO brands (name, url, img) VALUES ('Olivoilà', 'brands/olivoila-06052022121541', 'images/brands/olivoila-06052022121541.png');
INSERT INTO brands (name, url, img) VALUES ('Happi Koki', 'brands/happi-koki-0504202123508', 'images/brands/happi-koki-0504202123508.jpg');
INSERT INTO brands (name, url, img) VALUES ('Happi Soya', 'brands/happi-soya-05042021235016', 'images/brands/happi-soya-05042021235016.jpg');
INSERT INTO brands (name, url, img) VALUES ('Orchid', 'brands/orchid-08042021124317', 'images/brands/orchid-08042021124317.png');
INSERT INTO brands (name, url, img) VALUES ('Good Meall', 'brands/good-meall-05042021133022', 'images/brands/good-meall-05042021133022.jpg');
INSERT INTO brands (name, url, img) VALUES ('Janbee', 'brands/janbee-0604202102316', 'images/brands/janbee-0604202102316.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nam Ngư', 'brands/nam-ngu-2210202213309', 'images/brands/nam-ngu-2210202213309.png');
INSERT INTO brands (name, url, img) VALUES ('Chinsu', 'brands/chinsu-05042021145058', 'images/brands/chinsu-05042021145058.jpeg');
INSERT INTO brands (name, url, img) VALUES ('Knorr', 'brands/knorr-29092020133434', 'images/brands/knorr-29092020133434.png');
INSERT INTO brands (name, url, img) VALUES ('Thanh Quốc', 'brands/38875-id_202503251105126561', 'images/brands/38875-id_202503251105126561.jpg');
INSERT INTO brands (name, url, img) VALUES ('Liên Thành', 'brands/lien-thanh-1403202122184', 'images/brands/lien-thanh-1403202122184.jpg');
INSERT INTO brands (name, url, img) VALUES ('584 Nha Trang', 'brands/584-nha-trang-30082022154655', 'images/brands/584-nha-trang-30082022154655.png');
INSERT INTO brands (name, url, img) VALUES ('Hạnh Phúc', 'brands/hanh-phuc-16082022132524', 'images/brands/hanh-phuc-16082022132524.png');
INSERT INTO brands (name, url, img) VALUES ('Ông Tây', 'brands/ong-tay-26062021125328', 'images/brands/ong-tay-26062021125328.jpeg');
INSERT INTO brands (name, url, img) VALUES ('Hưng Thịnh', 'brands/hung-thinh-0604202101634', 'images/brands/hung-thinh-0604202101634.jpg');
INSERT INTO brands (name, url, img) VALUES ('Thuận Phát', 'brands/thuan-phat-0504202115192', 'images/brands/thuan-phat-0504202115192.jpg');
INSERT INTO brands (name, url, img) VALUES ('3 Miền', 'brands/3-mien-03042021234218', 'images/brands/3-mien-03042021234218.jpg');
INSERT INTO brands (name, url, img) VALUES ('Barona', 'brands/barona-14032021205921', 'images/brands/barona-14032021205921.jpg');
INSERT INTO brands (name, url, img) VALUES ('Việt Nhĩ', 'brands/viet-nhi-0504202116492', 'images/brands/viet-nhi-0504202116492.jpg');
INSERT INTO brands (name, url, img) VALUES ('Đầu Bếp', 'brands/dau-bep-0404202118455', 'images/brands/dau-bep-0404202118455.jpg');
INSERT INTO brands (name, url, img) VALUES ('Cholimex', 'brands/cholimex-04042021165746', 'images/brands/cholimex-04042021165746.jpg');
INSERT INTO brands (name, url, img) VALUES ('Đầu Bếp Tôm', 'brands/dau-bep-tom-16082022133135', 'images/brands/dau-bep-tom-16082022133135.png');
INSERT INTO brands (name, url, img) VALUES ('Tam Thái Tử', 'brands/tam-thai-tu-0504202122394', 'images/brands/tam-thai-tu-0504202122394.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nam Dương', 'brands/nam-duong-24102022144818', 'images/brands/nam-duong-24102022144818.png');
INSERT INTO brands (name, url, img) VALUES ('Maggi', 'brands/maggi-01112020194450', 'images/brands/maggi-01112020194450.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hương Việt', 'brands/huong-viet-060420210211', 'images/brands/huong-viet-060420210211.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hàng Việt', 'brands/hang-viet-07072022171021', 'images/brands/hang-viet-07072022171021.png');
INSERT INTO brands (name, url, img) VALUES ('Phú Sĩ', 'brands/phu-si-15032021115534', 'images/brands/phu-si-15032021115534.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ông Chà Và', 'brands/ong-cha-va-1503202195926', 'images/brands/ong-cha-va-1503202195926.jpg');
INSERT INTO brands (name, url, img) VALUES ('Aji-ngon', 'brands/aji-ngon-1609202112819', 'images/brands/aji-ngon-1609202112819.jpeg');
INSERT INTO brands (name, url, img) VALUES ('Vedan', 'brands/vedan-05042021163045', 'images/brands/vedan-05042021163045.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ajinomoto', 'brands/ajinomoto-03042021235634', 'images/brands/ajinomoto-03042021235634.jpg');
INSERT INTO brands (name, url, img) VALUES ('Delly Cook', 'brands/delly-cook-07072021155838', 'images/brands/delly-cook-07072021155838.jpeg');
INSERT INTO brands (name, url, img) VALUES ('ViFon', 'brands/vifon-05042021165510', 'images/brands/vifon-05042021165510.jpg');
INSERT INTO brands (name, url, img) VALUES ('Natafoods', 'brands/natafoods-28052021144845', 'images/brands/natafoods-28052021144845.jpeg');
INSERT INTO brands (name, url, img) VALUES ('Yess', 'brands/yess-05042021175120', 'images/brands/yess-05042021175120.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tài Lộc', 'brands/tai-loc-06042021102857', 'images/brands/tai-loc-06042021102857.jpg');
INSERT INTO brands (name, url, img) VALUES ('Golden Farm', 'brands/golden-farm-0504202113239', 'images/brands/golden-farm-0504202113239.jpg');
INSERT INTO brands (name, url, img) VALUES ('Kewpie', 'brands/kewpie-0604202102411', 'images/brands/kewpie-0604202102411.jpg');
INSERT INTO brands (name, url, img) VALUES ('Heinz', 'brands/heinz-0504202123586', 'images/brands/heinz-0504202123586.jpg');
INSERT INTO brands (name, url, img) VALUES ('Fadely', 'brands/fadely-05042021141531', 'images/brands/fadely-05042021141531.jpg');
INSERT INTO brands (name, url, img) VALUES ('Aji-Quick', 'brands/aji-quick-14032021201614', 'images/brands/aji-quick-14032021201614.jpg');
INSERT INTO brands (name, url, img) VALUES ('Vianco', 'brands/vianco-05042021231942', 'images/brands/vianco-05042021231942.jpg');
INSERT INTO brands (name, url, img) VALUES ('SG Food', 'brands/sg-food-05042021222518', 'images/brands/sg-food-05042021222518.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lee Kum Kee', 'brands/lee-kum-kee-0404202118204', 'images/brands/lee-kum-kee-0404202118204.jpg');
INSERT INTO brands (name, url, img) VALUES ('Dh Foods', 'brands/dh-foods-06042021102352', 'images/brands/dh-foods-06042021102352.jpg');
INSERT INTO brands (name, url, img) VALUES ('Thiên Thành', 'brands/thien-thanh-05042021151458', 'images/brands/thien-thanh-05042021151458.jpg');
INSERT INTO brands (name, url, img) VALUES ('Beksul', 'brands/beksul-1403202121529', 'images/brands/beksul-1403202121529.jpg');
INSERT INTO brands (name, url, img) VALUES ('A Tuấn Khang', 'brands/a-tuan-khang-0304202123444', 'images/brands/a-tuan-khang-0304202123444.jpg');
INSERT INTO brands (name, url, img) VALUES ('Vipep', 'brands/vipep-05042021171036', 'images/brands/vipep-05042021171036.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sông Hương', 'brands/song-huong-05042021102238', 'images/brands/song-huong-05042021102238.jpg');
INSERT INTO brands (name, url, img) VALUES ('Phạm Tân', 'brands/pham-tan-04042021231637', 'images/brands/pham-tan-04042021231637.jpg');
INSERT INTO brands (name, url, img) VALUES ('Merino', 'brands/merino-14032021222933', 'images/brands/merino-14032021222933.jpg');
INSERT INTO brands (name, url, img) VALUES ('Celano', 'brands/celano-14032021213226', 'images/brands/celano-14032021213226.jpg');
INSERT INTO brands (name, url, img) VALUES ('Wall''s', 'brands/walls-05042021232938', 'images/brands/walls-05042021232938.jpg');
INSERT INTO brands (name, url, img) VALUES ('Magnum', 'brands/frame-2_202504011359332010', 'images/brands/frame-2_202504011359332010.jpg');
INSERT INTO brands (name, url, img) VALUES ('Cornetto', 'brands/cornnetto-06102021144220', 'images/brands/cornnetto-06102021144220.jpeg');
INSERT INTO brands (name, url, img) VALUES ('Iberri', 'brands/iberri-2912202212560', 'images/brands/iberri-2912202212560.png');
INSERT INTO brands (name, url, img) VALUES ('Magnolia', 'brands/magnolia-0504202210380', 'images/brands/magnolia-0504202210380.jpg');
INSERT INTO brands (name, url, img) VALUES ('Melona', 'brands/melona-04092021171834', 'images/brands/melona-04092021171834.jpg');
INSERT INTO brands (name, url, img) VALUES ('Binggrae', 'brands/binggrae-04042021164350', 'images/brands/binggrae-04042021164350.jpg');
INSERT INTO brands (name, url, img) VALUES ('TH True Ice Cream', 'brands/th-true-ice-cream-06052024105927', 'images/brands/th-true-ice-cream-06052024105927.jpg');
INSERT INTO brands (name, url, img) VALUES ('Joyday', 'brands/joyday-27062024151949', 'images/brands/joyday-27062024151949.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hùng Linh', 'brands/hung-linh-15072024112828', 'images/brands/hung-linh-15072024112828.jpg');
INSERT INTO brands (name, url, img) VALUES ('Monte', 'brands/monte-14032021225748', 'images/brands/monte-14032021225748.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hoff', 'brands/hoff-060420210328', 'images/brands/hoff-060420210328.jpg');
INSERT INTO brands (name, url, img) VALUES ('Gotz', 'brands/gotz-05042021154141', 'images/brands/gotz-05042021154141.jpg');
INSERT INTO brands (name, url, img) VALUES ('SG Milk', 'brands/sg-milk-1405202113358', 'images/brands/sg-milk-1405202113358.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sài Gòn Milk', 'brands/sai-gon-milk-06032021163940', 'images/brands/sai-gon-milk-06032021163940.jpg');
INSERT INTO brands (name, url, img) VALUES ('DeliFres+', 'brands/39210-id_202503251124317724', 'images/brands/39210-id_202503251124317724.png');
INSERT INTO brands (name, url, img) VALUES ('Yakult', 'brands/yakult-05042021174245', 'images/brands/yakult-05042021174245.jpg');
INSERT INTO brands (name, url, img) VALUES ('Betagen', 'brands/betagen-140320212174', 'images/brands/betagen-140320212174.jpg');
INSERT INTO brands (name, url, img) VALUES ('Con Bò Cười', 'brands/con-bo-cuoi-14032021214854', 'images/brands/con-bo-cuoi-14032021214854.jpg');
INSERT INTO brands (name, url, img) VALUES ('Zott', 'brands/zott-05042021221435', 'images/brands/zott-05042021221435.jpg');
INSERT INTO brands (name, url, img) VALUES ('Paysan Breton', 'brands/paysan-breton-0404202123222', 'images/brands/paysan-breton-0404202123222.jpg');
INSERT INTO brands (name, url, img) VALUES ('Bottega Zelachi', 'brands/bottega-zelachi-0608202117426', 'images/brands/bottega-zelachi-0608202117426.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nguyễn Hồng', 'brands/nguyen-hong-27032023144114', 'images/brands/nguyen-hong-27032023144114.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ánh Hồng', 'brands/anh-hong-1403202120279', 'images/brands/anh-hong-1403202120279.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sunny', 'brands/sunny-060320210633', 'images/brands/sunny-060320210633.jpg');
INSERT INTO brands (name, url, img) VALUES ('Yessy', 'brands/yessy-07072021154249', 'images/brands/yessy-07072021154249.jpg');
INSERT INTO brands (name, url, img) VALUES ('La Cusina', 'brands/la-cusina-0604202183255', 'images/brands/la-cusina-0604202183255.jpeg');
INSERT INTO brands (name, url, img) VALUES ('M.Ngon', 'brands/mngon-13032021225918', 'images/brands/mngon-13032021225918.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hoa Doanh', 'brands/hoa-doanh-060420210130', 'images/brands/hoa-doanh-060420210130.jpg');
INSERT INTO brands (name, url, img) VALUES ('Thọ Phát', 'brands/tho-phat-04042021165042', 'images/brands/tho-phat-04042021165042.jpg');
INSERT INTO brands (name, url, img) VALUES ('Manna', 'brands/manna-04042021234044', 'images/brands/manna-04042021234044.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hoàng Phát', 'brands/hoang-phat-2412202111528', 'images/brands/hoang-phat-2412202111528.jpg');
INSERT INTO brands (name, url, img) VALUES ('HT Food', 'brands/ht-food-0604202101147', 'images/brands/ht-food-0604202101147.jpg');
INSERT INTO brands (name, url, img) VALUES ('KCook', 'brands/kcook-1108202392230', 'images/brands/kcook-1108202392230.jpg');
INSERT INTO brands (name, url, img) VALUES ('Kitkool', 'brands/kitkool-14082023144843', 'images/brands/kitkool-14082023144843.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hetori', 'brands/hetori-2604202410213', 'images/brands/hetori-2604202410213.jpg');
INSERT INTO brands (name, url, img) VALUES ('Le Gourmet', 'brands/le-gourmet-0404202118477', 'images/brands/le-gourmet-0404202118477.jpg');
INSERT INTO brands (name, url, img) VALUES ('G Kitchen', 'brands/g-kitchen-05042021144250', 'images/brands/g-kitchen-05042021144250.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tiến Tấn Đạt', 'brands/tien-tan-dat-05042021152558', 'images/brands/tien-tan-dat-05042021152558.jpg');
INSERT INTO brands (name, url, img) VALUES ('MEATDeli', 'brands/meatdeli-17012024151546', 'images/brands/meatdeli-17012024151546.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tân Hải Hòa', 'brands/tan-hai-hoa-1503202191012', 'images/brands/tan-hai-hoa-1503202191012.jpg');
INSERT INTO brands (name, url, img) VALUES ('3N Foods', 'brands/3n-foods-03042021234316', 'images/brands/3n-foods-03042021234316.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mr.T', 'brands/mrt-12042022144812', 'images/brands/mrt-12042022144812.jpg');
INSERT INTO brands (name, url, img) VALUES ('Orifood', 'brands/orifood-0404202118546', 'images/brands/orifood-0404202118546.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nhật Minh', 'brands/nhat-minh-05062021155158', 'images/brands/nhat-minh-05062021155158.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lam Điền', 'brands/thuong-hieu_202410031200134532', 'images/brands/thuong-hieu_202410031200134532.jpg');
INSERT INTO brands (name, url, img) VALUES ('Bà Bảy', 'brands/ba-bay-06032021174911', 'images/brands/ba-bay-06032021174911.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nuffam', 'brands/nuffam-27052024102527', 'images/brands/nuffam-27052024102527.jpg');
INSERT INTO brands (name, url, img) VALUES ('Jimmy', 'brands/jimmy-0604202103623', 'images/brands/jimmy-0604202103623.jpg');
INSERT INTO brands (name, url, img) VALUES ('Dalat Vinfarm', 'brands/dalat-vinfarm-2503202410151', 'images/brands/dalat-vinfarm-2503202410151.jpg');
INSERT INTO brands (name, url, img) VALUES ('Safoco', 'brands/safoco-050420219920', 'images/brands/safoco-050420219920.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lotus', 'brands/lotus-0404202123102', 'images/brands/lotus-0404202123102.jpg');
INSERT INTO brands (name, url, img) VALUES ('Minh Hảo', 'brands/minh-hao-1005202395321', 'images/brands/minh-hao-1005202395321.jpg');
INSERT INTO brands (name, url, img) VALUES ('Susan', 'brands/susan-27112021144458', 'images/brands/susan-27112021144458.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ngọc Liên', 'brands/ngoc-lien-19072023104341', 'images/brands/ngoc-lien-19072023104341.png');
INSERT INTO brands (name, url, img) VALUES ('Tre Xanh', 'brands/tre-xanh-05042021154853', 'images/brands/tre-xanh-05042021154853.jpg');
INSERT INTO brands (name, url, img) VALUES ('Vĩ Lâm', 'brands/vi-lam-05042021163450', 'images/brands/vi-lam-05042021163450.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mama', 'brands/mama-08042021125013', 'images/brands/mama-08042021125013.png');
INSERT INTO brands (name, url, img) VALUES ('Việt Hàn', 'brands/viet-han-05042021232312', 'images/brands/viet-han-05042021232312.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mr.Lee', 'brands/mrlee-0404202123155', 'images/brands/mrlee-0404202123155.jpg');
INSERT INTO brands (name, url, img) VALUES ('Phú An Khang', 'brands/thuong-hieu_202409271452282290', 'images/brands/thuong-hieu_202409271452282290.jpg');
INSERT INTO brands (name, url, img) VALUES ('Danisa', 'brands/danisa-1403202122230', 'images/brands/danisa-1403202122230.jpg');
INSERT INTO brands (name, url, img) VALUES ('Cosy', 'brands/cosy-14032021215238', 'images/brands/cosy-14032021215238.jpg');
INSERT INTO brands (name, url, img) VALUES ('Kokola', 'brands/kokola-31102020165027', 'images/brands/kokola-31102020165027.jpg');
INSERT INTO brands (name, url, img) VALUES ('O&T', 'brands/o-t-1503202193130', 'images/brands/o-t-1503202193130.jpg');
INSERT INTO brands (name, url, img) VALUES ('Oreo', 'brands/oreo-150320211075', 'images/brands/oreo-150320211075.jpg');
INSERT INTO brands (name, url, img) VALUES ('Imperial', 'brands/imperial-0604202101155', 'images/brands/imperial-0604202101155.jpg');
INSERT INTO brands (name, url, img) VALUES ('Meiji', 'brands/meiji-04042021231050', 'images/brands/meiji-04042021231050.jpg');
INSERT INTO brands (name, url, img) VALUES ('Gouté', 'brands/goute-05042021133214', 'images/brands/goute-05042021133214.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lu', 'brands/lu-0404202123754', 'images/brands/lu-0404202123754.jpg');
INSERT INTO brands (name, url, img) VALUES ('Cream-O', 'brands/cream-o-0404202117226', 'images/brands/cream-o-0404202117226.jpg');
INSERT INTO brands (name, url, img) VALUES ('Orion', 'brands/orion-15032021103148', 'images/brands/orion-15032021103148.jpg');
INSERT INTO brands (name, url, img) VALUES ('AFC', 'brands/afc-03042021235546', 'images/brands/afc-03042021235546.jpg');
INSERT INTO brands (name, url, img) VALUES ('Gery', 'brands/gery-05042021145243', 'images/brands/gery-05042021145243.jpg');
INSERT INTO brands (name, url, img) VALUES ('Goody Chips', 'brands/goody-chips-05042021133138', 'images/brands/goody-chips-05042021133138.jpg');
INSERT INTO brands (name, url, img) VALUES ('Coffee Joy', 'brands/coffee-joy-0404202117042', 'images/brands/coffee-joy-0404202117042.jpg');
INSERT INTO brands (name, url, img) VALUES ('Bibica', 'brands/bibica-04042021182741', 'images/brands/bibica-04042021182741.jpg');
INSERT INTO brands (name, url, img) VALUES ('Magic', 'brands/magic-13032021235547', 'images/brands/magic-13032021235547.jpg');
INSERT INTO brands (name, url, img) VALUES ('Libra', 'brands/libra-29062021101630', 'images/brands/libra-29062021101630.jpg');
INSERT INTO brands (name, url, img) VALUES ('TOK', 'brands/tok-09062021103357', 'images/brands/tok-09062021103357.jpg');
INSERT INTO brands (name, url, img) VALUES ('Tipo', 'brands/tipo-0504202115320', 'images/brands/tipo-0504202115320.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ritz', 'brands/ritz-1303202118058', 'images/brands/ritz-1303202118058.jpg');
INSERT INTO brands (name, url, img) VALUES ('Richy', 'brands/richy-13032021173238', 'images/brands/richy-13032021173238.jpg');
INSERT INTO brands (name, url, img) VALUES ('Munchy''s', 'brands/munchys-1403202123758', 'images/brands/munchys-1403202123758.jpg');
INSERT INTO brands (name, url, img) VALUES ('Parle Platina Hide & Seek', 'brands/parle-platina-hide-seek-29032024142248', 'images/brands/parle-platina-hide-seek-29032024142248.jpg');
INSERT INTO brands (name, url, img) VALUES ('Roma', 'brands/roma-1303202117838', 'images/brands/roma-1303202117838.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lotte', 'brands/lotte-13032021183010', 'images/brands/lotte-13032021183010.jpg');
INSERT INTO brands (name, url, img) VALUES ('Franzzi', 'brands/franzzi-20122021123845', 'images/brands/franzzi-20122021123845.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lexus', 'brands/lexus-09062023155210', 'images/brands/lexus-09062023155210.jpg');
INSERT INTO brands (name, url, img) VALUES ('One One', 'brands/one-one-1503202110020', 'images/brands/one-one-1503202110020.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ichi', 'brands/ichi-0604202102124', 'images/brands/ichi-0604202102124.jpg');
INSERT INTO brands (name, url, img) VALUES ('YappySenbei', 'brands/yappysenbei-05042021233328', 'images/brands/yappysenbei-05042021233328.jpg');
INSERT INTO brands (name, url, img) VALUES ('Want Want', 'brands/want-want-12032021211121', 'images/brands/want-want-12032021211121.jpg');
INSERT INTO brands (name, url, img) VALUES ('Rice Fruit', 'brands/rice-fruit-20122021114258', 'images/brands/rice-fruit-20122021114258.png');
INSERT INTO brands (name, url, img) VALUES ('Rice Crispy', 'brands/rice-crispy-20122021113627', 'images/brands/rice-crispy-20122021113627.png');
INSERT INTO brands (name, url, img) VALUES ('Play Nutrition', 'brands/play-nutrition-091020239242', 'images/brands/play-nutrition-091020239242.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sunrise', 'brands/sunrise-05042021112853', 'images/brands/sunrise-05042021112853.jpg');
INSERT INTO brands (name, url, img) VALUES ('Vitapro', 'brands/vitapro-05042021232826', 'images/brands/vitapro-05042021232826.jpg');
INSERT INTO brands (name, url, img) VALUES ('Oishi', 'brands/oishi-1503202194253', 'images/brands/oishi-1503202194253.jpg');
INSERT INTO brands (name, url, img) VALUES ('Poca', 'brands/poca-130620231369', 'images/brands/poca-130620231369.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lay''s Stax', 'brands/lays-stax-06032023171014', 'images/brands/lays-stax-06032023171014.png');
INSERT INTO brands (name, url, img) VALUES ('Kinh Đô', 'brands/kinh-do-14112023105536', 'images/brands/kinh-do-14112023105536.jpg');
INSERT INTO brands (name, url, img) VALUES ('Slide', 'brands/slide-05042021101452', 'images/brands/slide-05042021101452.jpg');
INSERT INTO brands (name, url, img) VALUES ('O''Star', 'brands/ostar-1503202193148', 'images/brands/ostar-1503202193148.jpg');
INSERT INTO brands (name, url, img) VALUES ('Swing', 'brands/swing-0504202111518', 'images/brands/swing-0504202111518.jpg');
INSERT INTO brands (name, url, img) VALUES ('Enaak', 'brands/enaak-0504202114223', 'images/brands/enaak-0504202114223.jpg');
INSERT INTO brands (name, url, img) VALUES ('Kimmy', 'brands/kimmy-0608202193359', 'images/brands/kimmy-0608202193359.jpg');
INSERT INTO brands (name, url, img) VALUES ('Bento', 'brands/bento-0404202102757', 'images/brands/bento-0404202102757.jpg');
INSERT INTO brands (name, url, img) VALUES ('Talaethong', 'brands/talaethong-04062022141211', 'images/brands/talaethong-04062022141211.jpg');
INSERT INTO brands (name, url, img) VALUES ('Toonies', 'brands/toonies-05042021153824', 'images/brands/toonies-05042021153824.jpg');
INSERT INTO brands (name, url, img) VALUES ('Puff Corn', 'brands/puff-corn-04042021233824', 'images/brands/puff-corn-04042021233824.jpg');
INSERT INTO brands (name, url, img) VALUES ('Gokochi', 'brands/gokochi-250320229114', 'images/brands/gokochi-250320229114.jpg');
INSERT INTO brands (name, url, img) VALUES ('TaYo', 'brands/tayo-05042021143523', 'images/brands/tayo-05042021143523.jpg');
INSERT INTO brands (name, url, img) VALUES ('Corn Chip', 'brands/corn-chip-14032021215142', 'images/brands/corn-chip-14032021215142.jpg');
INSERT INTO brands (name, url, img) VALUES ('Koikeya', 'brands/anh-thuong-hieu-1_202504101022145246', 'images/brands/anh-thuong-hieu-1_202504101022145246.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mplus', 'brands/mplus-030720241148', 'images/brands/mplus-030720241148.jpg');
INSERT INTO brands (name, url, img) VALUES ('Genkai', 'brands/genkai-15122021133612', 'images/brands/genkai-15122021133612.jpg');
INSERT INTO brands (name, url, img) VALUES ('Seleco', 'brands/seleco-050420219569', 'images/brands/seleco-050420219569.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lotte Xylitol', 'brands/lotte-xylitol-0404202123109', 'images/brands/lotte-xylitol-0404202123109.jpg');
INSERT INTO brands (name, url, img) VALUES ('Cool Air', 'brands/cool-air-14032021215123', 'images/brands/cool-air-14032021215123.jpg');
INSERT INTO brands (name, url, img) VALUES ('DoubleMint', 'brands/doublemint-1503202195857', 'images/brands/doublemint-1503202195857.jpg');
INSERT INTO brands (name, url, img) VALUES ('Happydent', 'brands/happydent-13032021224155', 'images/brands/happydent-13032021224155.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mentos', 'brands/mentos-14032021221017', 'images/brands/mentos-14032021221017.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hubba Bubba', 'brands/hubba-bubba-1305202115429', 'images/brands/hubba-bubba-1305202115429.png');
INSERT INTO brands (name, url, img) VALUES ('Chupa Chups', 'brands/chupa-chups-1503202122165', 'images/brands/chupa-chups-1503202122165.jpg');
INSERT INTO brands (name, url, img) VALUES ('Đức Hạnh', 'brands/duc-hanh-05092023134348', 'images/brands/duc-hanh-05092023134348.jpg');
INSERT INTO brands (name, url, img) VALUES ('Snickers', 'brands/snickers-06032021204839', 'images/brands/snickers-06032021204839.jpg');
INSERT INTO brands (name, url, img) VALUES ('M&M''s', 'brands/m-ms-13032021225444', 'images/brands/m-ms-13032021225444.jpg');
INSERT INTO brands (name, url, img) VALUES ('Kinder Joy', 'brands/kinder-joy-060420210486', 'images/brands/kinder-joy-060420210486.jpg');
INSERT INTO brands (name, url, img) VALUES ('Play More', 'brands/play-more-04042021225940', 'images/brands/play-more-04042021225940.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lacasitos', 'brands/lacasitos-1511202385854', 'images/brands/lacasitos-1511202385854.jpg');
INSERT INTO brands (name, url, img) VALUES ('Wolfoo', 'brands/anh-thuong-hieu_202409100927039935', 'images/brands/anh-thuong-hieu_202409100927039935.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ba bông sen', 'brands/ba-bong-sen-04042021185053', 'images/brands/ba-bong-sen-04042021185053.jpg');
INSERT INTO brands (name, url, img) VALUES ('FnV', 'brands/fnv-1701202282932', 'images/brands/fnv-1701202282932.jpg');
INSERT INTO brands (name, url, img) VALUES ('Oh Smile Nuts', 'brands/oh-smile-nuts-2112202123857', 'images/brands/oh-smile-nuts-2112202123857.jpg');
INSERT INTO brands (name, url, img) VALUES ('Minh Châu', 'brands/minh-chau-09072024132638', 'images/brands/minh-chau-09072024132638.jpg');
INSERT INTO brands (name, url, img) VALUES ('Kodochi', 'brands/frame-3475210_202411251029110520', 'images/brands/frame-3475210_202411251029110520.jpg');
INSERT INTO brands (name, url, img) VALUES ('C B', 'brands/c-b-14032021212024', 'images/brands/c-b-14032021212024.jpg');
INSERT INTO brands (name, url, img) VALUES ('Pichi', 'brands/pichi-14042023205542', 'images/brands/pichi-14042023205542.jpg');
INSERT INTO brands (name, url, img) VALUES ('Chef Biggy', 'brands/chef-biggy-23062023103246', 'images/brands/chef-biggy-23062023103246.jpg');
INSERT INTO brands (name, url, img) VALUES ('Posi', 'brands/posi-26042024113619', 'images/brands/posi-26042024113619.jpg');
INSERT INTO brands (name, url, img) VALUES ('Nguyễn Hoàng', 'brands/nguyen-hoang-08032024111639', 'images/brands/nguyen-hoang-08032024111639.jpg');
INSERT INTO brands (name, url, img) VALUES ('Đầm Sen', 'brands/dam-sen-15032021221344', 'images/brands/dam-sen-15032021221344.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hey Yo', 'brands/hey-yo-26032024152039', 'images/brands/hey-yo-26032024152039.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ariel', 'brands/ariel-20102022104346', 'images/brands/ariel-20102022104346.png');
INSERT INTO brands (name, url, img) VALUES ('Downy', 'brands/downy-26082021181521', 'images/brands/downy-26082021181521.jpg');
INSERT INTO brands (name, url, img) VALUES ('Surf', 'brands/surf-0106202313416', 'images/brands/surf-0106202313416.jpg');
INSERT INTO brands (name, url, img) VALUES ('OMO', 'brands/omo-2706202415740', 'images/brands/omo-2706202415740.jpg');
INSERT INTO brands (name, url, img) VALUES ('Lix', 'brands/lix-0404202118624', 'images/brands/lix-0404202118624.jpg');
INSERT INTO brands (name, url, img) VALUES ('IZI HOME', 'brands/izi-home-0604202101650', 'images/brands/izi-home-0604202101650.jpg');
INSERT INTO brands (name, url, img) VALUES ('Aba', 'brands/aba-14032021194156', 'images/brands/aba-14032021194156.jpg');
INSERT INTO brands (name, url, img) VALUES ('MaxKleen', 'brands/maxkleen-0404202123521', 'images/brands/maxkleen-0404202123521.jpg');
INSERT INTO brands (name, url, img) VALUES ('QMAX', 'brands/38996-id_202410191117340970', 'images/brands/38996-id_202410191117340970.jpg');
INSERT INTO brands (name, url, img) VALUES ('Comfort', 'brands/comfort-0106202313359', 'images/brands/comfort-0106202313359.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hygiene', 'brands/hygiene-3011202183136', 'images/brands/hygiene-3011202183136.jpg');
INSERT INTO brands (name, url, img) VALUES ('Siusop', 'brands/siusop-05042021101245', 'images/brands/siusop-05042021101245.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sunlight', 'brands/sunlight-01062023134818', 'images/brands/sunlight-01062023134818.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mỹ Hảo', 'brands/my-hao-14032021232427', 'images/brands/my-hao-14032021232427.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ez Clean', 'brands/ez-clean-05042021141433', 'images/brands/ez-clean-05042021141433.jpg');
INSERT INTO brands (name, url, img) VALUES ('Gift', 'brands/gift-1509202295544', 'images/brands/gift-1509202295544.png');
INSERT INTO brands (name, url, img) VALUES ('Rena', 'brands/rena-080320228410', 'images/brands/rena-080320228410.jpg');
INSERT INTO brands (name, url, img) VALUES ('Botany', 'brands/botany-1503202122648', 'images/brands/botany-1503202122648.jpg');
INSERT INTO brands (name, url, img) VALUES ('VIM', 'brands/vim-01062023134338', 'images/brands/vim-01062023134338.jpg');
INSERT INTO brands (name, url, img) VALUES ('Duck', 'brands/duck-05042021133840', 'images/brands/duck-05042021133840.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hando', 'brands/hando-060420211614', 'images/brands/hando-060420211614.jpg');
INSERT INTO brands (name, url, img) VALUES ('OKAY', 'brands/okay-1203202110331', 'images/brands/okay-1203202110331.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mr.Fresh', 'brands/mrfresh-04042021225538', 'images/brands/mrfresh-04042021225538.jpg');
INSERT INTO brands (name, url, img) VALUES ('Mao Bao', 'brands/mao-bao-08042021124845', 'images/brands/mao-bao-08042021124845.png');
INSERT INTO brands (name, url, img) VALUES ('Sandokkaebi', 'brands/sandokkaebi-0404202123227', 'images/brands/sandokkaebi-0404202123227.jpg');
INSERT INTO brands (name, url, img) VALUES ('Glade', 'brands/glade-05042021153153', 'images/brands/glade-05042021153153.jpg');
INSERT INTO brands (name, url, img) VALUES ('Spring', 'brands/spring-0603202120592', 'images/brands/spring-0603202120592.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sunflower', 'brands/sunflower-04042021231459', 'images/brands/sunflower-04042021231459.jpg');
INSERT INTO brands (name, url, img) VALUES ('Ambi Pur', 'brands/ambi-pur-03042021235853', 'images/brands/ambi-pur-03042021235853.jpg');
INSERT INTO brands (name, url, img) VALUES ('Oasis', 'brands/oasis-11112021112142', 'images/brands/oasis-11112021112142.jpg');
INSERT INTO brands (name, url, img) VALUES ('Hefei Huicheng', 'brands/hefei-huicheng-0604202114825', 'images/brands/hefei-huicheng-0604202114825.jpg');
INSERT INTO brands (name, url, img) VALUES ('AXO', 'brands/axo-0404202102356', 'images/brands/axo-0404202102356.jpg');
INSERT INTO brands (name, url, img) VALUES ('On1', 'brands/on1-0804202112454', 'images/brands/on1-0804202112454.png');
INSERT INTO brands (name, url, img) VALUES ('Jumbo', 'brands/jumbo-0604202101728', 'images/brands/jumbo-0604202101728.jpg');
INSERT INTO brands (name, url, img) VALUES ('Raid', 'brands/raid-2208202285544', 'images/brands/raid-2208202285544.png');
INSERT INTO brands (name, url, img) VALUES ('ARS', 'brands/ars-040420210735', 'images/brands/ars-040420210735.jpg');
INSERT INTO brands (name, url, img) VALUES ('Panasonic', 'brands/panasonic-150320211158', 'images/brands/panasonic-150320211158.jpg');
INSERT INTO brands (name, url, img) VALUES ('Con Ó', 'brands/con-o-1910202111020', 'images/brands/con-o-1910202111020.jpg');
INSERT INTO brands (name, url, img) VALUES ('Sunhouse', 'brands/sunhouse-05042021112620', 'images/brands/sunhouse-05042021112620.jpg');
INSERT INTO brands (name, url, img) VALUES ('Rainy', 'brands/rainy-15032021134933', 'images/brands/rainy-15032021134933.jpg')

INSERT INTO categories (name) VALUES
('Thịt, cá, trứng, hải sản'),
('Rau, củ, nấm, trái cây'),
('Bia, nước giải khát'),
('Sữa các loại'),
('Gạo, bột, đồ khô'),
('Dầu ăn, nước chấm, gia vị'),
('Mì, miến, cháo, phở'),
('Kem, sữa chua'),
('Thực phẩm đông mát'),
('Bánh kẹo các loại'),
('Chăm sóc cá nhân'),
('Vệ sinh nhà cửa'),
('Sản phẩm cho mẹ và bé'),
('Đồ dùng gia đình')

INSERT INTO subcategories (category_id, name, img ,url) VALUES
(2, 'Trái cây', 'images/subcategories/trái_cây.png', 'trai-cay'),
(2, 'Rau lá', 'images/subcategories/rau_lá.png', 'rau-la'),
(2, 'Củ, quả', 'images/subcategories/củ_quả.png', 'cu-qua'),
(2, 'Nấm các loại', 'images/subcategories/nấm_các_loại.png', 'nam-cac-loai'),
(2, 'Rau, củ làm sẵn', 'images/subcategories/rau_củ_làm_sẵn.png', 'rau-cu-lam-san'),
(2, 'Rau, củ đông lạnh', 'images/subcategories/rau_củ_đông_lạnh.png', 'rau-cu-ong-lanh'),
(1, 'Thịt heo', 'images/subcategories/thịt_heo.png', 'thit-heo'),
(1, 'Thịt bò', 'images/subcategories/thịt_bò.png', 'thit-bo'),
(1, 'Thịt gà, vịt, chim', 'images/subcategories/thịt_gà_vịt_chim.png', 'thit-ga-vit-chim'),
(1, 'Thịt sơ chế', 'images/subcategories/thịt_sơ_chế.png', 'thit-so-che'),
(1, 'Cá, hải sản, khô', 'images/subcategories/cá_hải_sản_khô.png', 'ca-hai-san-kho'),
(1, 'Trứng gà, vịt, cút', 'images/subcategories/trứng_gà_vịt_cút.png', 'trung-ga-vit-cut'),
(3, 'Bia, nước có cồn', 'images/subcategories/bia_nước_có_cồn.png', 'bia-nuoc-co-con'),
(3, 'Nước trà', 'images/subcategories/nước_trà.png', 'nuoc-tra'),
(3, 'Nước ngọt', 'images/subcategories/nước_ngọt.png', 'nuoc-ngot'),
(3, 'Nước tăng lực, bù khoáng', 'images/subcategories/nước_tăng_lực_bù_khoáng.png', 'nuoc-tang-luc-bu-khoang'),
(3, 'Nước suối', 'images/subcategories/nước_suối.png', 'nuoc-suoi'),
(3, 'Nước yến', 'images/subcategories/nước_yến.jpg', 'nuoc-yen'),
(3, 'Nước ép trái cây', 'images/subcategories/nước_ép_trái_cây.png', 'nuoc-ep-trai-cay'),
(3, 'Sữa trái cây, trà sữa', 'images/subcategories/sữa_trái_cây_trà_sữa.png', 'sua-trai-cay-tra-sua'),
(3, 'Trái cây hộp, si rô', 'images/subcategories/trái_cây_hộp_si_rô.png', 'trai-cay-hop-si-ro'),
(3, 'Rượu', 'images/subcategories/rượu.png', 'ruou'),
(3, 'Cà phê hoà tan', 'images/subcategories/cà_phê_hoà_tan.png', 'ca-phe-hoa-tan'),
(3, 'Trà khô, túi lọc', 'images/subcategories/trà_khô_túi_lọc.png', 'tra-kho-tui-loc'),
(3, 'Cà phê pha phin', 'images/subcategories/cà_phê_pha_phin.png', 'ca-phe-pha-phin'),
(3, 'Cà phê lon', 'images/subcategories/cà_phê_lon.png', 'ca-phe-lon'),
(3, 'Mật ong, bột nghệ', 'images/subcategories/mật_ong_bột_nghệ.png', 'mat-ong-bot-nghe'),
(4, 'Sữa tươi', 'images/subcategories/sữa_tươi.png', 'sua-tuoi'),
(4, 'Sữa ca cao, lúa mạch', 'images/subcategories/sữa_ca_cao_lúa_mạch.png', 'sua-ca-cao-lua-mach'),
(4, 'Sữa chua uống liền', 'images/subcategories/sữa_chua_uống_liền.png', 'sua-chua-uong-lien'),
(4, 'Sữa pha sẵn', 'images/subcategories/sữa_pha_sẵn.png', 'sua-pha-san'),
(4, 'Sữa hạt, sữa đậu', 'images/subcategories/sữa_hạt_sữa_đậu.png', 'sua-hat-sua-au'),
(4, 'Sữa đặc', 'images/subcategories/sữa_đặc.png', 'sua-ac'),
(4, 'Ngũ cốc', 'images/subcategories/ngũ_cốc.png', 'ngu-coc'),
(5, 'Gạo các loại', 'images/subcategories/gạo_các_loại.png', 'gao-cac-loai'),
(5, 'Xúc xích', 'images/subcategories/xúc_xích.png', 'xuc-xich'),
(5, 'Cá hộp', 'images/subcategories/cá_hộp.png', 'ca-hop'),
(5, 'Heo, bò, pate hộp', 'images/subcategories/heo_bò_pate_hộp.png', 'heo-bo-pate-hop'),
(5, 'Đồ chay ăn liền', 'images/subcategories/đồ_chay_ăn_liền.png', 'o-chay-an-lien'),
(5, 'Rong biển', 'images/subcategories/rong_biển.png', 'rong-bien'),
(5, 'Tương, chao', 'images/subcategories/tương_chao.png', 'tuong-chao'),
(5, 'Đậu hũ, đồ chay khác', 'images/subcategories/đậu_hũ_đồ_chay_khác.png', 'au-hu-o-chay-khac'),
(5, 'Bột các loại', 'images/subcategories/bột_các_loại.png', 'bot-cac-loai'),
(5, 'Đậu, nấm, đồ khô', 'images/subcategories/đậu_nấm_đồ_khô.png', 'au-nam-o-kho'),
(5, 'Lạp xưởng', 'images/subcategories/lạp_xưởng.png', 'lap-xuong'),
(5, 'Cá mắm, dưa mắm', 'images/subcategories/cá_mắm_dưa_mắm.png', 'ca-mam-dua-mam'),
(5, 'Bánh phồng, bánh đa', 'images/subcategories/bánh_phồng_bánh_đa.png', 'banh-phong-banh-a'),
(5, 'Bánh tráng', 'images/subcategories/bánh_tráng.png', 'banh-trang'),
(5, 'Nước cốt dừa lon', 'images/subcategories/nước_cốt_dừa_lon.png', 'nuoc-cot-dua-lon'),
(6, 'Dầu ăn', 'images/subcategories/dầu_ăn.png', 'dau-an'),
(6, 'Nước mắm', 'images/subcategories/nước_mắm.png', 'nuoc-mam'),
(6, 'Nước tương', 'images/subcategories/nước_tương.png', 'nuoc-tuong'),
(6, 'Đường', 'images/subcategories/đường.png', 'uong'),
(6, 'Hạt nêm, bột ngọt, bột canh', 'images/subcategories/hạt_nêm_bột_ngọt_bột_canh.png', 'hat-nem-bot-ngot-bot-canh'),
(6, 'Muối', 'images/subcategories/muối.png', 'muoi'),
(6, 'Tương ớt-đen, mayonnaise', 'images/subcategories/tương_ớt-đen_mayonnaise.png', 'tuong-ot-en-mayonnaise'),
(6, 'Dầu hào, giấm, bơ', 'images/subcategories/dầu_hào_giấm_bơ.png', 'dau-hao-giam-bo'),
(6, 'Gia vị nêm sẵn', 'images/subcategories/gia_vị_nêm_sẵn.png', 'gia-vi-nem-san'),
(6, 'Nước chấm, mắm', 'images/subcategories/nước_chấm_mắm.png', 'nuoc-cham-mam'),
(6, 'Tiêu, sa tế, ớt bột', 'images/subcategories/tiêu_sa_tế_ớt_bột.png', 'tieu-sa-te-ot-bot'),
(6, 'Bột nghệ, tỏi, hồi, quế,...', 'images/subcategories/bột_nghệ_tỏi_hồi_quế.png', 'bot-nghe-toi-hoi-que'),
(7, 'Mì ăn liền', 'images/subcategories/mì_ăn_liền.png', 'mi-an-lien'),
(7, 'Hủ tiếu, miến', 'images/subcategories/hủ_tiếu_miến.png', 'hu-tieu-mien'),
(7, 'Phở, bún ăn liền', 'images/subcategories/phở_bún_ăn_liền.png', 'pho-bun-an-lien'),
(7, 'Cháo gói, cháo tươi', 'images/subcategories/cháo_gói_cháo_tươi.png', 'chao-goi-chao-tuoi'),
(7, 'Miến, hủ tiếu, phở khô', 'images/subcategories/miến_hủ_tiếu_phở_khô.png', 'mien-hu-tieu-pho-kho'),
(7, 'Bún các loại', 'images/subcategories/bún_các_loại.png', 'bun-cac-loai'),
(7, 'Nui các loại', 'images/subcategories/nui_các_loại.png', 'nui-cac-loai'),
(7, 'Mì Ý, mì trứng', 'images/subcategories/mì_ý_mì_trứng.png', 'mi-y-mi-trung'),
(7, 'Bánh gạo Hàn Quốc', 'images/subcategories/bánh_gạo_hàn_quốc.png', 'banh-gao-han-quoc'),
(8, 'Kem cây, kem hộp', 'images/subcategories/kem_cây_kem_hộp.png', 'kem-cay-kem-hop'),
(8, 'Sữa chua ăn', 'images/subcategories/sữa_chua_ăn.png', 'sua-chua-an'),
(8, 'Sữa chua uống', 'images/subcategories/sữa_chua_uống.png', 'sua-chua-uong'),
(8, 'Bơ sữa, phô mai', 'images/subcategories/bơ_sữa_phô_mai.png', 'bo-sua-pho-mai'),
(8, 'Bánh flan, thạch, chè', 'images/subcategories/bánh_flan_thạch_chè.png', 'banh-flan-thach-che'),
(9, 'Chả giò, chả ram', 'images/subcategories/chả_giò_chả_ram.png', 'cha-gio-cha-ram'),
(9, 'Bánh bao, bánh mì, pizza', 'images/subcategories/bánh_bao_bánh_mì_pizza.png', 'banh-bao-banh-mi-pizza'),
(9, 'Chả lụa, thịt nguội', 'images/subcategories/chả_lụa_thịt_nguội.png', 'cha-lua-thit-nguoi'),
(9, 'Xúc xích, lạp xưởng tươi', 'images/subcategories/xúc_xích_lạp_xưởng_tươi.png', 'xuc-xich-lap-xuong-tuoi'),
(9, 'Làm sẵn, ăn liền', 'images/subcategories/làm_sẵn_ăn_liền.png', 'lam-san-an-lien'),
(9, 'Sơ chế, tẩm ướp', 'images/subcategories/sơ_chế_tẩm_ướp.png', 'so-che-tam-uop'),
(9, 'Cá viên, bò viên', 'images/subcategories/cá_viên_bò_viên.png', 'ca-vien-bo-vien'),
(9, 'Đậu hũ, tàu hũ', 'images/subcategories/đậu_hũ_tàu_hũ.png', 'au-hu-tau-hu'),
(9, 'Thịt, cá đông lạnh', 'images/subcategories/thịt_cá_đông_lạnh.png', 'thit-ca-ong-lanh'),
(9, 'Bún tươi, mì nưa', 'images/subcategories/bún_tươi_mì_nưa.png', 'bun-tuoi-mi-nua'),
(9, 'Kim chi, đồ chua', 'images/subcategories/kim_chi_đồ_chua.png', 'kim-chi-o-chua'),
(9, 'Mandu, há cảo, sủi cảo', 'images/subcategories/mandu_há_cảo_sủi_cảo.png', 'mandu-ha-cao-sui-cao'),
(9, 'Nước lẩu, viên thả lẩu', 'images/subcategories/nước_lẩu_viên_thả_lẩu.png', 'nuoc-lau-vien-tha-lau'),
(10, 'Bánh quy', 'images/subcategories/bánh_quy.png', 'banh-quy'),
(10, 'Bánh gạo', 'images/subcategories/bánh_gạo.png', 'banh-gao'),
(10, 'Bánh quế', 'images/subcategories/bánh_quế.png', 'banh-que'),
(10, 'Ngũ cốc, yến mạch', 'images/subcategories/ngũ_cốc_yến_mạch.png', 'ngu-coc-yen-mach'),
(10, 'Snack, rong biển', 'images/subcategories/snack_rong_biển.png', 'snack-rong-bien'),
(10, 'Bánh Chocopie', 'images/subcategories/bánh_chocopie.png', 'banh-chocopie'),
(10, 'Bánh bông lan', 'images/subcategories/bánh_bông_lan.png', 'banh-bong-lan'),
(10, 'Bánh tươi, Sandwich', 'images/subcategories/bánh_tươi_sandwich.png', 'banh-tuoi-sandwich'),
(10, 'Socola', 'images/subcategories/socola.png', 'socola'),
(10, 'Kẹo cứng', 'images/subcategories/kẹo_cứng.png', 'keo-cung'),
(10, 'Kẹo dẻo, kẹo marshmallow', 'images/subcategories/kẹo_dẻo_kẹo_marshmallow.png', 'keo-deo-keo-marshmallow'),
(10, 'Kẹo Singum', 'images/subcategories/kẹo_singum.png', 'keo-singum'),
(10, 'Trái cây sấy', 'images/subcategories/trái_cây_sấy.png', 'trai-cay-say'),
(10, 'Hạt khô', 'images/subcategories/hạt_khô.png', 'hat-kho'),
(10, 'Rau câu, thạch dừa', 'images/subcategories/rau_câu_thạch_dừa.png', 'rau-cau-thach-dua'),
(10, 'Khô chế biến sẵn', 'images/subcategories/khô_chế_biến_sẵn.png', 'kho-che-bien-san'),
(10, 'Cơm cháy, bánh tráng', 'images/subcategories/cơm_cháy_bánh_tráng.png', 'com-chay-banh-trang'),
(10, 'Bánh xốp', 'images/subcategories/bánh_xốp.png', 'banh-xop'),
(10, 'Bánh que', 'images/subcategories/bánh_que.png', 'banh-que'),
(11, 'Tẩy trang', 'images/subcategories/tẩy_trang.png', 'tay-trang'),
(11, 'Dầu gội', 'images/subcategories/dầu_gội.png', 'dau-goi'),
(11, 'Dầu xả, kem ủ', 'images/subcategories/dầu_xả_kem_ủ.png', 'dau-xa-kem-u'),
(11, 'Sữa tắm', 'images/subcategories/sữa_tắm.png', 'sua-tam'),
(11, 'Kem đánh răng', 'images/subcategories/kem_đánh_răng.png', 'kem-anh-rang'),
(11, 'Kem chống nắng', 'images/subcategories/kem_chống_nắng.png', 'kem-chong-nang'),
(11, 'Bàn chải, tăm chỉ nha khoa', 'images/subcategories/bàn_chải_tăm_chỉ_nha_khoa.png', 'ban-chai-tam-chi-nha-khoa'),
(11, 'Giấy vệ sinh', 'images/subcategories/giấy_vệ_sinh.png', 'giay-ve-sinh'),
(11, 'Khăn giấy', 'images/subcategories/khăn_giấy.png', 'khan-giay'),
(11, 'Khăn ướt', 'images/subcategories/khăn_ướt.png', 'khan-uot'),
(11, 'Băng vệ sinh', 'images/subcategories/băng_vệ_sinh.png', 'bang-ve-sinh'),
(11, 'Nước rửa tay', 'images/subcategories/nước_rửa_tay.png', 'nuoc-rua-tay'),
(11, 'Xà bông cục', 'images/subcategories/xà_bông_cục.png', 'xa-bong-cuc'),
(11, 'Lăn xịt khử mùi', 'images/subcategories/lăn_xịt_khử_mùi.png', 'lan-xit-khu-mui'),
(11, 'Nước súc miệng', 'images/subcategories/nước_súc_miệng.png', 'nuoc-suc-mieng'),
(11, 'Dao cạo, bọt cạo râu', 'images/subcategories/dao_cạo_bọt_cạo_râu.png', 'dao-cao-bot-cao-rau'),
(11, 'Bao cao su', 'images/subcategories/bao_cao_su.png', 'bao-cao-su'),
(11, 'Khẩu trang', 'images/subcategories/khẩu_trang.png', 'khau-trang'),
(11, 'Thuốc nhuộm tóc', 'images/subcategories/thuốc_nhuộm_tóc.png', 'thuoc-nhuom-toc'),
(11, 'Tăm bông', 'images/subcategories/tăm_bông.png', 'tam-bong'),
(11, 'Dung dịch vệ sinh', 'images/subcategories/dung_dịch_vệ_sinh.png', 'dung-dich-ve-sinh'),
(11, 'Sữa dưỡng thể', 'images/subcategories/sữa_dưỡng_thể.png', 'sua-duong-the'),
(11, 'Xịt dưỡng, keo vuốt tóc', 'images/subcategories/xịt_dưỡng_keo_vuốt_tóc.png', 'xit-duong-keo-vuot-toc'),
(11, 'Kem tẩy lông', 'images/subcategories/kem_tẩy_lông.png', 'kem-tay-long'),
(11, 'Sữa rửa mặt', 'images/subcategories/sữa_rửa_mặt.png', 'sua-rua-mat'),
(12, 'Nước giặt', 'images/subcategories/nước_giặt.png', 'nuoc-giat'),
(12, 'Nước xả', 'images/subcategories/nước_xả.png', 'nuoc-xa'),
(12, 'Bột giặt', 'images/subcategories/bột_giặt.png', 'bot-giat'),
(12, 'Nước rửa chén', 'images/subcategories/nước_rửa_chén.png', 'nuoc-rua-chen'),
(12, 'Nước lau sàn', 'images/subcategories/nước_lau_sàn.png', 'nuoc-lau-san'),
(12, 'Tẩy rửa nhà tắm', 'images/subcategories/tẩy_rửa_nhà_tắm.png', 'tay-rua-nha-tam'),
(12, 'Bình xịt côn trùng', 'images/subcategories/bình_xịt_côn_trùng.png', 'binh-xit-con-trung'),
(12, 'Xịt phòng, sáp thơm', 'images/subcategories/xịt_phòng_sáp_thơm.png', 'xit-phong-sap-thom'),
(12, 'Lau kính, lau bếp', 'images/subcategories/lau_kính_lau_bếp.png', 'lau-kinh-lau-bep'),
(12, 'Nước tẩy', 'images/subcategories/nước_tẩy.png', 'nuoc-tay'),
(13, 'Tắm gội cho bé', 'images/subcategories/tắm_gội_cho_bé.png', 'tam-goi-cho-be'),
(13, 'Sữa tắm, dầu gội cho bé', 'images/subcategories/sữa_tắm_dầu_gội_cho_bé.png', 'sua-tam-dau-goi-cho-be'),
(13, 'Nước xả cho bé', 'images/subcategories/nước_xả_cho_bé.png', 'nuoc-xa-cho-be'),
(13, 'Kem đánh răng bé', 'images/subcategories/kem_đánh_răng_bé.png', 'kem-anh-rang-be'),
(13, 'Bàn chải cho bé', 'images/subcategories/bàn_chải_cho_bé.png', 'ban-chai-cho-be'),
(13, 'Khẩu trang, tăm bông', 'images/subcategories/khẩu_trang_tăm_bông.png', 'khau-trang-tam-bong'),
(13, 'Phấn thơm, dưỡng ẩm', 'images/subcategories/phấn_thơm_dưỡng_ẩm.png', 'phan-thom-duong-am'),
(14, 'Túi đựng rác', 'images/subcategories/túi_đựng_rác.png', 'tui-ung-rac'),
(14, 'Pin tiểu', 'images/subcategories/pin_tiểu.png', 'pin-tieu'),
(14, 'Màng bọc, giấy thấm dầu', 'images/subcategories/màng_bọc_giấy_thấm_dầu.png', 'mang-boc-giay-tham-dau'),
(14, 'Đồ dùng một lần', 'images/subcategories/đồ_dùng_một_lần.png', 'o-dung-mot-lan'),
(14, 'Hộp đựng thực phẩm', 'images/subcategories/hộp_đựng_thực_phẩm.png', 'hop-ung-thuc-pham'),
(14, 'Chảo', 'images/subcategories/chảo.png', 'chao'),
(14, 'Dao, kéo', 'images/subcategories/dao_kéo.jpg', 'dao-keo'),
(14, 'Thau, rổ', 'images/subcategories/thau_rổ.png', 'thau-ro'),
(14, 'Ly, bình giữ nhiệt', 'images/subcategories/ly_bình_giữ_nhiệt.png', 'ly-binh-giu-nhiet'),
(14, 'Nhấc lót nồi', 'images/subcategories/nhấc_lót_nồi.png', 'nhac-lot-noi'),
(14, 'Khăn lau bếp', 'images/subcategories/khăn_lau_bếp.png', 'khan-lau-bep'),
(14, 'Miếng rửa chén', 'images/subcategories/miếng_rửa_chén.png', 'mieng-rua-chen'),
(14, 'Khăn tắm, bông tắm', 'images/subcategories/khăn_tắm_bông_tắm.png', 'khan-tam-bong-tam'),
(14, 'Bàn chải', 'images/subcategories/bàn_chải.png', 'ban-chai'),
(14, 'Bút bi, thước kẻ', 'images/subcategories/bút_bi_thước_kẻ.png', 'but-bi-thuoc-ke'),
(14, 'Băng keo, bao thư', 'images/subcategories/băng_keo_bao_thư.png', 'bang-keo-bao-thu');

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sườn non heo nhập khẩu Đức túi 1kg",
    99000,
    "images/products/suon-non-heo-nhap-khau-uc-tui-1kg.jpg",
    "suon-non-heo-nhap-khau-uc-tui-1kg",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân giò trước C.P 500g",
    50000,
    "images/products/chan-gio-truoc-cp-500g.jpg",
    "chan-gio-truoc-cp-500g",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân giò heo nhập khẩu Đức túi 500g",
    22500,
    "images/products/chan-gio-heo-nhap-khau-uc-tui-500g.jpg",
    "chan-gio-heo-nhap-khau-uc-tui-500g",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Móng giò heo Ace Foods khay 500g",
    38000,
    "images/products/mong-gio-heo-ace-foods-khay-500g.jpg",
    "mong-gio-heo-ace-foods-khay-500g",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân giò heo nhập khẩu Đức",
    44840,
    "images/products/chan-gio-heo-nhap-khau-uc.jpg",
    "chan-gio-heo-nhap-khau-uc",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt heo xay C.P 200g",
    22620,
    "images/products/thit-heo-xay-cp-200g.jpg",
    "thit-heo-xay-cp-200g",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ba rọi heo C.P",
    51840,
    "images/products/ba-roi-heo-cp.jpg",
    "ba-roi-heo-cp",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ba rọi heo nhập khẩu Nga",
    38340,
    "images/products/ba-roi-heo-nhap-khau-nga.jpg",
    "ba-roi-heo-nhap-khau-nga",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ba rọi heo nhập khẩu Nga túi 500g",
    58220,
    "images/products/ba-roi-heo-nhap-khau-nga-tui-500g.jpg",
    "ba-roi-heo-nhap-khau-nga-tui-500g",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt heo xay C.P",
    38610,
    "images/products/thit-heo-xay-cp.jpg",
    "thit-heo-xay-cp",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt đùi C.P khay 300g",
    31000,
    "images/products/thit-ui-cp-khay-300g.jpg",
    "thit-ui-cp-khay-300g",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt đùi heo C.P",
    34290,
    "images/products/thit-ui-heo-cp.jpg",
    "thit-ui-heo-cp",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt nạc heo C.P 300g",
    38400,
    "images/products/thit-nac-heo-cp-300g.jpg",
    "thit-nac-heo-cp-300g",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt nạc heo C.P",
    43470,
    "images/products/thit-nac-heo-cp.jpg",
    "thit-nac-heo-cp",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân giò heo C.P",
    37200,
    "images/products/chan-gio-heo-cp.jpg",
    "chan-gio-heo-cp",
    1000,
    5,
    1,
    1,
    1
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ba chỉ bò Mỹ Kiwifood khay 300g",
    89000,
    "images/products/ba-chi-bo-my-kiwifood-khay-300g.jpg",
    "ba-chi-bo-my-kiwifood-khay-300g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gầu bò Mỹ Kiwifood khay 300g",
    99000,
    "images/products/gau-bo-my-kiwifood-khay-300g.jpg",
    "gau-bo-my-kiwifood-khay-300g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lõi vai bò cuộn Kiwifood khay 300g",
    119000,
    "images/products/loi-vai-bo-cuon-kiwifood-khay-300g.jpg",
    "loi-vai-bo-cuon-kiwifood-khay-300g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lõi vai bò cắt miếng Kiwifood khay 300g",
    112000,
    "images/products/loi-vai-bo-cat-mieng-kiwifood-khay-300g.jpg",
    "loi-vai-bo-cat-mieng-kiwifood-khay-300g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ba chỉ bò Úc đông lạnh Mr.T 300g",
    89000,
    "images/products/ba-chi-bo-uc-ong-lanh-mrt-300g.jpg",
    "ba-chi-bo-uc-ong-lanh-mrt-300g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sườn bò Tây Ban Nha Ace Foods khay 200g",
    55000,
    "images/products/suon-bo-tay-ban-nha-ace-foods-khay-200g.jpg",
    "suon-bo-tay-ban-nha-ace-foods-khay-200g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt vụn bò vỉ 250g",
    33760,
    "images/products/thit-vun-bo-vi-250g.jpg",
    "thit-vun-bo-vi-250g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nạm bò 150g",
    30800,
    "images/products/nam-bo-150g.jpg",
    "nam-bo-150g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bắp bò vỉ 300g",
    58630,
    "images/products/bap-bo-vi-300g.jpg",
    "bap-bo-vi-300g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt vụn bò",
    40545,
    "images/products/thit-vun-bo.jpg",
    "thit-vun-bo",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nạm bò",
    59700,
    "images/products/nam-bo.jpg",
    "nam-bo",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bắp bò",
    67392,
    "images/products/bap-bo.jpg",
    "bap-bo",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đùi bò",
    80700,
    "images/products/ui-bo.jpg",
    "ui-bo",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dẻ sườn bò Mỹ Gofood 500g",
    284000,
    "images/products/de-suon-bo-my-gofood-500g.jpg",
    "de-suon-bo-my-gofood-500g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dẻ sườn bò Mỹ Gofood 300g",
    169000,
    "images/products/de-suon-bo-my-gofood-300g.jpg",
    "de-suon-bo-my-gofood-300g",
    1000,
    5,
    1,
    1,
    2
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gà ủ muối hoa tiêu LifeFood gói 450g",
    83000,
    "images/products/ga-u-muoi-hoa-tieu-lifefood-goi-450g.jpg",
    "ga-u-muoi-hoa-tieu-lifefood-goi-450g",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Má đùi gà C.P 500g",
    35000,
    "images/products/ma-ui-ga-cp-500g.jpg",
    "ma-ui-ga-cp-500g",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân gà C.P 500g",
    32000,
    "images/products/chan-ga-cp-500g.jpg",
    "chan-ga-cp-500g",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đùi cánh gà tươi C.P 500g",
    43000,
    "images/products/ui-canh-ga-tuoi-cp-500g.jpg",
    "ui-canh-ga-tuoi-cp-500g",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xương gà C.P 500g",
    21900,
    "images/products/xuong-ga-cp-500g.jpg",
    "xuong-ga-cp-500g",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Vịt nửa con C.P 1.2kg",
    99000,
    "images/products/vit-nua-con-cp-12kg.jpg",
    "vit-nua-con-cp-12kg",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ức gà phi lê có da C.P",
    49500,
    "images/products/uc-ga-phi-le-co-da-cp.jpg",
    "uc-ga-phi-le-co-da-cp",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Má đùi gà cắt sẵn C.P",
    26481,
    "images/products/ma-ui-ga-cat-san-cp.jpg",
    "ma-ui-ga-cat-san-cp",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Má đùi gà cắt sẵn C.P 500g",
    40057,
    "images/products/ma-ui-ga-cat-san-cp-500g.jpg",
    "ma-ui-ga-cat-san-cp-500g",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đùi tỏi gà C.P",
    33480,
    "images/products/ui-toi-ga-cp.jpg",
    "ui-toi-ga-cp",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đùi tỏi gà C.P 500g",
    50240,
    "images/products/ui-toi-ga-cp-500g.jpg",
    "ui-toi-ga-cp-500g",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đùi gà góc tư C.P 500g",
    43520,
    "images/products/ui-ga-goc-tu-cp-500g.jpg",
    "ui-ga-goc-tu-cp-500g",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đùi gà góc tư C.P",
    28350,
    "images/products/ui-ga-goc-tu-cp.jpg",
    "ui-ga-goc-tu-cp",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cánh gà C.P",
    31365,
    "images/products/canh-ga-cp.jpg",
    "canh-ga-cp",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cánh gà 500g",
    50720,
    "images/products/canh-ga-500g.jpg",
    "canh-ga-500g",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cánh gà giữa nhập khẩu 500g",
    70400,
    "images/products/canh-ga-giua-nhap-khau-500g.jpg",
    "canh-ga-giua-nhap-khau-500g",
    1000,
    5,
    1,
    1,
    3
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Giả cầy heo 1kg",
    121000,
    "images/products/gia-cay-heo-1kg.jpg",
    "gia-cay-heo-1kg",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân gà rút xương sả tắc 250g",
    52000,
    "images/products/chan-ga-rut-xuong-sa-tac-250g.jpg",
    "chan-ga-rut-xuong-sa-tac-250g",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thỏ nướng ống tre 100g",
    44000,
    "images/products/tho-nuong-ong-tre-100g.jpg",
    "tho-nuong-ong-tre-100g",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Heo rừng nướng ống tre 100g",
    44000,
    "images/products/heo-rung-nuong-ong-tre-100g.jpg",
    "heo-rung-nuong-ong-tre-100g",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dê nướng ống tre 100g",
    44000,
    "images/products/de-nuong-ong-tre-100g.jpg",
    "de-nuong-ong-tre-100g",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bò tơ nướng ống tre 100g",
    44000,
    "images/products/bo-to-nuong-ong-tre-100g.jpg",
    "bo-to-nuong-ong-tre-100g",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Canh khổ qua dồn cá basa khay 370g",
    35000,
    "images/products/canh-kho-qua-don-ca-basa-khay-370g.jpg",
    "canh-kho-qua-don-ca-basa-khay-370g",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Canh chua cá basa 750g",
    49000,
    "images/products/canh-chua-ca-basa-750g.jpg",
    "canh-chua-ca-basa-750g",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dê xối sả 250g",
    134000,
    "images/products/de-xoi-sa-250g.jpg",
    "de-xoi-sa-250g",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân gà rút xương xốt Thái 450g vị cay nồng",
    77000,
    "images/products/chan-ga-rut-xuong-xot-thai-450g-vi-cay-nong.jpg",
    "chan-ga-rut-xuong-xot-thai-450g-vi-cay-nong",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân gà rút xương xốt Thái 300g vị cay nồng",
    62000,
    "images/products/chan-ga-rut-xuong-xot-thai-300g-vi-cay-nong.jpg",
    "chan-ga-rut-xuong-xot-thai-300g-vi-cay-nong",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân gà rút xương xốt Thái 250g vị cay nồng",
    53000,
    "images/products/chan-ga-rut-xuong-xot-thai-250g-vi-cay-nong.jpg",
    "chan-ga-rut-xuong-xot-thai-250g-vi-cay-nong",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân gà rút xương sả tắc hộp 450g",
    71000,
    "images/products/chan-ga-rut-xuong-sa-tac-hop-450g.jpg",
    "chan-ga-rut-xuong-sa-tac-hop-450g",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân gà rút xương sả tắc hộp 300g",
    59000,
    "images/products/chan-ga-rut-xuong-sa-tac-hop-300g.jpg",
    "chan-ga-rut-xuong-sa-tac-hop-300g",
    1000,
    5,
    1,
    1,
    4
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá bống đục làm sạch 500g",
    65000,
    "images/products/ca-bong-uc-lam-sach-500g.jpg",
    "ca-bong-uc-lam-sach-500g",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá he làm sạch 450g - 550g (3 - 4 con)",
    59000,
    "images/products/ca-he-lam-sach-450g---550g-3---4-con.jpg",
    "ca-he-lam-sach-450g---550g-3---4-con",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá Sapa Nhật Ào Ào 400g",
    27500,
    "images/products/ca-sapa-nhat-ao-ao-400g.jpg",
    "ca-sapa-nhat-ao-ao-400g",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá thu ảo 1 nắng Lam Điền gói 300g",
    38000,
    "images/products/ca-thu-ao-1-nang-lam-ien-goi-300g.jpg",
    "ca-thu-ao-1-nang-lam-ien-goi-300g",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá hồi coho cắt khúc nhập khẩu chi lê 200g",
    84000,
    "images/products/ca-hoi-coho-cat-khuc-nhap-khau-chi-le-200g.jpg",
    "ca-hoi-coho-cat-khuc-nhap-khau-chi-le-200g",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá hồi Coho cắt khúc nhập khẩu Chi Lê",
    90000,
    "images/products/ca-hoi-coho-cat-khuc-nhap-khau-chi-le.jpg",
    "ca-hoi-coho-cat-khuc-nhap-khau-chi-le",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tôm thẻ Minh Phú 250g",
    58000,
    "images/products/tom-the-minh-phu-250g.jpg",
    "tom-the-minh-phu-250g",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tôm thẻ C.P 250g",
    58000,
    "images/products/tom-the-cp-250g.jpg",
    "tom-the-cp-250g",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá chim nước ngọt làm sạch 450g",
    24840,
    "images/products/ca-chim-nuoc-ngot-lam-sach-450g.jpg",
    "ca-chim-nuoc-ngot-lam-sach-450g",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá chim nước ngọt làm sạch",
    44400,
    "images/products/ca-chim-nuoc-ngot-lam-sach.jpg",
    "ca-chim-nuoc-ngot-lam-sach",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá basa cắt khúc 500g",
    28880,
    "images/products/ca-basa-cat-khuc-500g.jpg",
    "ca-basa-cat-khuc-500g",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá basa cắt khúc",
    40000,
    "images/products/ca-basa-cat-khuc.jpg",
    "ca-basa-cat-khuc",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá cơm",
    58000,
    "images/products/ca-com.jpg",
    "ca-com",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá rô phi làm sạch",
    45000,
    "images/products/ca-ro-phi-lam-sach.jpg",
    "ca-ro-phi-lam-sach",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá cam size lớn làm sạch nhập khẩu Nhật Bản",
    49500,
    "images/products/ca-cam-size-lon-lam-sach-nhap-khau-nhat-ban.jpg",
    "ca-cam-size-lon-lam-sach-nhap-khau-nhat-ban",
    1000,
    5,
    1,
    1,
    5
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng vịt lộn Phương Nam hộp 10 quả",
    49000,
    "images/products/trung-vit-lon-phuong-nam-hop-10-qua.jpg",
    "trung-vit-lon-phuong-nam-hop-10-qua",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng cút lộn Phương Nam hộp 30 quả",
    36000,
    "images/products/trung-cut-lon-phuong-nam-hop-30-qua.jpg",
    "trung-cut-lon-phuong-nam-hop-30-qua",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng vịt lộn Phương Nam hộp 6 quả",
    30000,
    "images/products/trung-vit-lon-phuong-nam-hop-6-qua.jpg",
    "trung-vit-lon-phuong-nam-hop-6-qua",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng vịt hộp 10 quả (giao ngẫu nhiên thương hiệu)",
    35000,
    "images/products/trung-vit-hop-10-qua-giao-ngau-nhien-thuong-hieu.jpg",
    "trung-vit-hop-10-qua-giao-ngau-nhien-thuong-hieu",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng cút hộp 30 (giao ngẫu nhiên thương hiệu)",
    27000,
    "images/products/trung-cut-hop-30-giao-ngau-nhien-thuong-hieu.jpg",
    "trung-cut-hop-30-giao-ngau-nhien-thuong-hieu",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng gà so hộp 10 tặng 2 (giao ngẫu nhiên thương hiệu)",
    27000,
    "images/products/trung-ga-so-hop-10-tang-2-giao-ngau-nhien-thuong-hieu.jpg",
    "trung-ga-so-hop-10-tang-2-giao-ngau-nhien-thuong-hieu",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng gà tươi hộp 10 quả",
    27000,
    "images/products/trung-ga-tuoi-hop-10-qua.jpg",
    "trung-ga-tuoi-hop-10-qua",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng gà ta hộp 6 quả (giao ngẫu nhiên thương hiệu)",
    24000,
    "images/products/trung-ga-ta-hop-6-qua-giao-ngau-nhien-thuong-hieu.jpg",
    "trung-ga-ta-hop-6-qua-giao-ngau-nhien-thuong-hieu",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng vịt muối hộp 4 quả (giao ngẫu nhiên thương hiệu)",
    24000,
    "images/products/trung-vit-muoi-hop-4-qua-giao-ngau-nhien-thuong-hieu.jpg",
    "trung-vit-muoi-hop-4-qua-giao-ngau-nhien-thuong-hieu",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng vịt bắc thảo hộp 4 quả (giao ngẫu nhiên thương hiệu)",
    27000,
    "images/products/trung-vit-bac-thao-hop-4-qua-giao-ngau-nhien-thuong-hieu.jpg",
    "trung-vit-bac-thao-hop-4-qua-giao-ngau-nhien-thuong-hieu",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng gà omega Emivest hộp 6 quả",
    31000,
    "images/products/trung-ga-omega-emivest-hop-6-qua.jpg",
    "trung-ga-omega-emivest-hop-6-qua",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trứng gà thả vườn Emivest hộp 6",
    31000,
    "images/products/trung-ga-tha-vuon-emivest-hop-6.jpg",
    "trung-ga-tha-vuon-emivest-hop-6",
    1000,
    5,
    1,
    1,
    6
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cam sành",
    40000/5kg,
    "images/products/cam-sanh.jpg",
    "cam-sanh",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Táo Ninh Thuận 500g",
    11000/500g,
    "images/products/tao-ninh-thuan-500g.jpg",
    "tao-ninh-thuan-500g",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xoài keo trái từ 350g trở lên",
    28000/2kg,
    "images/products/xoai-keo-trai-tu-350g-tro-len.jpg",
    "xoai-keo-trai-tu-350g-tro-len",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng táo story pháp 2.5kg",
    105000/25kg,
    "images/products/thung-tao-story-phap-25kg.jpg",
    "thung-tao-story-phap-25kg",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chuối già giống Nam Mỹ 1kg (trái từ 120-220g)",
    21000/1kg,
    "images/products/chuoi-gia-giong-nam-my-1kg-trai-tu-120-220g.jpg",
    "chuoi-gia-giong-nam-my-1kg-trai-tu-120-220g",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mít Thái 1kg",
    22500/1kg,
    "images/products/mit-thai-1kg.jpg",
    "mit-thai-1kg",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dưa hấu đỏ trái 2.5 kg (1 trái)",
    25000/25kg,
    "images/products/dua-hau-o-trai-25-kg-1-trai.jpg",
    "dua-hau-o-trai-25-kg-1-trai",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cam sành 1kg (trái từ 130g)",
    15600/1kg,
    "images/products/cam-sanh-1kg-trai-tu-130g.jpg",
    "cam-sanh-1kg-trai-tu-130g",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cam sành vắt nước 5kg",
    30000/5kg,
    "images/products/cam-sanh-vat-nuoc-5kg.jpg",
    "cam-sanh-vat-nuoc-5kg",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xoài keo 1kg (trái từ 300g)",
    23900/1kg,
    "images/products/xoai-keo-1kg-trai-tu-300g.jpg",
    "xoai-keo-1kg-trai-tu-300g",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Táo Gala mini nhập khẩu",
    94000/2kg,
    "images/products/tao-gala-mini-nhap-khau.jpg",
    "tao-gala-mini-nhap-khau",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Táo Gala mini nhập khẩu New Zealand 1kg",
    45000/1kg,
    "images/products/tao-gala-mini-nhap-khau-new-zealand-1kg.jpg",
    "tao-gala-mini-nhap-khau-new-zealand-1kg",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bưởi da xanh trái 1.5kg (1 trái)",
    71700/15kg,
    "images/products/buoi-da-xanh-trai-15kg-1-trai.jpg",
    "buoi-da-xanh-trai-15kg-1-trai",
    1000,
    5,
    1,
    2,
    7
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rau lang 400g",
    6000/400g,
    "images/products/rau-lang-400g.jpg",
    "rau-lang-400g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cải bẹ dún",
    6000/400g,
    "images/products/cai-be-dun.jpg",
    "cai-be-dun",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bún tươi 500g",
    8000/500g,
    "images/products/bun-tuoi-500g.jpg",
    "bun-tuoi-500g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xà lách búp mỡ 300g",
    7200/300g,
    "images/products/xa-lach-bup-mo-300g.jpg",
    "xa-lach-bup-mo-300g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rau muống nước 400g",
    5400/400g,
    "images/products/rau-muong-nuoc-400g.jpg",
    "rau-muong-nuoc-400g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cải ngọt túi 400g",
    6000/400g,
    "images/products/cai-ngot-tui-400g.jpg",
    "cai-ngot-tui-400g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rau muống hạt 400g",
    6000/400g,
    "images/products/rau-muong-hat-400g.jpg",
    "rau-muong-hat-400g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rau mồng tơi 400g",
    6000/400g,
    "images/products/rau-mong-toi-400g.jpg",
    "rau-mong-toi-400g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cải bẹ xanh 400gr",
    6000/400g,
    "images/products/cai-be-xanh-400gr.jpg",
    "cai-be-xanh-400gr",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rau dền 400g",
    6000/400g,
    "images/products/rau-den-400g.jpg",
    "rau-den-400g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cải thìa 300g",
    6000/300g,
    "images/products/cai-thia-300g.jpg",
    "cai-thia-300g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rau ngót khoảng 250g",
    8760/250g,
    "images/products/rau-ngot-khoang-250g.jpg",
    "rau-ngot-khoang-250g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hành lá khoảng 100g",
    4740/100g,
    "images/products/hanh-la-khoang-100g.jpg",
    "hanh-la-khoang-100g",
    1000,
    5,
    1,
    2,
    8
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hành tây 1kg",
    16000/1kg,
    "images/products/hanh-tay-1kg.jpg",
    "hanh-tay-1kg",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dưa leo giống Nhật cặp 2 trái 500g",
    9000/500g,
    "images/products/dua-leo-giong-nhat-cap-2-trai-500g.jpg",
    "dua-leo-giong-nhat-cap-2-trai-500g",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hành tây 10kg",
    180000/Bao 10kg,
    "images/products/hanh-tay-10kg.jpg",
    "hanh-tay-10kg",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bầu sao 1kg (2 trái)",
    15500/1kg,
    "images/products/bau-sao-1kg-2-trai.jpg",
    "bau-sao-1kg-2-trai",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà rốt 1kg",
    21000/1kg,
    "images/products/ca-rot-1kg.jpg",
    "ca-rot-1kg",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bí xanh 1kg",
    18000//từ 2-3 trái,
    "images/products/bi-xanh-1kg.jpg",
    "bi-xanh-1kg",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bắp cải trắng",
    15000/1kg,
    "images/products/bap-cai-trang.jpg",
    "bap-cai-trang",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bắp cải thảo",
    14250/1kg,
    "images/products/bap-cai-thao.jpg",
    "bap-cai-thao",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bắp cải thảo túi 1kg",
    13000/Từ 1-2 bắp,
    "images/products/bap-cai-thao-tui-1kg.jpg",
    "bap-cai-thao-tui-1kg",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bầu sao",
    9488/500g,
    "images/products/bau-sao.jpg",
    "bau-sao",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bí xanh",
    9975/500g,
    "images/products/bi-xanh.jpg",
    "bi-xanh",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mướp hương",
    11250/500g,
    "images/products/muop-huong.jpg",
    "muop-huong",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khoai tây 1kg",
    19000/1kg,
    "images/products/khoai-tay-1kg.jpg",
    "khoai-tay-1kg",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khoai tây",
    22500/1kg,
    "images/products/khoai-tay.jpg",
    "khoai-tay",
    1000,
    5,
    1,
    2,
    9
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm kim châm Thái Lan 150g",
    6500,
    "images/products/nam-kim-cham-thai-lan-150g.jpg",
    "nam-kim-cham-thai-lan-150g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm kim châm nội địa Trung 150g",
    5500,
    "images/products/nam-kim-cham-noi-ia-trung-150g.jpg",
    "nam-kim-cham-noi-ia-trung-150g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm đùi gà baby nội địa Trung 200g",
    14000/200g,
    "images/products/nam-ui-ga-baby-noi-ia-trung-200g.jpg",
    "nam-ui-ga-baby-noi-ia-trung-200g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm hải sản nội địa Trung 150g",
    9000,
    "images/products/nam-hai-san-noi-ia-trung-150g.jpg",
    "nam-hai-san-noi-ia-trung-150g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm kim châm Hàn Quốc 150g",
    14000,
    "images/products/nam-kim-cham-han-quoc-150g.jpg",
    "nam-kim-cham-han-quoc-150g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm linh chi trắng nội địa Trung 150g",
    15000,
    "images/products/nam-linh-chi-trang-noi-ia-trung-150g.jpg",
    "nam-linh-chi-trang-noi-ia-trung-150g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm đùi gà baby HQ 200g",
    33000/200g,
    "images/products/nam-ui-ga-baby-hq-200g.jpg",
    "nam-ui-ga-baby-hq-200g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm đùi gà 200g",
    30000/200g,
    "images/products/nam-ui-ga-200g.jpg",
    "nam-ui-ga-200g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm bào ngư trắng 300g",
    18500/300g,
    "images/products/nam-bao-ngu-trang-300g.jpg",
    "nam-bao-ngu-trang-300g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm bào ngư xám 300g",
    24000/300g,
    "images/products/nam-bao-ngu-xam-300g.jpg",
    "nam-bao-ngu-xam-300g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm linh chi nâu nội địa Trung 150g",
    15000,
    "images/products/nam-linh-chi-nau-noi-ia-trung-150g.jpg",
    "nam-linh-chi-nau-noi-ia-trung-150g",
    1000,
    5,
    1,
    2,
    10
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kim chi cải thảo Mr. Lee gói 300g",
    20000/300g,
    "images/products/kim-chi-cai-thao-mr-lee-goi-300g.jpg",
    "kim-chi-cai-thao-mr-lee-goi-300g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kim chi cải thảo cắt lát Bibigo hộp 500g",
    40000/500g,
    "images/products/kim-chi-cai-thao-cat-lat-bibigo-hop-500g.jpg",
    "kim-chi-cai-thao-cat-lat-bibigo-hop-500g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kim chi cải thảo Mama gói 400g",
    28000,
    "images/products/kim-chi-cai-thao-mama-goi-400g.jpg",
    "kim-chi-cai-thao-mama-goi-400g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kim chi cải thảo lên men Việt Hàn hộp 500g",
    36000,
    "images/products/kim-chi-cai-thao-len-men-viet-han-hop-500g.jpg",
    "kim-chi-cai-thao-len-men-viet-han-hop-500g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Măng le chua Vĩ Lâm gói 350g",
    24000/350g,
    "images/products/mang-le-chua-vi-lam-goi-350g.jpg",
    "mang-le-chua-vi-lam-goi-350g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cải chua Ngọc Phú gói 450g",
    24500/450g,
    "images/products/cai-chua-ngoc-phu-goi-450g.png",
    "cai-chua-ngoc-phu-goi-450g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bắp Mỹ tách hạt 250g",
    13425/250g,
    "images/products/bap-my-tach-hat-250g.jpg",
    "bap-my-tach-hat-250g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kim chi cải thảo cắt lát TH True Food 500g",
    54000,
    "images/products/kim-chi-cai-thao-cat-lat-th-true-food-500g.jpg",
    "kim-chi-cai-thao-cat-lat-th-true-food-500g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kim chi cải thảo cắt lát CJ Food Ông Kim's gói 300g",
    27000/300g,
    "images/products/kim-chi-cai-thao-cat-lat-cj-food-ong-kims-goi-300g.jpg",
    "kim-chi-cai-thao-cat-lat-cj-food-ong-kims-goi-300g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mắm cà pháo chua cay Sông Hương hũ 390g",
    38000,
    "images/products/mam-ca-phao-chua-cay-song-huong-hu-390g.jpg",
    "mam-ca-phao-chua-cay-song-huong-hu-390g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Me chua 250g",
    11925/250g,
    "images/products/me-chua-250g.jpg",
    "me-chua-250g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Măng luộc xé Vĩ Lâm gói 500g",
    32000,
    "images/products/mang-luoc-xe-vi-lam-goi-500g.png",
    "mang-luoc-xe-vi-lam-goi-500g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cải chua Vĩ Lâm gói 500g",
    29000,
    "images/products/cai-chua-vi-lam-goi-500g.jpg",
    "cai-chua-vi-lam-goi-500g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Me chua 68g",
    3600/68g,
    "images/products/me-chua-68g.jpg",
    "me-chua-68g",
    1000,
    5,
    1,
    2,
    11
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khoai tây Trần Gia/Mama Food 500g",
    30500,
    "images/products/khoai-tay-tran-giamama-food-500g.jpg",
    "khoai-tay-tran-giamama-food-500g",
    1000,
    5,
    1,
    2,
    12
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khoai tây cắt thẳng 10mm Meito 350g",
    30000,
    "images/products/khoai-tay-cat-thang-10mm-meito-350g.jpg",
    "khoai-tay-cat-thang-10mm-meito-350g",
    1000,
    5,
    1,
    2,
    12
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon bia Blanc 1664 330ml",
    410000,
    "images/products/thung-24-lon-bia-blanc-1664-330ml.jpg",
    "thung-24-lon-bia-blanc-1664-330ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon Bia Red Ruby 330ml",
    219000,
    "images/products/thung-24-lon-bia-red-ruby-330ml.jpg",
    "thung-24-lon-bia-red-ruby-330ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon bia Sapporo 330ml",
    353000,
    "images/products/thung-24-lon-bia-sapporo-330ml.jpg",
    "thung-24-lon-bia-sapporo-330ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bia Sapporo lon 500ml",
    27500,
    "images/products/bia-sapporo-lon-500ml.jpg",
    "bia-sapporo-lon-500ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon bia Heineken Sleek 330ml",
    445000,
    "images/products/thung-24-lon-bia-heineken-sleek-330ml.jpg",
    "thung-24-lon-bia-heineken-sleek-330ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon bia Sài Gòn Lager 330ml",
    260000,
    "images/products/thung-24-lon-bia-sai-gon-lager-330ml.jpg",
    "thung-24-lon-bia-sai-gon-lager-330ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon bia Heineken Bạc 330ml",
    449000,
    "images/products/thung-24-lon-bia-heineken-bac-330ml.jpg",
    "thung-24-lon-bia-heineken-bac-330ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon bia Tiger lon 250ml",
    268000,
    "images/products/thung-24-lon-bia-tiger-lon-250ml.jpg",
    "thung-24-lon-bia-tiger-lon-250ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon bia Tiger Bạc 250ml",
    286000,
    "images/products/thung-24-lon-bia-tiger-bac-250ml.jpg",
    "thung-24-lon-bia-tiger-bac-250ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon bia Heineken Silver 250ml",
    349000,
    "images/products/thung-24-lon-bia-heineken-silver-250ml.jpg",
    "thung-24-lon-bia-heineken-silver-250ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon bia Tiger Bạc 330ml",
    399000,
    "images/products/thung-24-lon-bia-tiger-bac-330ml.jpg",
    "thung-24-lon-bia-tiger-bac-330ml",
    1000,
    5,
    1,
    3,
    13
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai trà mật ong Boncha hương hoa lài 450ml",
    235000,
    "images/products/thung-24-chai-tra-mat-ong-boncha-huong-hoa-lai-450ml.jpg",
    "thung-24-chai-tra-mat-ong-boncha-huong-hoa-lai-450ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai trà mật ong Boncha vị chanh 450ml",
    235000,
    "images/products/thung-24-chai-tra-mat-ong-boncha-vi-chanh-450ml.jpg",
    "thung-24-chai-tra-mat-ong-boncha-vi-chanh-450ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai trà xanh chanh C2 225ml",
    95000,
    "images/products/thung-24-chai-tra-xanh-chanh-c2-225ml.jpg",
    "thung-24-chai-tra-xanh-chanh-c2-225ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai trà xanh táo C2 225ml",
    95000,
    "images/products/thung-24-chai-tra-xanh-tao-c2-225ml.jpg",
    "thung-24-chai-tra-xanh-tao-c2-225ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai trà đen đào C2 225ml",
    95000,
    "images/products/thung-24-chai-tra-en-ao-c2-225ml.jpg",
    "thung-24-chai-tra-en-ao-c2-225ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 chai trà đen vị đào C2 225ml",
    25000,
    "images/products/6-chai-tra-en-vi-ao-c2-225ml.jpg",
    "6-chai-tra-en-vi-ao-c2-225ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai trà mật ong Boncha vị ô long đào 450ml",
    235000,
    "images/products/thung-24-chai-tra-mat-ong-boncha-vi-o-long-ao-450ml.jpg",
    "thung-24-chai-tra-mat-ong-boncha-vi-o-long-ao-450ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai trà mật ong Boncha vị tắc 450ml",
    247000,
    "images/products/thung-24-chai-tra-mat-ong-boncha-vi-tac-450ml.jpg",
    "thung-24-chai-tra-mat-ong-boncha-vi-tac-450ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai trà mật ong Boncha việt quất 450ml",
    247000,
    "images/products/thung-24-chai-tra-mat-ong-boncha-viet-quat-450ml.jpg",
    "thung-24-chai-tra-mat-ong-boncha-viet-quat-450ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai hồng trà Tea365 hương đào 500ml",
    257000,
    "images/products/thung-24-chai-hong-tra-tea365-huong-ao-500ml.jpg",
    "thung-24-chai-hong-tra-tea365-huong-ao-500ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai trà Tea365 hương mật ong 500ml",
    257000,
    "images/products/thung-24-chai-tra-tea365-huong-mat-ong-500ml.jpg",
    "thung-24-chai-tra-tea365-huong-mat-ong-500ml",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà ô long xanh hương chanh Tea Plus 1 lít",
    20500,
    "images/products/tra-o-long-xanh-huong-chanh-tea-plus-1-lit.jpg",
    "tra-o-long-xanh-huong-chanh-tea-plus-1-lit",
    1000,
    5,
    1,
    3,
    14
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước ngọt Mirinda soda kem 320ml",
    195000,
    "images/products/thung-24-lon-nuoc-ngot-mirinda-soda-kem-320ml.jpg",
    "thung-24-lon-nuoc-ngot-mirinda-soda-kem-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước ngọt Coca Cola Zero 320ml",
    138000,
    "images/products/thung-24-lon-nuoc-ngot-coca-cola-zero-320ml.jpg",
    "thung-24-lon-nuoc-ngot-coca-cola-zero-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước ngọt Coca Cola 320ml",
    180000,
    "images/products/thung-24-lon-nuoc-ngot-coca-cola-320ml.jpg",
    "thung-24-lon-nuoc-ngot-coca-cola-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 lon nước ngọt Coca Cola Zero 320ml",
    39000,
    "images/products/6-lon-nuoc-ngot-coca-cola-zero-320ml.jpg",
    "6-lon-nuoc-ngot-coca-cola-zero-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước ngọt Sprite chanh 320ml",
    138000,
    "images/products/thung-24-lon-nuoc-ngot-sprite-chanh-320ml.jpg",
    "thung-24-lon-nuoc-ngot-sprite-chanh-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước ngọt Fanta soda kem 320ml",
    138000,
    "images/products/thung-24-lon-nuoc-ngot-fanta-soda-kem-320ml.jpg",
    "thung-24-lon-nuoc-ngot-fanta-soda-kem-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 lon nước ngọt Fanta hương dâu 320ml",
    56000,
    "images/products/6-lon-nuoc-ngot-fanta-huong-dau-320ml.jpg",
    "6-lon-nuoc-ngot-fanta-huong-dau-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước ngọt Fanta nho 320ml",
    138000,
    "images/products/thung-24-lon-nuoc-ngot-fanta-nho-320ml.jpg",
    "thung-24-lon-nuoc-ngot-fanta-nho-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước ngọt Fanta cam 320ml",
    138000,
    "images/products/thung-24-lon-nuoc-ngot-fanta-cam-320ml.jpg",
    "thung-24-lon-nuoc-ngot-fanta-cam-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon Pepsi Cola 320ml",
    256000,
    "images/products/thung-24-lon-pepsi-cola-320ml.jpg",
    "thung-24-lon-pepsi-cola-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước ngọt Pepsi không calo vị chanh 320ml",
    262000,
    "images/products/thung-24-lon-nuoc-ngot-pepsi-khong-calo-vi-chanh-320ml.jpg",
    "thung-24-lon-nuoc-ngot-pepsi-khong-calo-vi-chanh-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước ngọt 7 Up chanh 320ml",
    252000,
    "images/products/thung-24-lon-nuoc-ngot-7-up-chanh-320ml.jpg",
    "thung-24-lon-nuoc-ngot-7-up-chanh-320ml",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước ngọt Coca Cola giảm đường chai 1.5 lít",
    21000,
    "images/products/nuoc-ngot-coca-cola-giam-uong-chai-15-lit.jpg",
    "nuoc-ngot-coca-cola-giam-uong-chai-15-lit",
    1000,
    5,
    1,
    3,
    15
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon Sting dâu 320ml",
    230000,
    "images/products/thung-24-lon-sting-dau-320ml.jpg",
    "thung-24-lon-sting-dau-320ml",
    1000,
    5,
    1,
    3,
    16
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon Rockstar 250ml",
    225000,
    "images/products/thung-24-lon-rockstar-250ml.jpg",
    "thung-24-lon-rockstar-250ml",
    1000,
    5,
    1,
    3,
    16
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon Redbull 250ml",
    247000,
    "images/products/thung-24-lon-redbull-250ml.jpg",
    "thung-24-lon-redbull-250ml",
    1000,
    5,
    1,
    3,
    16
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon Redbull Thái kẽm và vitamin 250ml",
    215000,
    "images/products/thung-24-lon-redbull-thai-kem-va-vitamin-250ml.jpg",
    "thung-24-lon-redbull-thai-kem-va-vitamin-250ml",
    1000,
    5,
    1,
    3,
    16
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon Warrior dâu 325ml",
    168000,
    "images/products/thung-24-lon-warrior-dau-325ml.jpg",
    "thung-24-lon-warrior-dau-325ml",
    1000,
    5,
    1,
    3,
    16
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon Warrior nho 320ml",
    168000,
    "images/products/thung-24-lon-warrior-nho-320ml.jpg",
    "thung-24-lon-warrior-nho-320ml",
    1000,
    5,
    1,
    3,
    16
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước tăng lực Redbull Thái 250ml",
    276000,
    "images/products/thung-24-lon-nuoc-tang-luc-redbull-thai-250ml.jpg",
    "thung-24-lon-nuoc-tang-luc-redbull-thai-250ml",
    1000,
    5,
    1,
    3,
    16
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon Lipovitan mật ong 250ml",
    191000,
    "images/products/thung-24-lon-lipovitan-mat-ong-250ml.png",
    "thung-24-lon-lipovitan-mat-ong-250ml",
    1000,
    5,
    1,
    3,
    16
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai Number1 330ml",
    180000,
    "images/products/thung-24-chai-number1-330ml.jpg",
    "thung-24-chai-number1-330ml",
    1000,
    5,
    1,
    3,
    16
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon Monster xoài 355ml",
    471000,
    "images/products/thung-24-lon-monster-xoai-355ml.jpg",
    "thung-24-lon-monster-xoai-355ml",
    1000,
    5,
    1,
    3,
    16
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai nước tinh khiết Dasani 510ml",
    89000,
    "images/products/thung-24-chai-nuoc-tinh-khiet-dasani-510ml.jpg",
    "thung-24-chai-nuoc-tinh-khiet-dasani-510ml",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai nước khoáng Vikoda 500ml",
    95000,
    "images/products/thung-24-chai-nuoc-khoang-vikoda-500ml.jpg",
    "thung-24-chai-nuoc-khoang-vikoda-500ml",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai nước uống i-on kiềm I-on Life 450ml",
    110000,
    "images/products/thung-24-chai-nuoc-uong-i-on-kiem-i-on-life-450ml.jpg",
    "thung-24-chai-nuoc-uong-i-on-kiem-i-on-life-450ml",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai nước uống Tavi 500ml",
    69000,
    "images/products/thung-24-chai-nuoc-uong-tavi-500ml.jpg",
    "thung-24-chai-nuoc-uong-tavi-500ml",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 lon nước có ga Aquafina Soda 320ml",
    30000,
    "images/products/6-lon-nuoc-co-ga-aquafina-soda-320ml.jpg",
    "6-lon-nuoc-co-ga-aquafina-soda-320ml",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon nước có ga Aquafina Soda 320ml",
    120000,
    "images/products/thung-24-lon-nuoc-co-ga-aquafina-soda-320ml.jpg",
    "thung-24-lon-nuoc-co-ga-aquafina-soda-320ml",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 12 chai nước tinh khiết Aquafina 1.5 lít",
    105000,
    "images/products/thung-12-chai-nuoc-tinh-khiet-aquafina-15-lit.jpg",
    "thung-12-chai-nuoc-tinh-khiet-aquafina-15-lit",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 12 chai nước khoáng La Vie 1.5 lít",
    89000,
    "images/products/thung-12-chai-nuoc-khoang-la-vie-15-lit.jpg",
    "thung-12-chai-nuoc-khoang-la-vie-15-lit",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai nước khoáng La Vie vị dịu nhẹ 500ml",
    89000,
    "images/products/thung-24-chai-nuoc-khoang-la-vie-vi-diu-nhe-500ml.jpg",
    "thung-24-chai-nuoc-khoang-la-vie-vi-diu-nhe-500ml",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai nước khoáng La Vie 500ml",
    89000,
    "images/products/thung-24-chai-nuoc-khoang-la-vie-500ml.jpg",
    "thung-24-chai-nuoc-khoang-la-vie-500ml",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 12 chai nước khoáng Vikoda 1.5 lít",
    116000,
    "images/products/thung-12-chai-nuoc-khoang-vikoda-15-lit.jpg",
    "thung-12-chai-nuoc-khoang-vikoda-15-lit",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 4 chai nước khoáng Vikoda 5 lít",
    112000,
    "images/products/thung-4-chai-nuoc-khoang-vikoda-5-lit.jpg",
    "thung-4-chai-nuoc-khoang-vikoda-5-lit",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai nước khoáng Vikoda 350ml",
    85000,
    "images/products/thung-24-chai-nuoc-khoang-vikoda-350ml.jpg",
    "thung-24-chai-nuoc-khoang-vikoda-350ml",
    1000,
    5,
    1,
    3,
    17
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 chai nước yến đông trùng hạ thảo BestNest 180ml",
    390000,
    "images/products/thung-30-chai-nuoc-yen-ong-trung-ha-thao-bestnest-180ml.jpg",
    "thung-30-chai-nuoc-yen-ong-trung-ha-thao-bestnest-180ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 chai nước yến BestNest mật ong 180ml",
    390000,
    "images/products/thung-30-chai-nuoc-yen-bestnest-mat-ong-180ml.jpg",
    "thung-30-chai-nuoc-yen-bestnest-mat-ong-180ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp 6 hũ yến Song Yến Kids Dream 70ml",
    169000,
    "images/products/hop-6-hu-yen-song-yen-kids-dream-70ml.jpg",
    "hop-6-hu-yen-song-yen-kids-dream-70ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp 6 hũ nước yến sào Nhung huơu, nhân sâm Nest Gold ít đường 70ml",
    189000,
    "images/products/hop-6-hu-nuoc-yen-sao-nhung-huou-nhan-sam-nest-gold-it-uong-70ml.jpg",
    "hop-6-hu-nuoc-yen-sao-nhung-huou-nhan-sam-nest-gold-it-uong-70ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp 6 hũ yến Sài Gòn Anpha 18% hương sâm 70ml",
    189000,
    "images/products/hop-6-hu-yen-sai-gon-anpha-18-huong-sam-70ml.jpg",
    "hop-6-hu-yen-sai-gon-anpha-18-huong-sam-70ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp 6 hũ nước yến chưng sẵn Red Nest 70ml",
    169000,
    "images/products/hop-6-hu-nuoc-yen-chung-san-red-nest-70ml.jpg",
    "hop-6-hu-nuoc-yen-chung-san-red-nest-70ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp 6 hũ nước yến nguyên chất Song Yến 70ml",
    169000,
    "images/products/hop-6-hu-nuoc-yen-nguyen-chat-song-yen-70ml.jpg",
    "hop-6-hu-nuoc-yen-nguyen-chat-song-yen-70ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước yến chưng sẵn Red Nest 70ml",
    35000,
    "images/products/nuoc-yen-chung-san-red-nest-70ml.jpg",
    "nuoc-yen-chung-san-red-nest-70ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp 6 hũ tổ yến đông trùng hạ thảo Win'snest 70ml",
    229000,
    "images/products/hop-6-hu-to-yen-ong-trung-ha-thao-winsnest-70ml.jpg",
    "hop-6-hu-to-yen-ong-trung-ha-thao-winsnest-70ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 lon nước yến sào Nunest đường phèn 190ml",
    240000,
    "images/products/thung-30-lon-nuoc-yen-sao-nunest-uong-phen-190ml.jpg",
    "thung-30-lon-nuoc-yen-sao-nunest-uong-phen-190ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 6 lon nước yến sào Nunest đường phèn 190ml",
    49000,
    "images/products/loc-6-lon-nuoc-yen-sao-nunest-uong-phen-190ml.jpg",
    "loc-6-lon-nuoc-yen-sao-nunest-uong-phen-190ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước yến sào Nunest đường phèn 190ml",
    11600,
    "images/products/nuoc-yen-sao-nunest-uong-phen-190ml.jpg",
    "nuoc-yen-sao-nunest-uong-phen-190ml",
    1000,
    5,
    1,
    3,
    18
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước gạo Hàn Quốc OKF 1.5 lít",
    48000,
    "images/products/nuoc-gao-han-quoc-okf-15-lit.jpg",
    "nuoc-gao-han-quoc-okf-15-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai nước sương sáo A1 Food 280ml",
    205000,
    "images/products/thung-24-chai-nuoc-suong-sao-a1-food-280ml.jpg",
    "thung-24-chai-nuoc-suong-sao-a1-food-280ml",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước ép lựu Juss 1 lít",
    58000,
    "images/products/nuoc-ep-luu-juss-1-lit.jpg",
    "nuoc-ep-luu-juss-1-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước ép berry & trái cây Tipco Cool Fit 1 lít",
    39000,
    "images/products/nuoc-ep-berry--trai-cay-tipco-cool-fit-1-lit.jpg",
    "nuoc-ep-berry--trai-cay-tipco-cool-fit-1-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước ép kiwi & trái cây Tipco Cool Fit 1 lít",
    39000,
    "images/products/nuoc-ep-kiwi--trai-cay-tipco-cool-fit-1-lit.jpg",
    "nuoc-ep-kiwi--trai-cay-tipco-cool-fit-1-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước ép táo & trái cây Tipco 1 lít",
    58000,
    "images/products/nuoc-ep-tao--trai-cay-tipco-1-lit.jpg",
    "nuoc-ep-tao--trai-cay-tipco-1-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước cam có tép Teppy 1 lít",
    23000,
    "images/products/nuoc-cam-co-tep-teppy-1-lit.jpg",
    "nuoc-cam-co-tep-teppy-1-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước gạo rang Woongjin 1.5 lít",
    49000,
    "images/products/nuoc-gao-rang-woongjin-15-lit.jpg",
    "nuoc-gao-rang-woongjin-15-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước cam ép Twister Tropicana 1 lít",
    23000,
    "images/products/nuoc-cam-ep-twister-tropicana-1-lit.jpg",
    "nuoc-cam-ep-twister-tropicana-1-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước ép trái vải & nho trắng Malee 1 lít",
    65500,
    "images/products/nuoc-ep-trai-vai--nho-trang-malee-1-lit.jpg",
    "nuoc-ep-trai-vai--nho-trang-malee-1-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước ép nho Juss 1 lít",
    55000,
    "images/products/nuoc-ep-nho-juss-1-lit.jpg",
    "nuoc-ep-nho-juss-1-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước ép dâu tây và nho trắng Malee 1 lít",
    65500,
    "images/products/nuoc-ep-dau-tay-va-nho-trang-malee-1-lit.jpg",
    "nuoc-ep-dau-tay-va-nho-trang-malee-1-lit",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "24 chai nước dưa lưới Deedo Fruitku 450ml",
    290000,
    "images/products/24-chai-nuoc-dua-luoi-deedo-fruitku-450ml.jpg",
    "24-chai-nuoc-dua-luoi-deedo-fruitku-450ml",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 chai nước dưa lưới Deedo Fruitku 450ml",
    75000,
    "images/products/6-chai-nuoc-dua-luoi-deedo-fruitku-450ml.jpg",
    "6-chai-nuoc-dua-luoi-deedo-fruitku-450ml",
    1000,
    5,
    1,
    3,
    19
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 chai sữa trái cây Nutriboost bánh quy kem 297ml",
    40000,
    "images/products/6-chai-sua-trai-cay-nutriboost-banh-quy-kem-297ml.jpg",
    "6-chai-sua-trai-cay-nutriboost-banh-quy-kem-297ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 chai sữa trái cây Nutriboost dâu 297ml",
    40000,
    "images/products/6-chai-sua-trai-cay-nutriboost-dau-297ml.jpg",
    "6-chai-sua-trai-cay-nutriboost-dau-297ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 chai sữa trái cây Nutriboost cam 297ml",
    40000,
    "images/products/6-chai-sua-trai-cay-nutriboost-cam-297ml.jpg",
    "6-chai-sua-trai-cay-nutriboost-cam-297ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai sữa trái cây Nutriboost bánh quy kem 297ml",
    185000,
    "images/products/thung-24-chai-sua-trai-cay-nutriboost-banh-quy-kem-297ml.jpg",
    "thung-24-chai-sua-trai-cay-nutriboost-banh-quy-kem-297ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai sữa trái cây Nutriboost dâu 297ml",
    185000,
    "images/products/thung-24-chai-sua-trai-cay-nutriboost-dau-297ml.jpg",
    "thung-24-chai-sua-trai-cay-nutriboost-dau-297ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai sữa trái cây Nutriboost cam 297ml",
    185000,
    "images/products/thung-24-chai-sua-trai-cay-nutriboost-cam-297ml.jpg",
    "thung-24-chai-sua-trai-cay-nutriboost-cam-297ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa trái cây Kun dâu 180ml",
    270000,
    "images/products/thung-48-hop-sua-trai-cay-kun-dau-180ml.jpg",
    "thung-48-hop-sua-trai-cay-kun-dau-180ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa trái cây Kun nho 180ml",
    270000,
    "images/products/thung-48-hop-sua-trai-cay-kun-nho-180ml.jpg",
    "thung-48-hop-sua-trai-cay-kun-nho-180ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp thạch trái cây YoMost hương dâu 180ml",
    430000,
    "images/products/thung-48-hop-thach-trai-cay-yomost-huong-dau-180ml.jpg",
    "thung-48-hop-thach-trai-cay-yomost-huong-dau-180ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa trái cây Kun trái cây 180ml",
    270000,
    "images/products/thung-48-hop-sua-trai-cay-kun-trai-cay-180ml.jpg",
    "thung-48-hop-sua-trai-cay-kun-trai-cay-180ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa trái cây Kun cam 180ml",
    270000,
    "images/products/thung-48-hop-sua-trai-cay-kun-cam-180ml.jpg",
    "thung-48-hop-sua-trai-cay-kun-cam-180ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa trái cây Kun hương cam có thạch 170ml",
    357000,
    "images/products/thung-48-hop-sua-trai-cay-kun-huong-cam-co-thach-170ml.jpg",
    "thung-48-hop-sua-trai-cay-kun-huong-cam-co-thach-170ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa trái cây Kun hương cam có thạch 170ml",
    32500,
    "images/products/loc-4-hop-sua-trai-cay-kun-huong-cam-co-thach-170ml.jpg",
    "loc-4-hop-sua-trai-cay-kun-huong-cam-co-thach-170ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa trái cây Kun hương dâu có thạch 170ml",
    357000,
    "images/products/thung-48-hop-sua-trai-cay-kun-huong-dau-co-thach-170ml.jpg",
    "thung-48-hop-sua-trai-cay-kun-huong-dau-co-thach-170ml",
    1000,
    5,
    1,
    3,
    20
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rượu vang đỏ Sài Gòn Export 13% chai 750ml",
    95000,
    "images/products/ruou-vang-o-sai-gon-export-13-chai-750ml.jpg",
    "ruou-vang-o-sai-gon-export-13-chai-750ml",
    1000,
    5,
    1,
    3,
    22
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rượu vang đỏ Sài Gòn Classic 12.5% chai 750ml",
    95000,
    "images/products/ruou-vang-o-sai-gon-classic-125-chai-750ml.jpg",
    "ruou-vang-o-sai-gon-classic-125-chai-750ml",
    1000,
    5,
    1,
    3,
    22
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rượu vang đỏ Passion 13.5% 3 lít",
    415000,
    "images/products/ruou-vang-o-passion-135-3-lit.jpg",
    "ruou-vang-o-passion-135-3-lit",
    1000,
    5,
    1,
    3,
    22
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rượu soju Heejin vị việt quất 12% chai 360ml",
    46500,
    "images/products/ruou-soju-heejin-vi-viet-quat-12-chai-360ml.jpg",
    "ruou-soju-heejin-vi-viet-quat-12-chai-360ml",
    1000,
    5,
    1,
    3,
    22
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rượu soju Heejin vị đào 12% chai 360ml",
    46500,
    "images/products/ruou-soju-heejin-vi-ao-12-chai-360ml.jpg",
    "ruou-soju-heejin-vi-ao-12-chai-360ml",
    1000,
    5,
    1,
    3,
    22
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rượu soju Heejin vị dâu 12% chai 360ml",
    46500,
    "images/products/ruou-soju-heejin-vi-dau-12-chai-360ml.jpg",
    "ruou-soju-heejin-vi-dau-12-chai-360ml",
    1000,
    5,
    1,
    3,
    22
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rượu soju Rice+ hương dứa 12.5% 360ml",
    46500,
    "images/products/ruou-soju-rice-huong-dua-125-360ml.jpg",
    "ruou-soju-rice-huong-dua-125-360ml",
    1000,
    5,
    1,
    3,
    22
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rượu soju Rice+ hương bưởi 12.5% chai 360ml",
    46500,
    "images/products/ruou-soju-rice-huong-buoi-125-chai-360ml.jpg",
    "ruou-soju-rice-huong-buoi-125-chai-360ml",
    1000,
    5,
    1,
    3,
    22
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rượu soju Rice+ vải 12.5% 360ml",
    46500,
    "images/products/ruou-soju-rice-vai-125-360ml.jpg",
    "ruou-soju-rice-vai-125-360ml",
    1000,
    5,
    1,
    3,
    22
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rượu soju Rice+ đào 12.5% chai 360ml",
    46500,
    "images/products/ruou-soju-rice-ao-125-chai-360ml.jpg",
    "ruou-soju-rice-ao-125-chai-360ml",
    1000,
    5,
    1,
    3,
    22
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa hòa tan K Coffee Delight 3 in 1 170g",
    30000,
    "images/products/ca-phe-sua-hoa-tan-k-coffee-delight-3-in-1-170g.jpg",
    "ca-phe-sua-hoa-tan-k-coffee-delight-3-in-1-170g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa nóng MacCoffee Café Phố 3 in 1 160g",
    39000,
    "images/products/ca-phe-sua-nong-maccoffee-cafe-pho-3-in-1-160g.jpg",
    "ca-phe-sua-nong-maccoffee-cafe-pho-3-in-1-160g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa VinaCafé Chất 240g",
    43000,
    "images/products/ca-phe-sua-vinacafe-chat-240g.jpg",
    "ca-phe-sua-vinacafe-chat-240g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa VinaCafé Gold Original 360g",
    47000,
    "images/products/ca-phe-sua-vinacafe-gold-original-360g.jpg",
    "ca-phe-sua-vinacafe-gold-original-360g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa đá NesCafé nhân đôi sánh quyện 240g",
    44000,
    "images/products/ca-phe-sua-a-nescafe-nhan-oi-sanh-quyen-240g.jpg",
    "ca-phe-sua-a-nescafe-nhan-oi-sanh-quyen-240g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa đá Việt Nam Wake Up 240g",
    50000,
    "images/products/ca-phe-sua-a-viet-nam-wake-up-240g.jpg",
    "ca-phe-sua-a-viet-nam-wake-up-240g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa G7 3in1 800g",
    189000,
    "images/products/ca-phe-sua-g7-3in1-800g.jpg",
    "ca-phe-sua-g7-3in1-800g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa NesCafé 3 in 1 đậm đà hài hòa 736g",
    156000,
    "images/products/ca-phe-sua-nescafe-3-in-1-am-a-hai-hoa-736g.jpg",
    "ca-phe-sua-nescafe-3-in-1-am-a-hai-hoa-736g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa đậm vị NesCafé 3in1 736g",
    156000,
    "images/products/ca-phe-sua-am-vi-nescafe-3in1-736g.jpg",
    "ca-phe-sua-am-vi-nescafe-3in1-736g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê MacCoffee Café Phố Gold 3in1 290g",
    63000/290g,
    "images/products/ca-phe-maccoffee-cafe-pho-gold-3in1-290g.jpg",
    "ca-phe-maccoffee-cafe-pho-gold-3in1-290g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp 5 gói nước cốt cà phê sữa NesCafé 75ml",
    51000,
    "images/products/hop-5-goi-nuoc-cot-ca-phe-sua-nescafe-75ml.jpg",
    "hop-5-goi-nuoc-cot-ca-phe-sua-nescafe-75ml",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp 5 gói nước cốt cà phê đen NesCafé 75ml",
    51000,
    "images/products/hop-5-goi-nuoc-cot-ca-phe-en-nescafe-75ml.jpg",
    "hop-5-goi-nuoc-cot-ca-phe-en-nescafe-75ml",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê muối Ông Bầu 220g",
    56000,
    "images/products/ca-phe-muoi-ong-bau-220g.jpg",
    "ca-phe-muoi-ong-bau-220g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa đá Ông Bầu 240g",
    53000,
    "images/products/ca-phe-sua-a-ong-bau-240g.jpg",
    "ca-phe-sua-a-ong-bau-240g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa VinaCafé Gold Original 800g",
    129000,
    "images/products/ca-phe-sua-vinacafe-gold-original-800g.jpg",
    "ca-phe-sua-vinacafe-gold-original-800g",
    1000,
    5,
    1,
    3,
    23
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà sữa trân châu 3 in 1 Wangcha 400g",
    25000,
    "images/products/tra-sua-tran-chau-3-in-1-wangcha-400g.jpg",
    "tra-sua-tran-chau-3-in-1-wangcha-400g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà sữa trân châu Deli Thái đỏ hộp 240g",
    24500,
    "images/products/tra-sua-tran-chau-deli-thai-o-hop-240g.jpg",
    "tra-sua-tran-chau-deli-thai-o-hop-240g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà vải hạt chia Gu Việt hộp 200g",
    29000,
    "images/products/tra-vai-hat-chia-gu-viet-hop-200g.jpg",
    "tra-vai-hat-chia-gu-viet-hop-200g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà xoài hạt chia Gu Việt hộp 200g",
    29000,
    "images/products/tra-xoai-hat-chia-gu-viet-hop-200g.jpg",
    "tra-xoai-hat-chia-gu-viet-hop-200g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà sữa trân châu đường đen Hillway hộp 232g",
    35000,
    "images/products/tra-sua-tran-chau-uong-en-hillway-hop-232g.jpg",
    "tra-sua-tran-chau-uong-en-hillway-hop-232g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà mãng cầu Wil hộp 140g",
    29000,
    "images/products/tra-mang-cau-wil-hop-140g.jpg",
    "tra-mang-cau-wil-hop-140g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà sữa Lipton vị truyền thống hộp 240g",
    95000,
    "images/products/tra-sua-lipton-vi-truyen-thong-hop-240g.jpg",
    "tra-sua-lipton-vi-truyen-thong-hop-240g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà ô long túi lọc Phúc Long hộp 50g",
    36000,
    "images/products/tra-o-long-tui-loc-phuc-long-hop-50g.jpg",
    "tra-o-long-tui-loc-phuc-long-hop-50g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà lài túi lọc Phúc Long hộp 50g",
    35000,
    "images/products/tra-lai-tui-loc-phuc-long-hop-50g.jpg",
    "tra-lai-tui-loc-phuc-long-hop-50g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà sữa trân châu đường đen Ban Milk Tea 260g",
    33000,
    "images/products/tra-sua-tran-chau-uong-en-ban-milk-tea-260g.jpg",
    "tra-sua-tran-chau-uong-en-ban-milk-tea-260g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Trà sữa ô long nướng Ban Milk Tea 260g",
    33000,
    "images/products/tra-sua-o-long-nuong-ban-milk-tea-260g.jpg",
    "tra-sua-o-long-nuong-ban-milk-tea-260g",
    1000,
    5,
    1,
    3,
    24
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê Trung Nguyên Nâu sức sống đại ngàn 500g",
    120000,
    "images/products/ca-phe-trung-nguyen-nau-suc-song-ai-ngan-500g.jpg",
    "ca-phe-trung-nguyen-nau-suc-song-ai-ngan-500g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê rang xay Ông Bầu OB 1 đậm đà 250g",
    85500,
    "images/products/ca-phe-rang-xay-ong-bau-ob-1-am-a-250g.jpg",
    "ca-phe-rang-xay-ong-bau-ob-1-am-a-250g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê rang xay Ông Bầu OB 2 hài hòa 250g",
    96000,
    "images/products/ca-phe-rang-xay-ong-bau-ob-2-hai-hoa-250g.jpg",
    "ca-phe-rang-xay-ong-bau-ob-2-hai-hoa-250g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê Phương Vy Moka 500g",
    92500,
    "images/products/ca-phe-phuong-vy-moka-500g.jpg",
    "ca-phe-phuong-vy-moka-500g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê Highlands truyền thống 200g",
    88500,
    "images/products/ca-phe-highlands-truyen-thong-200g.jpg",
    "ca-phe-highlands-truyen-thong-200g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê Mê Trang MC 1 500g",
    115000,
    "images/products/ca-phe-me-trang-mc-1-500g.jpg",
    "ca-phe-me-trang-mc-1-500g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê Mê Trang Robusta 500g",
    81000,
    "images/products/ca-phe-me-trang-robusta-500g.jpg",
    "ca-phe-me-trang-robusta-500g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê Trung Nguyên S chinh phục thành công 100g",
    18600,
    "images/products/ca-phe-trung-nguyen-s-chinh-phuc-thanh-cong-100g.jpg",
    "ca-phe-trung-nguyen-s-chinh-phuc-thanh-cong-100g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê Trung Nguyên sáng tạo 5 340g",
    184000,
    "images/products/ca-phe-trung-nguyen-sang-tao-5-340g.jpg",
    "ca-phe-trung-nguyen-sang-tao-5-340g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê Trung Nguyên sáng tạo 3 340g",
    132000,
    "images/products/ca-phe-trung-nguyen-sang-tao-3-340g.jpg",
    "ca-phe-trung-nguyen-sang-tao-3-340g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê Trung Nguyên S chinh phục thành công 500g",
    86000,
    "images/products/ca-phe-trung-nguyen-s-chinh-phuc-thanh-cong-500g.jpg",
    "ca-phe-trung-nguyen-s-chinh-phuc-thanh-cong-500g",
    1000,
    5,
    1,
    3,
    25
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 lon cà phê sữa Highlands 235ml",
    76500,
    "images/products/6-lon-ca-phe-sua-highlands-235ml.jpg",
    "6-lon-ca-phe-sua-highlands-235ml",
    1000,
    5,
    1,
    3,
    26
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 lon cà phê sữa Highlands 185ml",
    72500,
    "images/products/6-lon-ca-phe-sua-highlands-185ml.jpg",
    "6-lon-ca-phe-sua-highlands-185ml",
    1000,
    5,
    1,
    3,
    26
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon cà phê sữa Boss 180ml",
    286000,
    "images/products/thung-24-lon-ca-phe-sua-boss-180ml.jpg",
    "thung-24-lon-ca-phe-sua-boss-180ml",
    1000,
    5,
    1,
    3,
    26
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 lon cà phê sữa Boss 180ml",
    73500,
    "images/products/6-lon-ca-phe-sua-boss-180ml.jpg",
    "6-lon-ca-phe-sua-boss-180ml",
    1000,
    5,
    1,
    3,
    26
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa Boss 180ml",
    12600,
    "images/products/ca-phe-sua-boss-180ml.jpg",
    "ca-phe-sua-boss-180ml",
    1000,
    5,
    1,
    3,
    26
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 lon cà phê sữa Highlands 185ml",
    286000,
    "images/products/thung-24-lon-ca-phe-sua-highlands-185ml.jpg",
    "thung-24-lon-ca-phe-sua-highlands-185ml",
    1000,
    5,
    1,
    3,
    26
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa Highlands 185ml",
    13200,
    "images/products/ca-phe-sua-highlands-185ml.jpg",
    "ca-phe-sua-highlands-185ml",
    1000,
    5,
    1,
    3,
    26
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà phê sữa Highlands 235ml",
    15800,
    "images/products/ca-phe-sua-highlands-235ml.jpg",
    "ca-phe-sua-highlands-235ml",
    1000,
    5,
    1,
    3,
    26
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 bịch sữa dinh dưỡng có đường Vinamilk Happy Star 220ml",
    375000,
    "images/products/thung-48-bich-sua-dinh-duong-co-uong-vinamilk-happy-star-220ml.jpg",
    "thung-48-bich-sua-dinh-duong-co-uong-vinamilk-happy-star-220ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa dinh dưỡng Nuvi có đường 180ml",
    390000,
    "images/products/thung-48-hop-sua-dinh-duong-nuvi-co-uong-180ml.jpg",
    "thung-48-hop-sua-dinh-duong-nuvi-co-uong-180ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa tươi Dutch Lady ít đường 180ml",
    321000,
    "images/products/thung-48-hop-sua-tuoi-dutch-lady-it-uong-180ml.jpg",
    "thung-48-hop-sua-tuoi-dutch-lady-it-uong-180ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 bịch sữa tươi có đường Dutch Lady Cao Khoẻ 180ml",
    140000,
    "images/products/thung-24-bich-sua-tuoi-co-uong-dutch-lady-cao-khoe-180ml.jpg",
    "thung-24-bich-sua-tuoi-co-uong-dutch-lady-cao-khoe-180ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa tươi Kun 100% Sữa tươi 180ml",
    352000,
    "images/products/thung-48-hop-sua-tuoi-kun-100-sua-tuoi-180ml.jpg",
    "thung-48-hop-sua-tuoi-kun-100-sua-tuoi-180ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 12 hộp sữa tươi có đường Dutch Lady 965ml",
    412000,
    "images/products/thung-12-hop-sua-tuoi-co-uong-dutch-lady-965ml.jpg",
    "thung-12-hop-sua-tuoi-co-uong-dutch-lady-965ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 bịch sữa ít đường Dutch Lady 180ml",
    175000,
    "images/products/thung-24-bich-sua-it-uong-dutch-lady-180ml.jpg",
    "thung-24-bich-sua-it-uong-dutch-lady-180ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa tươi có đường Dutch Lady 180ml",
    375000,
    "images/products/thung-48-hop-sua-tuoi-co-uong-dutch-lady-180ml.jpg",
    "thung-48-hop-sua-tuoi-co-uong-dutch-lady-180ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 bịch sữa dinh dưỡng có đường Nutimilk 220ml",
    375000,
    "images/products/thung-48-bich-sua-dinh-duong-co-uong-nutimilk-220ml.jpg",
    "thung-48-bich-sua-dinh-duong-co-uong-nutimilk-220ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa tươi Vinamilk 100% ít đường 180ml",
    353000,
    "images/products/thung-48-hop-sua-tuoi-vinamilk-100-it-uong-180ml.jpg",
    "thung-48-hop-sua-tuoi-vinamilk-100-it-uong-180ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 12 hộp sữa tươi Vinamilk 100% không đường 1 lít",
    380000,
    "images/products/thung-12-hop-sua-tuoi-vinamilk-100-khong-uong-1-lit.jpg",
    "thung-12-hop-sua-tuoi-vinamilk-100-khong-uong-1-lit",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa tươi ít đường TH true MILK 180ml",
    418000,
    "images/products/thung-48-hop-sua-tuoi-it-uong-th-true-milk-180ml.jpg",
    "thung-48-hop-sua-tuoi-it-uong-th-true-milk-180ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa tươi Vinamilk 100% có đường 180ml",
    353000,
    "images/products/thung-48-hop-sua-tuoi-vinamilk-100-co-uong-180ml.jpg",
    "thung-48-hop-sua-tuoi-vinamilk-100-co-uong-180ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 bịch sữa tươi ít đường TH true MILK 220ml",
    370000,
    "images/products/thung-48-bich-sua-tuoi-it-uong-th-true-milk-220ml.jpg",
    "thung-48-bich-sua-tuoi-it-uong-th-true-milk-220ml",
    1000,
    5,
    1,
    4,
    28
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "48 hộp sữa lúa mạch Milo ít đường 180ml",
    345000,
    "images/products/48-hop-sua-lua-mach-milo-it-uong-180ml.jpg",
    "48-hop-sua-lua-mach-milo-it-uong-180ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "48 hộp sữa lúa mạch Milo 180ml",
    345000,
    "images/products/48-hop-sua-lua-mach-milo-180ml.jpg",
    "48-hop-sua-lua-mach-milo-180ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "48 hộp sữa Ovaltine canxi 180ml",
    315000,
    "images/products/48-hop-sua-ovaltine-canxi-180ml.jpg",
    "48-hop-sua-ovaltine-canxi-180ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa lúa mạch Nuvi cacao 180ml",
    265000,
    "images/products/thung-48-hop-sua-lua-mach-nuvi-cacao-180ml.jpg",
    "thung-48-hop-sua-lua-mach-nuvi-cacao-180ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "24 túi sữa lúa mạch Lof Kun socola 110ml",
    126000,
    "images/products/24-tui-sua-lua-mach-lofkun-socola-110ml.jpg",
    "24-tui-sua-lua-mach-lofkun-socola-110ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "48 hộp sữa Ovaltine canxi 110ml",
    211000,
    "images/products/48-hop-sua-ovaltine-canxi-110ml.jpg",
    "48-hop-sua-ovaltine-canxi-110ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "48 hộp sữa lúa mạch Milo ít đường 110ml",
    230000,
    "images/products/48-hop-sua-lua-mach-milo-it-uong-110ml.jpg",
    "48-hop-sua-lua-mach-milo-it-uong-110ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "48 hộp sữa lúa mạch Lof Kun socola 180ml",
    308000,
    "images/products/48-hop-sua-lua-mach-lof-kun-socola-180ml.jpg",
    "48-hop-sua-lua-mach-lof-kun-socola-180ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "48 hộp sữa lúa mạch Lof Kun có thạch 170ml",
    357000,
    "images/products/48-hop-sua-lua-mach-lof-kun-co-thach-170ml.jpg",
    "48-hop-sua-lua-mach-lof-kun-co-thach-170ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "48 hộp sữa ca cao có thạch Nuvi 170ml",
    375000,
    "images/products/48-hop-sua-ca-cao-co-thach-nuvi-170ml.jpg",
    "48-hop-sua-ca-cao-co-thach-nuvi-170ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "48 hộp sữa lúa mạch Milo 110ml",
    230000,
    "images/products/48-hop-sua-lua-mach-milo-110ml.jpg",
    "48-hop-sua-lua-mach-milo-110ml",
    1000,
    5,
    1,
    4,
    29
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 chai sữa chua uống  dâu Lof Kun 85ml",
    176000,
    "images/products/thung-48-chai-sua-chua-uong-dau-lof-kun-85ml.jpg",
    "thung-48-chai-sua-chua-uong-dau-lof-kun-85ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 chai sữa chua SuSu cam 80ml",
    185000,
    "images/products/thung-48-chai-sua-chua-susu-cam-80ml.jpg",
    "thung-48-chai-sua-chua-susu-cam-80ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 túi sữa chua Lof Kun kem dâu 110ml",
    126000,
    "images/products/thung-24-tui-sua-chua-lof-kun-kem-dau-110ml.jpg",
    "thung-24-tui-sua-chua-lof-kun-kem-dau-110ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai sữa chua uống Nutriboost cam 170ml",
    144000,
    "images/products/thung-24-chai-sua-chua-uong-nutriboost-cam-170ml.jpg",
    "thung-24-chai-sua-chua-uong-nutriboost-cam-170ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai sữa chua uống Nutriboost việt quất 170ml",
    144000,
    "images/products/thung-24-chai-sua-chua-uong-nutriboost-viet-quat-170ml.jpg",
    "thung-24-chai-sua-chua-uong-nutriboost-viet-quat-170ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 chai sữa chua uống Nutriboost việt quất 170ml",
    25000,
    "images/products/loc-4-chai-sua-chua-uong-nutriboost-viet-quat-170ml.jpg",
    "loc-4-chai-sua-chua-uong-nutriboost-viet-quat-170ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa chua YoMost cam 170ml",
    343000,
    "images/products/thung-48-hop-sua-chua-yomost-cam-170ml.jpg",
    "thung-48-hop-sua-chua-yomost-cam-170ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa chua Lof Kun cam 180ml",
    32500,
    "images/products/loc-4-hop-sua-chua-lof-kun-cam-180ml.jpg",
    "loc-4-hop-sua-chua-lof-kun-cam-180ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa chua YoMost cam 170ml",
    30500,
    "images/products/loc-4-hop-sua-chua-yomost-cam-170ml.jpg",
    "loc-4-hop-sua-chua-yomost-cam-170ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 28 gói sữa chua tổ yến Nestlé Gấu 75ml",
    190000,
    "images/products/thung-28-goi-sua-chua-to-yen-nestle-gau-75ml.jpg",
    "thung-28-goi-sua-chua-to-yen-nestle-gau-75ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa chua YoMost bạc hà và việt quất 170ml",
    343000,
    "images/products/thung-48-hop-sua-chua-yomost-bac-ha-va-viet-quat-170ml.jpg",
    "thung-48-hop-sua-chua-yomost-bac-ha-va-viet-quat-170ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 chai sữa chua uống Nutriboost cam 170ml",
    25000,
    "images/products/loc-4-chai-sua-chua-uong-nutriboost-cam-170ml.jpg",
    "loc-4-chai-sua-chua-uong-nutriboost-cam-170ml",
    1000,
    5,
    1,
    4,
    30
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 36 hộp sữa đậu nành Fami Canxi ít đường 200ml",
    145000,
    "images/products/thung-36-hop-sua-au-nanh-fami-canxi-it-uong-200ml.jpg",
    "thung-36-hop-sua-au-nanh-fami-canxi-it-uong-200ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa đậu nành tươi Vinamilk 180ml",
    232000,
    "images/products/thung-48-hop-sua-au-nanh-tuoi-vinamilk-180ml.jpg",
    "thung-48-hop-sua-au-nanh-tuoi-vinamilk-180ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 36 hộp sữa đậu nành không đường Fami Green Soy 180ml",
    155000,
    "images/products/thung-36-hop-sua-au-nanh-khong-uong-fami-green-soy-180ml.jpg",
    "thung-36-hop-sua-au-nanh-khong-uong-fami-green-soy-180ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 36 hộp sữa đậu nành rất ít đường Fami Green Soy 180ml",
    155000,
    "images/products/thung-36-hop-sua-au-nanh-rat-it-uong-fami-green-soy-180ml.jpg",
    "thung-36-hop-sua-au-nanh-rat-it-uong-fami-green-soy-180ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai sữa đậu nành Number1 Soya Canxi 268ml",
    215000,
    "images/products/thung-24-chai-sua-au-nanh-number1-soya-canxi-268ml.jpg",
    "thung-24-chai-sua-au-nanh-number1-soya-canxi-268ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 36 hộp sữa đậu nành Fami Canxi cà phê 200ml",
    145000,
    "images/products/thung-36-hop-sua-au-nanh-fami-canxi-ca-phe-200ml.jpg",
    "thung-36-hop-sua-au-nanh-fami-canxi-ca-phe-200ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa đậu nành Fami Canxi 1 lít",
    23000,
    "images/products/sua-au-nanh-fami-canxi-1-lit.jpg",
    "sua-au-nanh-fami-canxi-1-lit",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 40 bịch sữa đậu nành Fami Canxi ít đường 200ml",
    150000,
    "images/products/thung-40-bich-sua-au-nanh-fami-canxi-it-uong-200ml.jpg",
    "thung-40-bich-sua-au-nanh-fami-canxi-it-uong-200ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 40 bịch sữa đậu nành Fami Canxi 200ml",
    150000,
    "images/products/thung-40-bich-sua-au-nanh-fami-canxi-200ml.jpg",
    "thung-40-bich-sua-au-nanh-fami-canxi-200ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "48 hộp sữa yến mạch TH True Oat vị tự nhiên 180ml",
    485000,
    "images/products/48-hop-sua-yen-mach-th-true-oat-vi-tu-nhien-180ml.jpg",
    "48-hop-sua-yen-mach-th-true-oat-vi-tu-nhien-180ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 36 hộp sữa đậu nành Fami nguyên chất 200ml",
    145000,
    "images/products/thung-36-hop-sua-au-nanh-fami-nguyen-chat-200ml.jpg",
    "thung-36-hop-sua-au-nanh-fami-nguyen-chat-200ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 40 bịch sữa đậu nành Fami ít đường 200ml",
    150000,
    "images/products/thung-40-bich-sua-au-nanh-fami-it-uong-200ml.jpg",
    "thung-40-bich-sua-au-nanh-fami-it-uong-200ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 40 bịch sữa đậu nành Fami nguyên chất 200ml",
    150000,
    "images/products/thung-40-bich-sua-au-nanh-fami-nguyen-chat-200ml.jpg",
    "thung-40-bich-sua-au-nanh-fami-nguyen-chat-200ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 36 bịch sữa đậu nành Nuti 200ml",
    157000,
    "images/products/thung-36-bich-sua-au-nanh-nuti-200ml.jpg",
    "thung-36-bich-sua-au-nanh-nuti-200ml",
    1000,
    5,
    1,
    4,
    32
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đặc Lamosa lon 1kg",
    49500,
    "images/products/kem-ac-lamosa-lon-1kg.jpg",
    "kem-ac-lamosa-lon-1kg",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đặc Vega có đường 1kg",
    49500,
    "images/products/kem-ac-vega-co-uong-1kg.jpg",
    "kem-ac-vega-co-uong-1kg",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đặc Ngôi sao Phương Nam xanh lá hộp 1.284kg",
    67500,
    "images/products/kem-ac-ngoi-sao-phuong-nam-xanh-la-hop-1284kg.jpg",
    "kem-ac-ngoi-sao-phuong-nam-xanh-la-hop-1284kg",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đặc Ngôi sao Phương Nam xanh lá hộp 380g",
    20500,
    "images/products/kem-ac-ngoi-sao-phuong-nam-xanh-la-hop-380g.jpg",
    "kem-ac-ngoi-sao-phuong-nam-xanh-la-hop-380g",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đặc Vinamilk Tài Lộc lon 380g",
    16300,
    "images/products/kem-ac-vinamilk-tai-loc-lon-380g.jpg",
    "kem-ac-vinamilk-tai-loc-lon-380g",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đặc Ngôi sao Phương Nam xanh lá lon 380g",
    20500,
    "images/products/kem-ac-ngoi-sao-phuong-nam-xanh-la-lon-380g.jpg",
    "kem-ac-ngoi-sao-phuong-nam-xanh-la-lon-380g",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đặc có đường Dutch Lady túi 280g",
    21500,
    "images/products/kem-ac-co-uong-dutch-lady-tui-280g.jpg",
    "kem-ac-co-uong-dutch-lady-tui-280g",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Creamer đặc socola Ông Thọ tuýp 165g",
    20000,
    "images/products/creamer-ac-socola-ong-tho-tuyp-165g.jpg",
    "creamer-ac-socola-ong-tho-tuyp-165g",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa đặc Ông Thọ đỏ tuýp 165g",
    19900,
    "images/products/sua-ac-ong-tho-o-tuyp-165g.jpg",
    "sua-ac-ong-tho-o-tuyp-165g",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa đặc Ông Thọ nhãn xanh hộp 380g",
    27000,
    "images/products/sua-ac-ong-tho-nhan-xanh-hop-380g.jpg",
    "sua-ac-ong-tho-nhan-xanh-hop-380g",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đặc Hoàn Hảo hộp 1.27kg",
    67500,
    "images/products/kem-ac-hoan-hao-hop-127kg.jpg",
    "kem-ac-hoan-hao-hop-127kg",
    1000,
    5,
    1,
    4,
    33
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ngũ cốc MacCereal Macfito 500g",
    49000,
    "images/products/ngu-coc-maccereal-macfito-500g.jpg",
    "ngu-coc-maccereal-macfito-500g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột ngũ cốc Calsome vị vanila 500g",
    53000/500g,
    "images/products/bot-ngu-coc-calsome-vi-vanila-500g.jpg",
    "bot-ngu-coc-calsome-vi-vanila-500g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột ngũ cốc Calsome chocolate 500g",
    53000/500g,
    "images/products/bot-ngu-coc-calsome-chocolate-500g.jpg",
    "bot-ngu-coc-calsome-chocolate-500g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ngũ cốc VinaCafé B'fast Kachi 500g",
    55000,
    "images/products/ngu-coc-vinacafe-bfast-kachi-500g.jpg",
    "ngu-coc-vinacafe-bfast-kachi-500g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ngũ cốc ít đường Golden Xuân An 400g",
    69000,
    "images/products/ngu-coc-it-uong-golden-xuan-an-400g.jpg",
    "ngu-coc-it-uong-golden-xuan-an-400g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ngũ cốc óc chó & mè đen Xuân An 400g",
    65000,
    "images/products/ngu-coc-oc-cho--me-en-xuan-an-400g.jpg",
    "ngu-coc-oc-cho--me-en-xuan-an-400g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ngũ cốc yến mạch hạnh nhân & hạt chia Xuân An 400g",
    82000,
    "images/products/ngu-coc-yen-mach-hanh-nhan--hat-chia-xuan-an-400g.jpg",
    "ngu-coc-yen-mach-hanh-nhan--hat-chia-xuan-an-400g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ngũ cốc yến mạch MacCereal ít đường 480g",
    78000/480g,
    "images/products/ngu-coc-yen-mach-maccereal-it-uong-480g.jpg",
    "ngu-coc-yen-mach-maccereal-it-uong-480g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Yến mạch hạt chia Best Choice 240g",
    50500/240g,
    "images/products/yen-mach-hat-chia-best-choice-240g.jpg",
    "yen-mach-hat-chia-best-choice-240g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ngũ cốc gạo lứt Best Choice 450g",
    90000/450g,
    "images/products/ngu-coc-gao-lut-best-choice-450g.jpg",
    "ngu-coc-gao-lut-best-choice-450g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Yến mạch gạo lứt Yumfood 210g",
    44500/210g,
    "images/products/yen-mach-gao-lut-yumfood-210g.jpg",
    "yen-mach-gao-lut-yumfood-210g",
    1000,
    5,
    1,
    4,
    34
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích Five Star Red C.P gói 200g",
    19500/200g,
    "images/products/xuc-xich-five-star-red-cp-goi-200g.png",
    "xuc-xich-five-star-red-cp-goi-200g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích tiệt trùng Ponnie gói 280g",
    28500,
    "images/products/xuc-xich-tiet-trung-ponnie-goi-280g.png",
    "xuc-xich-tiet-trung-ponnie-goi-280g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích heo tiệt trùng LC FOODS gói 200g",
    23000/200g,
    "images/products/xuc-xich-heo-tiet-trung-lc-foods-goi-200g.png",
    "xuc-xich-heo-tiet-trung-lc-foods-goi-200g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích tiệt trùng cay C.P cây 60g",
    11500/60g,
    "images/products/xuc-xich-tiet-trung-cay-cp-cay-60g.png",
    "xuc-xich-tiet-trung-cay-cp-cay-60g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích heo tiệt trùng C.P gói 200g",
    26000/200g,
    "images/products/xuc-xich-heo-tiet-trung-cp-goi-200g.png",
    "xuc-xich-heo-tiet-trung-cp-goi-200g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích heo dinh dưỡng Vissan gói 175g",
    21500/175g,
    "images/products/xuc-xich-heo-dinh-duong-vissan-goi-175g.png",
    "xuc-xich-heo-dinh-duong-vissan-goi-175g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích ăn liền handy đức việt bị bò O'food 192g",
    20000,
    "images/products/xuc-xich-an-lien-handy-uc-viet-bi-bo-ofood-192g.png",
    "xuc-xich-an-lien-handy-uc-viet-bi-bo-ofood-192g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích ăn liền handy đức việt vị heo O'food 192g",
    20000,
    "images/products/xuc-xich-an-lien-handy-uc-viet-vi-heo-ofood-192g.jpg",
    "xuc-xich-an-lien-handy-uc-viet-vi-heo-ofood-192g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích ăn liền vị giò lụa Ponnie cây 28g",
    7900,
    "images/products/xuc-xich-an-lien-vi-gio-lua-ponnie-cay-28g.png",
    "xuc-xich-an-lien-vi-gio-lua-ponnie-cay-28g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích ăn liền vị cay Ponnie cây 28g",
    7900,
    "images/products/xuc-xich-an-lien-vi-cay-ponnie-cay-28g.png",
    "xuc-xich-an-lien-vi-cay-ponnie-cay-28g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích ăn liền vị bắp Ponnie cây 28g",
    7900,
    "images/products/xuc-xich-an-lien-vi-bap-ponnie-cay-28g.png",
    "xuc-xich-an-lien-vi-bap-ponnie-cay-28g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xúc xích lắc phô mai C.P ly 64g",
    12900,
    "images/products/xuc-xich-lac-pho-mai-cp-ly-64g.png",
    "xuc-xich-lac-pho-mai-cp-ly-64g",
    1000,
    5,
    1,
    5,
    36
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá nục xốt cà 3 Cô Gái 190g",
    25000,
    "images/products/ca-nuc-xot-ca-3-co-gai-190g.png",
    "ca-nuc-xot-ca-3-co-gai-190g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá nục xốt cà Thai Ship 155g",
    14000,
    "images/products/ca-nuc-xot-ca-thai-ship-155g.jpg",
    "ca-nuc-xot-ca-thai-ship-155g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá ngừ xốt tương Tuna Việt Nam 155g",
    25000,
    "images/products/ca-ngu-xot-tuong-tuna-viet-nam-155g.png",
    "ca-ngu-xot-tuong-tuna-viet-nam-155g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá ngừ xốt cà chua Tuna Việt Nam 140g",
    25000,
    "images/products/ca-ngu-xot-ca-chua-tuna-viet-nam-140g.png",
    "ca-ngu-xot-ca-chua-tuna-viet-nam-140g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá ngừ xốt cay Tuna Việt Nam 140g",
    25000,
    "images/products/ca-ngu-xot-cay-tuna-viet-nam-140g.png",
    "ca-ngu-xot-cay-tuna-viet-nam-140g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá ngừ ngâm dầu Tuna Việt Nam 140g",
    25000,
    "images/products/ca-ngu-ngam-dau-tuna-viet-nam-140g.jpg",
    "ca-ngu-ngam-dau-tuna-viet-nam-140g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá mòi xốt cà chua nắp giật 3 Cô Gái 155g",
    19000,
    "images/products/ca-moi-xot-ca-chua-nap-giat-3-co-gai-155g.jpg",
    "ca-moi-xot-ca-chua-nap-giat-3-co-gai-155g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "4 hộp cá nục xốt cà 3 Cô Gái 190g",
    100000,
    "images/products/4-hop-ca-nuc-xot-ca-3-co-gai-190g.jpg",
    "4-hop-ca-nuc-xot-ca-3-co-gai-190g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá nục sốt cà nắp giật Lilly 155g",
    14000,
    "images/products/ca-nuc-sot-ca-nap-giat-lilly-155g.jpg",
    "ca-nuc-sot-ca-nap-giat-lilly-155g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá nục sốt ớt chua ngọt Sea Crown 155g",
    16000,
    "images/products/ca-nuc-sot-ot-chua-ngot-sea-crown-155g.png",
    "ca-nuc-sot-ot-chua-ngot-sea-crown-155g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá nục sốt cà Sea Crown 155g",
    16400,
    "images/products/ca-nuc-sot-ca-sea-crown-155g.png",
    "ca-nuc-sot-ca-sea-crown-155g",
    1000,
    5,
    1,
    5,
    37
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Pate gan heo WYN 150g",
    22000,
    "images/products/pate-gan-heo-wyn-150g.png",
    "pate-gan-heo-wyn-150g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Pate thịt cột đèn Hải Phòng Hạ Long hộp 150g",
    22000,
    "images/products/pate-thit-cot-en-hai-phong-ha-long-hop-150g.png",
    "pate-thit-cot-en-hai-phong-ha-long-hop-150g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt heo viên Heo Cao Bồi ăn liền vị xốt cà Masan hộp 200g",
    26500,
    "images/products/thit-heo-vien-heo-cao-boi-an-lien-vi-xot-ca-masan-hop-200g.png",
    "thit-heo-vien-heo-cao-boi-an-lien-vi-xot-ca-masan-hop-200g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt heo viên 3 phút Heo Cao Bồi Masan hộp 200g",
    26500,
    "images/products/thit-heo-vien-3-phut-heo-cao-boi-masan-hop-200g.png",
    "thit-heo-vien-3-phut-heo-cao-boi-masan-hop-200g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt heo Pork Luncheon Meat Classic Tulip hộp 200g",
    45000,
    "images/products/thit-heo-pork-luncheon-meat-classic-tulip-hop-200g.png",
    "thit-heo-pork-luncheon-meat-classic-tulip-hop-200g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Heo hai lát Hạ Long hộp 150g",
    21000,
    "images/products/heo-hai-lat-ha-long-hop-150g.png",
    "heo-hai-lat-ha-long-hop-150g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Pate gan Hạ Long hộp 170g",
    38000,
    "images/products/pate-gan-ha-long-hop-170g.png",
    "pate-gan-ha-long-hop-170g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "5 hộp pate thịt cột đèn Hải Phòng Hạ Long 150g",
    110000,
    "images/products/5-hop-pate-thit-cot-en-hai-phong-ha-long-150g.jpg",
    "5-hop-pate-thit-cot-en-hai-phong-ha-long-150g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt viên xốt phô mai Cây Thị 120g",
    20000,
    "images/products/thit-vien-xot-pho-mai-cay-thi-120g.png",
    "thit-vien-xot-pho-mai-cay-thi-120g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt viên xốt cà chua Cây Thị",
    20000,
    "images/products/thit-vien-xot-ca-chua-cay-thi.png",
    "thit-vien-xot-ca-chua-cay-thi",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt áp chảo Ponnie hộp 200g",
    67000,
    "images/products/thit-ap-chao-ponnie-hop-200g.png",
    "thit-ap-chao-ponnie-hop-200g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Heo hai lát 3 Bông Mai Vissan hộp 150g",
    18000,
    "images/products/heo-hai-lat-3-bong-mai-vissan-hop-150g.png",
    "heo-hai-lat-3-bong-mai-vissan-hop-150g",
    1000,
    5,
    1,
    5,
    38
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rong biển nướng giòn trộn chà bông cá hồi Bibigo gói 45g",
    37000,
    "images/products/rong-bien-nuong-gion-tron-cha-bong-ca-hoi-bibigo-goi-45g.jpg",
    "rong-bien-nuong-gion-tron-cha-bong-ca-hoi-bibigo-goi-45g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gia vị rắc cơm rắc rắc Tâm Minh vị rong biển mè hộp 48g",
    36000,
    "images/products/gia-vi-rac-com-rac-rac-tam-minh-vi-rong-bien-me-hop-48g.jpg",
    "gia-vi-rac-com-rac-rac-tam-minh-vi-rong-bien-me-hop-48g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rong biển ăn liền Bibigo vị BBQ lốc 3*5g",
    33000,
    "images/products/rong-bien-an-lien-bibigo-vi-bbq-loc-35g.jpg",
    "rong-bien-an-lien-bibigo-vi-bbq-loc-35g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rong biển ăn liền vị Wasbi Bibigo lốc 3*5g",
    33000,
    "images/products/rong-bien-an-lien-vi-wasbi-bibigo-loc-35g.jpg",
    "rong-bien-an-lien-vi-wasbi-bibigo-loc-35g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rong nho xốt mè rang Top Food 35g",
    21000,
    "images/products/rong-nho-xot-me-rang-top-food-35g.jpg",
    "rong-nho-xot-me-rang-top-food-35g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rong nho tách nước Top Food 50g",
    37000,
    "images/products/rong-nho-tach-nuoc-top-food-50g.jpg",
    "rong-nho-tach-nuoc-top-food-50g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rong mứt nấu canh Sea -Việt gói 50g",
    26500,
    "images/products/rong-mut-nau-canh-sea--viet-goi-50g.jpg",
    "rong-mut-nau-canh-sea--viet-goi-50g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rong biển trộn cơm captain lee Choi Gang vị tôm và cá cơm 40g",
    39000,
    "images/products/rong-bien-tron-com-captain-lee-choi-gang-vi-tom-va-ca-com-40g.jpg",
    "rong-bien-tron-com-captain-lee-choi-gang-vi-tom-va-ca-com-40g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rong biển trộn cơm captain lee Choi Gang vị truyền thống 40g",
    39000,
    "images/products/rong-bien-tron-com-captain-lee-choi-gang-vi-truyen-thong-40g.jpg",
    "rong-bien-tron-com-captain-lee-choi-gang-vi-truyen-thong-40g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rong nho Tasami xốt mè rang gói 35g",
    23000,
    "images/products/rong-nho-tasami-xot-me-rang-goi-35g.jpg",
    "rong-nho-tasami-xot-me-rang-goi-35g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rong nho Tasami gói 20g",
    16400,
    "images/products/rong-nho-tasami-goi-20g.jpg",
    "rong-nho-tasami-goi-20g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 2 gói rong biển ăn liền Tao Kae Noi Seasoned Laver vị cay 4g",
    28500,
    "images/products/loc-2-goi-rong-bien-an-lien-tao-kae-noi-seasoned-laver-vi-cay-4g.jpg",
    "loc-2-goi-rong-bien-an-lien-tao-kae-noi-seasoned-laver-vi-cay-4g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 2 gói rong biển ăn liền Tao Kae Noi Seasoned Laver vị truyền thống 4g",
    28500,
    "images/products/loc-2-goi-rong-bien-an-lien-tao-kae-noi-seasoned-laver-vi-truyen-thong-4g.jpg",
    "loc-2-goi-rong-bien-an-lien-tao-kae-noi-seasoned-laver-vi-truyen-thong-4g",
    1000,
    5,
    1,
    5,
    40
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chao đậu ăn liền Mikiri chai 120g",
    15400,
    "images/products/chao-au-an-lien-mikiri-chai-120g.png",
    "chao-au-an-lien-mikiri-chai-120g",
    1000,
    5,
    1,
    5,
    41
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chao khoai môn Mikiri hũ 180g",
    22000,
    "images/products/chao-khoai-mon-mikiri-hu-180g.png",
    "chao-khoai-mon-mikiri-hu-180g",
    1000,
    5,
    1,
    5,
    41
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chao Bông Mai hũ 170g",
    17500,
    "images/products/chao-bong-mai-hu-170g.png",
    "chao-bong-mai-hu-170g",
    1000,
    5,
    1,
    5,
    41
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột phô mai StFood 100g",
    37500,
    "images/products/bot-pho-mai-stfood-100g.jpg",
    "bot-pho-mai-stfood-100g",
    1000,
    5,
    1,
    5,
    43
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột chiên gà giòn Tài Ký 500g",
    43500,
    "images/products/bot-chien-ga-gion-tai-ky-500g.jpg",
    "bot-chien-ga-gion-tai-ky-500g",
    1000,
    5,
    1,
    5,
    43
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột chiên giòn thêm hạt O'food 100g",
    11300,
    "images/products/bot-chien-gion-them-hat-ofood-100g.jpg",
    "bot-chien-gion-them-hat-ofood-100g",
    1000,
    5,
    1,
    5,
    43
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột phô mai Ottogi 100g",
    31500,
    "images/products/bot-pho-mai-ottogi-100g.jpg",
    "bot-pho-mai-ottogi-100g",
    1000,
    5,
    1,
    5,
    43
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột sương sáo đen con rồng Konkon gói 50g",
    17000,
    "images/products/bot-suong-sao-en-con-rong-konkon-goi-50g.jpg",
    "bot-suong-sao-en-con-rong-konkon-goi-50g",
    1000,
    5,
    1,
    5,
    43
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rau câu dẻo con rồng Konkon gói 12g",
    10800,
    "images/products/rau-cau-deo-con-rong-konkon-goi-12g.jpg",
    "rau-cau-deo-con-rong-konkon-goi-12g",
    1000,
    5,
    1,
    5,
    43
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột baking soda tinh khiết Caster Daily hộp 454g",
    46500,
    "images/products/bot-baking-soda-tinh-khiet-caster-daily-hop-454g.jpg",
    "bot-baking-soda-tinh-khiet-caster-daily-hop-454g",
    1000,
    5,
    1,
    5,
    43
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột mì đa dụng Địa Cầu gói 500g",
    14900,
    "images/products/bot-mi-a-dung-ia-cau-goi-500g.jpg",
    "bot-mi-a-dung-ia-cau-goi-500g",
    1000,
    5,
    1,
    5,
    43
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột sương sáo đen Bà Bảy gói 50g",
    14400,
    "images/products/bot-suong-sao-en-ba-bay-goi-50g.jpg",
    "bot-suong-sao-en-ba-bay-goi-50g",
    1000,
    5,
    1,
    5,
    43
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột rau câu dẻo Bà Bảy gói 10g",
    11300,
    "images/products/bot-rau-cau-deo-ba-bay-goi-10g.jpg",
    "bot-rau-cau-deo-ba-bay-goi-10g",
    1000,
    5,
    1,
    5,
    43
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chè dưỡng nhan Vietfresh gói 150g",
    40000,
    "images/products/che-duong-nhan-vietfresh-goi-150g.jpg",
    "che-duong-nhan-vietfresh-goi-150g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột khoai màu Vietfresh gói 100g",
    6800/100g,
    "images/products/bot-khoai-mau-vietfresh-goi-100g.jpg",
    "bot-khoai-mau-vietfresh-goi-100g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm tuyết Vietfresh gói 50g",
    31000/50g,
    "images/products/nam-tuyet-vietfresh-goi-50g.jpg",
    "nam-tuyet-vietfresh-goi-50g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu nành 500g",
    23500/500g,
    "images/products/au-nanh-500g.jpg",
    "au-nanh-500g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt sen khô gói 100g",
    37000/100g,
    "images/products/hat-sen-kho-goi-100g.jpg",
    "hat-sen-kho-goi-100g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Táo đỏ không hạt gói 100g",
    15000/100g,
    "images/products/tao-o-khong-hat-goi-100g.jpg",
    "tao-o-khong-hat-goi-100g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Măng khô Tây Bắc gói 100g",
    40000/100g,
    "images/products/mang-kho-tay-bac-goi-100g.jpg",
    "mang-kho-tay-bac-goi-100g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Canh tiềm gói 100g",
    36000/100g,
    "images/products/canh-tiem-goi-100g.jpg",
    "canh-tiem-goi-100g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm hương khô Nguyên Bảo gói 50g",
    33000/50g,
    "images/products/nam-huong-kho-nguyen-bao-goi-50g.jpg",
    "nam-huong-kho-nguyen-bao-goi-50g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt é gói 100g",
    17500/100g,
    "images/products/hat-e-goi-100g.jpg",
    "hat-e-goi-100g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Táo đỏ có hạt gói 100g",
    15000/100g,
    "images/products/tao-o-co-hat-goi-100g.jpg",
    "tao-o-co-hat-goi-100g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột báng gói 100g",
    6200/100g,
    "images/products/bot-bang-goi-100g.jpg",
    "bot-bang-goi-100g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột khoai gói 100g",
    6200/100g,
    "images/products/bot-khoai-goi-100g.jpg",
    "bot-khoai-goi-100g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu trắng bi 150g",
    16000,
    "images/products/au-trang-bi-150g.jpg",
    "au-trang-bi-150g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm đông cô gói 50g",
    30000/50g,
    "images/products/nam-ong-co-goi-50g.jpg",
    "nam-ong-co-goi-50g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu xanh hạt 150g",
    12300,
    "images/products/au-xanh-hat-150g.jpg",
    "au-xanh-hat-150g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu xanh không vỏ 150g",
    12300,
    "images/products/au-xanh-khong-vo-150g.jpg",
    "au-xanh-khong-vo-150g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu xanh cà vỏ 150g",
    12300,
    "images/products/au-xanh-ca-vo-150g.jpg",
    "au-xanh-ca-vo-150g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu đen hạt 150g",
    12300,
    "images/products/au-en-hat-150g.jpg",
    "au-en-hat-150g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu phộng 150g",
    16000,
    "images/products/au-phong-150g.jpg",
    "au-phong-150g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu đỏ 150g",
    14400,
    "images/products/au-o-150g.jpg",
    "au-o-150g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phổ tai gói 50g",
    15400/50g,
    "images/products/pho-tai-goi-50g.jpg",
    "pho-tai-goi-50g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm mèo đen khô gói 50g",
    15000/50g,
    "images/products/nam-meo-en-kho-goi-50g.jpg",
    "nam-meo-en-kho-goi-50g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nấm mèo đen thái sợi 50g",
    16400,
    "images/products/nam-meo-en-thai-soi-50g.jpg",
    "nam-meo-en-thai-soi-50g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tỏi phi Nguyên Bảo 50g",
    17100,
    "images/products/toi-phi-nguyen-bao-50g.jpg",
    "toi-phi-nguyen-bao-50g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hành phi Nguyên Bảo 50g",
    17800,
    "images/products/hanh-phi-nguyen-bao-50g.jpg",
    "hanh-phi-nguyen-bao-50g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tiêu đen xay 50g",
    17500,
    "images/products/tieu-en-xay-50g.jpg",
    "tieu-en-xay-50g",
    1000,
    5,
    1,
    5,
    44
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cải tứ xuyên giòn Ông Chà Và 40g",
    8000,
    "images/products/cai-tu-xuyen-gion-ong-cha-va-40g.png",
    "cai-tu-xuyen-gion-ong-cha-va-40g",
    1000,
    5,
    1,
    5,
    46
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mắm cá cơm Sông Hương hũ 200g",
    30000,
    "images/products/mam-ca-com-song-huong-hu-200g.jpg",
    "mam-ca-com-song-huong-hu-200g",
    1000,
    5,
    1,
    5,
    46
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mắm cà pháo Sông Hương hũ 390g",
    37000,
    "images/products/mam-ca-phao-song-huong-hu-390g.jpg",
    "mam-ca-phao-song-huong-hu-390g",
    1000,
    5,
    1,
    5,
    46
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng rau củ Sa Giang gói 200g",
    29000,
    "images/products/banh-trang-rau-cu-sa-giang-goi-200g.jpg",
    "banh-trang-rau-cu-sa-giang-goi-200g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng gạo Mikiri gói 200g",
    25000,
    "images/products/banh-trang-gao-mikiri-goi-200g.jpg",
    "banh-trang-gao-mikiri-goi-200g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng gỏi cuốn hương quế Dalat Vinfarm gói 180g",
    19500,
    "images/products/banh-trang-goi-cuon-huong-que-dalat-vinfarm-goi-180g.jpg",
    "banh-trang-goi-cuon-huong-que-dalat-vinfarm-goi-180g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng gỏi cuốn hương quế Dalat Vinfarm gói 280g",
    29500,
    "images/products/banh-trang-goi-cuon-huong-que-dalat-vinfarm-goi-280g.jpg",
    "banh-trang-goi-cuon-huong-que-dalat-vinfarm-goi-280g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng cuốn 22cm Tân Nhiên gói 300g",
    24500/300g,
    "images/products/banh-trang-cuon-22cm-tan-nhien-goi-300g.jpg",
    "banh-trang-cuon-22cm-tan-nhien-goi-300g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng chả giò 16cm Tân Nhiên gói 300g",
    24500/300g,
    "images/products/banh-trang-cha-gio-16cm-tan-nhien-goi-300g.jpg",
    "banh-trang-cha-gio-16cm-tan-nhien-goi-300g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng siêu mỏng 16cm x 22cm Tân Nhiên gói 120g",
    12300/120g,
    "images/products/banh-trang-sieu-mong-16cm-x-22cm-tan-nhien-goi-120g.jpg",
    "banh-trang-sieu-mong-16cm-x-22cm-tan-nhien-goi-120g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng Mikiri gói 105g",
    12700/105g,
    "images/products/banh-trang-mikiri-goi-105g.jpg",
    "banh-trang-mikiri-goi-105g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng không nhúng nước Mikiri gói 210g",
    25000/210g,
    "images/products/banh-trang-khong-nhung-nuoc-mikiri-goi-210g.jpg",
    "banh-trang-khong-nhung-nuoc-mikiri-goi-210g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng siêu mỏng 21cm Tinh Nguyên gói 180g",
    19000/180g,
    "images/products/banh-trang-sieu-mong-21cm-tinh-nguyen-goi-180g.jpg",
    "banh-trang-sieu-mong-21cm-tinh-nguyen-goi-180g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng 16cm Safoco gói 200g",
    16400/200g,
    "images/products/banh-trang-16cm-safoco-goi-200g.jpg",
    "banh-trang-16cm-safoco-goi-200g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng 22cm Tinh Nguyên gói 200g",
    16900/200g,
    "images/products/banh-trang-22cm-tinh-nguyen-goi-200g.jpg",
    "banh-trang-22cm-tinh-nguyen-goi-200g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng ớt 22cm Tinh Nguyên gói 200g",
    19500/200g,
    "images/products/banh-trang-ot-22cm-tinh-nguyen-goi-200g.jpg",
    "banh-trang-ot-22cm-tinh-nguyen-goi-200g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng chả giò góc tư 21cm Hương Nam gói 250g",
    18500/250g,
    "images/products/banh-trang-cha-gio-goc-tu-21cm-huong-nam-goi-250g.jpg",
    "banh-trang-cha-gio-goc-tu-21cm-huong-nam-goi-250g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng 22cm Safoco gói 300g",
    22000/300g,
    "images/products/banh-trang-22cm-safoco-goi-300g.jpg",
    "banh-trang-22cm-safoco-goi-300g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng nướng Mikiri gói 55g",
    12300,
    "images/products/banh-trang-nuong-mikiri-goi-55g.jpg",
    "banh-trang-nuong-mikiri-goi-55g",
    1000,
    5,
    1,
    5,
    48
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu mè hảo hạng Meizan 250ml",
    45000/250ml,
    "images/products/dau-me-hao-hang-meizan-250ml.jpg",
    "dau-me-hao-hang-meizan-250ml",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu hướng dương Meizan 1 lít",
    53000/1 lít,
    "images/products/dau-huong-duong-meizan-1-lit.jpg",
    "dau-huong-duong-meizan-1-lit",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu hạt cải Simply 1 lít",
    65000/1 lít,
    "images/products/dau-hat-cai-simply-1-lit.jpg",
    "dau-hat-cai-simply-1-lit",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu đậu nành Simply 2 lít",
    112000/2 lít,
    "images/products/dau-au-nanh-simply-2-lit.jpg",
    "dau-au-nanh-simply-2-lit",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu đậu nành Simply 1 lít",
    56000/1 lít,
    "images/products/dau-au-nanh-simply-1-lit.jpg",
    "dau-au-nanh-simply-1-lit",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu ăn Neptune Light 1 lít",
    56000/1 lít,
    "images/products/dau-an-neptune-light-1-lit.jpg",
    "dau-an-neptune-light-1-lit",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu đậu nành Meizan 2 lít",
    139000/2 lít,
    "images/products/dau-au-nanh-meizan-2-lit.jpg",
    "dau-au-nanh-meizan-2-lit",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu đậu nành Janbee 2 lít",
    139000/2 lít,
    "images/products/dau-au-nanh-janbee-2-lit.jpg",
    "dau-au-nanh-janbee-2-lit",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu đậu nành Janbee 1 lít",
    69500/1 lít,
    "images/products/dau-au-nanh-janbee-1-lit.jpg",
    "dau-au-nanh-janbee-1-lit",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu thực vật Bếp Hồng 1 lít",
    44500/1 lít,
    "images/products/dau-thuc-vat-bep-hong-1-lit.jpg",
    "dau-thuc-vat-bep-hong-1-lit",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu mè thơm Tường An 100ml",
    39000/100ml,
    "images/products/dau-me-thom-tuong-an-100ml.jpg",
    "dau-me-thom-tuong-an-100ml",
    1000,
    5,
    1,
    6,
    50
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước mắm cá cơm than Knorr 242ml",
    15000,
    "images/products/nuoc-mam-ca-com-than-knorr-242ml.jpg",
    "nuoc-mam-ca-com-than-knorr-242ml",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước chấm Đầu Bếp Tôm 1,8 lít",
    21000,
    "images/products/nuoc-cham-au-bep-tom-18-lit.jpg",
    "nuoc-cham-au-bep-tom-18-lit",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước mắm 3 Miền nhãn vàng 900ml",
    20000,
    "images/products/nuoc-mam-3-mien-nhan-vang-900ml.jpg",
    "nuoc-mam-3-mien-nhan-vang-900ml",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước chấm Nam Ngư Siêu Tiết Kiệm 1,8 lít",
    22000,
    "images/products/nuoc-cham-nam-ngu-sieu-tiet-kiem-18-lit.jpg",
    "nuoc-cham-nam-ngu-sieu-tiet-kiem-18-lit",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước chấm cá cơm Đầu Bếp 800ml",
    11000,
    "images/products/nuoc-cham-ca-com-au-bep-800ml.jpg",
    "nuoc-cham-ca-com-au-bep-800ml",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước mắm Thuận Phát 740ml",
    34000,
    "images/products/nuoc-mam-thuan-phat-740ml.jpg",
    "nuoc-mam-thuan-phat-740ml",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước mắm cá cơm Knorr 750ml",
    54500,
    "images/products/nuoc-mam-ca-com-knorr-750ml.jpg",
    "nuoc-mam-ca-com-knorr-750ml",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước mắm nhãn bạc Liên Thành 600ml",
    58500,
    "images/products/nuoc-mam-nhan-bac-lien-thanh-600ml.jpg",
    "nuoc-mam-nhan-bac-lien-thanh-600ml",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước mắm cốt nhĩ Việt Nhĩ 500ml",
    53000,
    "images/products/nuoc-mam-cot-nhi-viet-nhi-500ml.jpg",
    "nuoc-mam-cot-nhi-viet-nhi-500ml",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước mắm cốt nhĩ tôm Đầu Bếp Tôm 500ml",
    61000,
    "images/products/nuoc-mam-cot-nhi-tom-au-bep-tom-500ml.jpg",
    "nuoc-mam-cot-nhi-tom-au-bep-tom-500ml",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước chấm cá cơm 3 Miền 800ml",
    17000,
    "images/products/nuoc-cham-ca-com-3-mien-800ml.jpg",
    "nuoc-cham-ca-com-3-mien-800ml",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước mắm cá cơm Thuận Phát 490ml",
    105000,
    "images/products/nuoc-mam-ca-com-thuan-phat-490ml.jpg",
    "nuoc-mam-ca-com-thuan-phat-490ml",
    1000,
    5,
    1,
    6,
    51
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tương Ông Chà Và vị thanh dịu 500ml",
    15900,
    "images/products/nuoc-tuong-ong-cha-va-vi-thanh-diu-500ml.jpg",
    "nuoc-tuong-ong-cha-va-vi-thanh-diu-500ml",
    1000,
    5,
    1,
    6,
    52
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tương Tam Thái Tử Nhất Ca sánh đậm 500ml",
    27000,
    "images/products/nuoc-tuong-tam-thai-tu-nhat-ca-sanh-am-500ml.jpg",
    "nuoc-tuong-tam-thai-tu-nhat-ca-sanh-am-500ml",
    1000,
    5,
    1,
    6,
    52
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tương đậu nành TaYaKi 380ml",
    13400/380ml,
    "images/products/nuoc-tuong-au-nanh-tayaki-380ml.jpg",
    "nuoc-tuong-au-nanh-tayaki-380ml",
    1000,
    5,
    1,
    6,
    52
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tương Maggi giảm muối 300ml",
    23000/300ml,
    "images/products/nuoc-tuong-maggi-giam-muoi-300ml.jpg",
    "nuoc-tuong-maggi-giam-muoi-300ml",
    1000,
    5,
    1,
    6,
    52
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tương thượng hạng Nam Dương 500ml",
    42500/500ml,
    "images/products/nuoc-tuong-thuong-hang-nam-duong-500ml.jpg",
    "nuoc-tuong-thuong-hang-nam-duong-500ml",
    1000,
    5,
    1,
    6,
    52
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tương tỏi ớt Chinsu 330ml",
    21500/330ml,
    "images/products/nuoc-tuong-toi-ot-chinsu-330ml.jpg",
    "nuoc-tuong-toi-ot-chinsu-330ml",
    1000,
    5,
    1,
    6,
    52
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tương Chinsu nấm Shiitake 330ml",
    18700/330ml,
    "images/products/nuoc-tuong-chinsu-nam-shiitake-330ml.jpg",
    "nuoc-tuong-chinsu-nam-shiitake-330ml",
    1000,
    5,
    1,
    6,
    52
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tương tỏi ớt Nam Dương 310ml",
    15900/310ml,
    "images/products/nuoc-tuong-toi-ot-nam-duong-310ml.jpg",
    "nuoc-tuong-toi-ot-nam-duong-310ml",
    1000,
    5,
    1,
    6,
    52
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tương đậm đặc Cholimex 300ml",
    14000/300ml,
    "images/products/nuoc-tuong-am-ac-cholimex-300ml.jpg",
    "nuoc-tuong-am-ac-cholimex-300ml",
    1000,
    5,
    1,
    6,
    52
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tương thượng hạng Nam Dương 210ml",
    19400,
    "images/products/nuoc-tuong-thuong-hang-nam-duong-210ml.jpg",
    "nuoc-tuong-thuong-hang-nam-duong-210ml",
    1000,
    5,
    1,
    6,
    52
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm nấm hương Knorr gói 800g",
    86000,
    "images/products/hat-nem-nam-huong-knorr-goi-800g.jpg",
    "hat-nem-nam-huong-knorr-goi-800g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm 3 Miền thịt và xương 900g",
    47000,
    "images/products/hat-nem-3-mien-thit-va-xuong-900g.jpg",
    "hat-nem-3-mien-thit-va-xuong-900g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm Ajinomoto tôm thịt 900g",
    51000,
    "images/products/hat-nem-ajinomoto-tom-thit-900g.jpg",
    "hat-nem-ajinomoto-tom-thit-900g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm vị heo Aji-ngon 900g",
    60500,
    "images/products/hat-nem-vi-heo-aji-ngon-900g.jpg",
    "hat-nem-vi-heo-aji-ngon-900g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm vị heo Aji-ngon 400g",
    28500,
    "images/products/hat-nem-vi-heo-aji-ngon-400g.jpg",
    "hat-nem-vi-heo-aji-ngon-400g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm Chinsu tôm thịt 900g",
    69000,
    "images/products/hat-nem-chinsu-tom-thit-900g.jpg",
    "hat-nem-chinsu-tom-thit-900g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm thịt thăn Knorr 900g",
    86000,
    "images/products/hat-nem-thit-than-knorr-900g.jpg",
    "hat-nem-thit-than-knorr-900g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm chay nấm hương Knorr 380g",
    45000,
    "images/products/hat-nem-chay-nam-huong-knorr-380g.jpg",
    "hat-nem-chay-nam-huong-knorr-380g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm thịt thăn Knorr 400g",
    39000,
    "images/products/hat-nem-thit-than-knorr-400g.jpg",
    "hat-nem-thit-than-knorr-400g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột ngọt Meizan 400g",
    34000,
    "images/products/bot-ngot-meizan-400g.jpg",
    "bot-ngot-meizan-400g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột ngọt Meizan 1kg",
    72500,
    "images/products/bot-ngot-meizan-1kg.jpg",
    "bot-ngot-meizan-1kg",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm tôm thịt Vedan Mommy 900g",
    53500,
    "images/products/hat-nem-tom-thit-vedan-mommy-900g.jpg",
    "hat-nem-tom-thit-vedan-mommy-900g",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt nêm thịt thăn Knorr 1.2kg",
    109000,
    "images/products/hat-nem-thit-than-knorr-12kg.jpg",
    "hat-nem-thit-than-knorr-12kg",
    1000,
    5,
    1,
    6,
    54
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Muối hạt thiên nhiên Ông Chà Và 1kg",
    9500,
    "images/products/muoi-hat-thien-nhien-ong-cha-va-1kg.jpg",
    "muoi-hat-thien-nhien-ong-cha-va-1kg",
    1000,
    5,
    1,
    6,
    55
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Muối tinh sạch Ông Chà Và 1kg",
    9900,
    "images/products/muoi-tinh-sach-ong-cha-va-1kg.jpg",
    "muoi-tinh-sach-ong-cha-va-1kg",
    1000,
    5,
    1,
    6,
    55
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Muối hạt Vĩnh Hảo Sosal Group 1kg",
    8100,
    "images/products/muoi-hat-vinh-hao-sosal-group-1kg.jpg",
    "muoi-hat-vinh-hao-sosal-group-1kg",
    1000,
    5,
    1,
    6,
    55
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Muối biển hạt Bạc Liêu 500g",
    5700,
    "images/products/muoi-bien-hat-bac-lieu-500g.jpg",
    "muoi-bien-hat-bac-lieu-500g",
    1000,
    5,
    1,
    6,
    55
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Muối I-ốt Bạc Liêu 500g",
    6800,
    "images/products/muoi-i-ot-bac-lieu-500g.jpg",
    "muoi-i-ot-bac-lieu-500g",
    1000,
    5,
    1,
    6,
    55
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Muối chấm Hảo Hảo tôm chua cay 120g",
    16000,
    "images/products/muoi-cham-hao-hao-tom-chua-cay-120g.jpg",
    "muoi-cham-hao-hao-tom-chua-cay-120g",
    1000,
    5,
    1,
    6,
    55
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Muối tôm Trần Lâm Food 100g",
    16000,
    "images/products/muoi-tom-tran-lam-food-100g.jpg",
    "muoi-tom-tran-lam-food-100g",
    1000,
    5,
    1,
    6,
    55
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Muối tiêu Guyumi 60g",
    8700,
    "images/products/muoi-tieu-guyumi-60g.jpg",
    "muoi-tieu-guyumi-60g",
    1000,
    5,
    1,
    6,
    55
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Muối ớt Tây Ninh Guyumi 110g",
    18000,
    "images/products/muoi-ot-tay-ninh-guyumi-110g.jpg",
    "muoi-ot-tay-ninh-guyumi-110g",
    1000,
    5,
    1,
    6,
    55
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Muối tôm siêu cay Fadely 60g",
    11200,
    "images/products/muoi-tom-sieu-cay-fadely-60g.jpg",
    "muoi-tom-sieu-cay-fadely-60g",
    1000,
    5,
    1,
    6,
    55
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương ớt tươi Cầu Tre 210g",
    14800,
    "images/products/tuong-ot-tuoi-cau-tre-210g.jpg",
    "tuong-ot-tuoi-cau-tre-210g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương ớt tươi Bibigo Hot Jang 240g",
    22500,
    "images/products/tuong-ot-tuoi-bibigo-hot-jang-240g.jpg",
    "tuong-ot-tuoi-bibigo-hot-jang-240g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương ớt cay đậm Knorr 450g",
    29000,
    "images/products/tuong-ot-cay-am-knorr-450g.jpg",
    "tuong-ot-cay-am-knorr-450g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương ớt Chinsu 500g",
    31000,
    "images/products/tuong-ot-chinsu-500g.jpg",
    "tuong-ot-chinsu-500g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương ớt Delly Cook 270g",
    13900,
    "images/products/tuong-ot-delly-cook-270g.jpg",
    "tuong-ot-delly-cook-270g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương ớt Chinsu 1kg",
    58000,
    "images/products/tuong-ot-chinsu-1kg.jpg",
    "tuong-ot-chinsu-1kg",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương ớt Cholimex 830g",
    31000,
    "images/products/tuong-ot-cholimex-830g.jpg",
    "tuong-ot-cholimex-830g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương ớt Chinsu Sriracha 250g",
    22500,
    "images/products/tuong-ot-chinsu-sriracha-250g.jpg",
    "tuong-ot-chinsu-sriracha-250g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương ớt Sriracha Heinz 120g",
    16800,
    "images/products/tuong-ot-sriracha-heinz-120g.jpg",
    "tuong-ot-sriracha-heinz-120g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương cà chua Heinz 125g",
    16800,
    "images/products/tuong-ca-chua-heinz-125g.jpg",
    "tuong-ca-chua-heinz-125g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xốt mayonnaise Heinz 120g",
    34000,
    "images/products/xot-mayonnaise-heinz-120g.jpg",
    "xot-mayonnaise-heinz-120g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tương cà Ông Chà Và 830g",
    31000,
    "images/products/tuong-ca-ong-cha-va-830g.jpg",
    "tuong-ca-ong-cha-va-830g",
    1000,
    5,
    1,
    6,
    56
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bơ thực vật Meizan 80g",
    7000,
    "images/products/bo-thuc-vat-meizan-80g.jpg",
    "bo-thuc-vat-meizan-80g",
    1000,
    5,
    1,
    6,
    57
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bơ thực vật Meizan 200g",
    16000,
    "images/products/bo-thuc-vat-meizan-200g.jpg",
    "bo-thuc-vat-meizan-200g",
    1000,
    5,
    1,
    6,
    57
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu hào Chinsu sò điệp 400g",
    27000,
    "images/products/dau-hao-chinsu-so-iep-400g.jpg",
    "dau-hao-chinsu-so-iep-400g",
    1000,
    5,
    1,
    6,
    57
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu hào chay Maggi 350g",
    27000,
    "images/products/dau-hao-chay-maggi-350g.jpg",
    "dau-hao-chay-maggi-350g",
    1000,
    5,
    1,
    6,
    57
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu hào Maggi đậm đặc 530g",
    38000,
    "images/products/dau-hao-maggi-am-ac-530g.jpg",
    "dau-hao-maggi-am-ac-530g",
    1000,
    5,
    1,
    6,
    57
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu hào Maggi bào ngư 350g",
    32000,
    "images/products/dau-hao-maggi-bao-ngu-350g.jpg",
    "dau-hao-maggi-bao-ngu-350g",
    1000,
    5,
    1,
    6,
    57
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Giấm ăn A Tuấn Khang 900ml",
    17700,
    "images/products/giam-an-a-tuan-khang-900ml.jpg",
    "giam-an-a-tuan-khang-900ml",
    1000,
    5,
    1,
    6,
    57
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu hào Nam Dương 270g",
    16100,
    "images/products/dau-hao-nam-duong-270g.jpg",
    "dau-hao-nam-duong-270g",
    1000,
    5,
    1,
    6,
    57
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu hào Cholimex 350g",
    21500,
    "images/products/dau-hao-cholimex-350g.jpg",
    "dau-hao-cholimex-350g",
    1000,
    5,
    1,
    6,
    57
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sốt dầu dấm salad Nam Dương 250g",
    15900,
    "images/products/sot-dau-dam-salad-nam-duong-250g.jpg",
    "sot-dau-dam-salad-nam-duong-250g",
    1000,
    5,
    1,
    6,
    57
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xốt gia vị kho sả ớt Maggi 60g",
    10500,
    "images/products/xot-gia-vi-kho-sa-ot-maggi-60g.jpg",
    "xot-gia-vi-kho-sa-ot-maggi-60g",
    1000,
    5,
    1,
    6,
    58
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xốt gia vị kho mía Maggi 60g",
    10500,
    "images/products/xot-gia-vi-kho-mia-maggi-60g.jpg",
    "xot-gia-vi-kho-mia-maggi-60g",
    1000,
    5,
    1,
    6,
    58
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gia vị lẩu cà chua Tứ Xuyên Ông Chà Và 150g",
    45000,
    "images/products/gia-vi-lau-ca-chua-tu-xuyen-ong-cha-va-150g.jpg",
    "gia-vi-lau-ca-chua-tu-xuyen-ong-cha-va-150g",
    1000,
    5,
    1,
    6,
    58
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gia vị lẩu hầm xương Tứ Xuyên Ông Chà Và 150g",
    45000,
    "images/products/gia-vi-lau-ham-xuong-tu-xuyen-ong-cha-va-150g.jpg",
    "gia-vi-lau-ham-xuong-tu-xuyen-ong-cha-va-150g",
    1000,
    5,
    1,
    6,
    58
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gia vị lẩu Tứ Xuyên Ông Chà Và 150g",
    45000,
    "images/products/gia-vi-lau-tu-xuyen-ong-cha-va-150g.jpg",
    "gia-vi-lau-tu-xuyen-ong-cha-va-150g",
    1000,
    5,
    1,
    6,
    58
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xốt ướp kho tiêu Cầu Tre 80g",
    11400,
    "images/products/xot-uop-kho-tieu-cau-tre-80g.jpg",
    "xot-uop-kho-tieu-cau-tre-80g",
    1000,
    5,
    1,
    6,
    58
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ớt rim xứ nắng Delly Cook 290g",
    35000,
    "images/products/ot-rim-xu-nang-delly-cook-290g.jpg",
    "ot-rim-xu-nang-delly-cook-290g",
    1000,
    5,
    1,
    6,
    58
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu ớt Nguyên Bảo 120g",
    29000,
    "images/products/dau-ot-nguyen-bao-120g.jpg",
    "dau-ot-nguyen-bao-120g",
    1000,
    5,
    1,
    6,
    58
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu tỏi phi Nguyên Bảo 120g",
    33000,
    "images/products/dau-toi-phi-nguyen-bao-120g.jpg",
    "dau-toi-phi-nguyen-bao-120g",
    1000,
    5,
    1,
    6,
    58
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xốt thịt kho tàu Cầu Tre 80g",
    11400,
    "images/products/xot-thit-kho-tau-cau-tre-80g.jpg",
    "xot-thit-kho-tau-cau-tre-80g",
    1000,
    5,
    1,
    6,
    58
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sa tế tôm Chinsu ớt sả tươi 90g",
    11500,
    "images/products/sa-te-tom-chinsu-ot-sa-tuoi-90g.jpg",
    "sa-te-tom-chinsu-ot-sa-tuoi-90g",
    1000,
    5,
    1,
    6,
    60
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tiêu đen xay Ông Chà Và 40g",
    22000,
    "images/products/tieu-en-xay-ong-cha-va-40g.jpg",
    "tieu-en-xay-ong-cha-va-40g",
    1000,
    5,
    1,
    6,
    60
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sa tế tôm Barona siêu ngon 100g",
    14200,
    "images/products/sa-te-tom-barona-sieu-ngon-100g.jpg",
    "sa-te-tom-barona-sieu-ngon-100g",
    1000,
    5,
    1,
    6,
    60
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ớt vẩy Hàn Quốc Ông Chà Và 90g",
    34000,
    "images/products/ot-vay-han-quoc-ong-cha-va-90g.jpg",
    "ot-vay-han-quoc-ong-cha-va-90g",
    1000,
    5,
    1,
    6,
    60
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ớt bột Hàn Quốc Ông Chà Và 90g",
    34000,
    "images/products/ot-bot-han-quoc-ong-cha-va-90g.jpg",
    "ot-bot-han-quoc-ong-cha-va-90g",
    1000,
    5,
    1,
    6,
    60
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sa tế tôm Delly Cook 90g",
    10200,
    "images/products/sa-te-tom-delly-cook-90g.jpg",
    "sa-te-tom-delly-cook-90g",
    1000,
    5,
    1,
    6,
    60
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tiêu đen xay DH Foods 45g",
    29000,
    "images/products/tieu-en-xay-dh-foods-45g.jpg",
    "tieu-en-xay-dh-foods-45g",
    1000,
    5,
    1,
    6,
    60
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tiêu đen xay Fadely 45g",
    17100,
    "images/products/tieu-en-xay-fadely-45g.jpg",
    "tieu-en-xay-fadely-45g",
    1000,
    5,
    1,
    6,
    60
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tiêu đen xay Vipep 50g",
    23000,
    "images/products/tieu-en-xay-vipep-50g.jpg",
    "tieu-en-xay-vipep-50g",
    1000,
    5,
    1,
    6,
    60
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đường mía thiên nhiên Biên Hòa gói 1kg",
    33000,
    "images/products/uong-mia-thien-nhien-bien-hoa-goi-1kg.jpg",
    "uong-mia-thien-nhien-bien-hoa-goi-1kg",
    1000,
    5,
    1,
    6,
    53
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đường mía trắng Biên Hòa gói 1kg",
    29000,
    "images/products/uong-mia-trang-bien-hoa-goi-1kg.jpg",
    "uong-mia-trang-bien-hoa-goi-1kg",
    1000,
    5,
    1,
    6,
    53
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đường kính trắng An Khê 500g",
    16400,
    "images/products/uong-kinh-trang-an-khe-500g.jpg",
    "uong-kinh-trang-an-khe-500g",
    1000,
    5,
    1,
    6,
    53
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đường vàng Quảng Ngãi 1kg",
    33500,
    "images/products/uong-vang-quang-ngai-1kg.jpg",
    "uong-vang-quang-ngai-1kg",
    1000,
    5,
    1,
    6,
    53
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đường tinh luyện Quảng Ngãi 1kg",
    31000,
    "images/products/uong-tinh-luyen-quang-ngai-1kg.jpg",
    "uong-tinh-luyen-quang-ngai-1kg",
    1000,
    5,
    1,
    6,
    53
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đường kính trắng An Khê 1kg",
    30000,
    "images/products/uong-kinh-trang-an-khe-1kg.jpg",
    "uong-kinh-trang-an-khe-1kg",
    1000,
    5,
    1,
    6,
    53
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đường thốt nốt Moun7ains gói 500g",
    36000/500g,
    "images/products/uong-thot-not-moun7ains-goi-500g.jpg",
    "uong-thot-not-moun7ains-goi-500g",
    1000,
    5,
    1,
    6,
    53
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đường thốt nốt dạng viên Moun7ains 200g",
    15400/200g,
    "images/products/uong-thot-not-dang-vien-moun7ains-200g.jpg",
    "uong-thot-not-dang-vien-moun7ains-200g",
    1000,
    5,
    1,
    6,
    53
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đường phèn hạt Hoàng Hải gói 500g",
    29000/500g,
    "images/products/uong-phen-hat-hoang-hai-goi-500g.jpg",
    "uong-phen-hat-hoang-hai-goi-500g",
    1000,
    5,
    1,
    6,
    53
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đường kính trắng Toàn Phát gói 500g",
    16400/500g,
    "images/products/uong-kinh-trang-toan-phat-goi-500g.jpg",
    "uong-kinh-trang-toan-phat-goi-500g",
    1000,
    5,
    1,
    6,
    53
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột thịt gà Knorr 300g",
    43000,
    "images/products/bot-thit-ga-knorr-300g.jpg",
    "bot-thit-ga-knorr-300g",
    1000,
    5,
    1,
    6,
    61
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ngũ vị hương Ông Chà Và 10g",
    6500/10g,
    "images/products/ngu-vi-huong-ong-cha-va-10g.jpg",
    "ngu-vi-huong-ong-cha-va-10g",
    1000,
    5,
    1,
    6,
    61
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Quế hồi thảo quả Dh Foods 25g",
    19900,
    "images/products/que-hoi-thao-qua-dh-foods-25g.jpg",
    "que-hoi-thao-qua-dh-foods-25g",
    1000,
    5,
    1,
    6,
    61
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lá xạ hương Ông Chà Và 30g",
    43200/30g,
    "images/products/la-xa-huong-ong-cha-va-30g.jpg",
    "la-xa-huong-ong-cha-va-30g",
    1000,
    5,
    1,
    6,
    61
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lá hương thảo Ông Chà Và 15g",
    28700/15g,
    "images/products/la-huong-thao-ong-cha-va-15g.jpg",
    "la-huong-thao-ong-cha-va-15g",
    1000,
    5,
    1,
    6,
    61
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nghệ bột Vipep 35g",
    11200,
    "images/products/nghe-bot-vipep-35g.jpg",
    "nghe-bot-vipep-35g",
    1000,
    5,
    1,
    6,
    61
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Quế cây Vipep 20g",
    10900/20g,
    "images/products/que-cay-vipep-20g.jpg",
    "que-cay-vipep-20g",
    1000,
    5,
    1,
    6,
    61
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lá nguyệt quế Ông Chà Và 25g",
    22000/25g,
    "images/products/la-nguyet-que-ong-cha-va-25g.jpg",
    "la-nguyet-que-ong-cha-va-25g",
    1000,
    5,
    1,
    6,
    61
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Quế cây Dh Foods 20g",
    13000/20g,
    "images/products/que-cay-dh-foods-20g.jpg",
    "que-cay-dh-foods-20g",
    1000,
    5,
    1,
    6,
    61
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lá mùi tây Ông Chà Và 15g",
    41000/15g,
    "images/products/la-mui-tay-ong-cha-va-15g.jpg",
    "la-mui-tay-ong-cha-va-15g",
    1000,
    5,
    1,
    6,
    61
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói mì Lẩu Thái tôm 81g",
    212000,
    "images/products/thung-30-goi-mi-lau-thai-tom-81g.jpg",
    "thung-30-goi-mi-lau-thai-tom-81g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói mì Đệ Nhất thịt bằm 83g",
    212000,
    "images/products/thung-30-goi-mi-e-nhat-thit-bam-83g.jpg",
    "thung-30-goi-mi-e-nhat-thit-bam-83g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói mì 3 Miền gà sợi phở gói 65g",
    80000,
    "images/products/thung-30-goi-mi-3-mien-ga-soi-pho-goi-65g.jpg",
    "thung-30-goi-mi-3-mien-ga-soi-pho-goi-65g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói mì 3 Miền tôm chua cay 65g",
    80000,
    "images/products/thung-30-goi-mi-3-mien-tom-chua-cay-65g.jpg",
    "thung-30-goi-mi-3-mien-tom-chua-cay-65g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói mì 3 Miền tôm hùm 65g",
    80000,
    "images/products/thung-30-goi-mi-3-mien-tom-hum-65g.jpg",
    "thung-30-goi-mi-3-mien-tom-hum-65g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì trộn Oppa hải sản hành phi Ottogi gói 65g",
    4900,
    "images/products/mi-tron-oppa-hai-san-hanh-phi-ottogi-goi-65g.jpg",
    "mi-tron-oppa-hai-san-hanh-phi-ottogi-goi-65g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói mì Gấu Đỏ tôm gà 63g",
    80000,
    "images/products/thung-30-goi-mi-gau-o-tom-ga-63g.jpg",
    "thung-30-goi-mi-gau-o-tom-ga-63g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói mì Gấu Đỏ bò bít tết 63g",
    80000,
    "images/products/thung-30-goi-mi-gau-o-bo-bit-tet-63g.jpg",
    "thung-30-goi-mi-gau-o-bo-bit-tet-63g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói mì Hảo 100 tôm chua cay 65g",
    93000,
    "images/products/thung-30-goi-mi-hao-100-tom-chua-cay-65g.jpg",
    "thung-30-goi-mi-hao-100-tom-chua-cay-65g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói mì vị bò SiuKay 127g",
    293000,
    "images/products/thung-24-goi-mi-vi-bo-siukay-127g.jpg",
    "thung-24-goi-mi-vi-bo-siukay-127g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói mì Kokomi 90 tôm chua cay 90g",
    115000,
    "images/products/thung-30-goi-mi-kokomi-90-tom-chua-cay-90g.jpg",
    "thung-30-goi-mi-kokomi-90-tom-chua-cay-90g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói mì hải sản SiuKay 129g",
    293000,
    "images/products/thung-24-goi-mi-hai-san-siukay-129g.jpg",
    "thung-24-goi-mi-hai-san-siukay-129g",
    1000,
    5,
    1,
    7,
    62
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói miến lẩu Thái Vifon 60g",
    170000,
    "images/products/thung-24-goi-mien-lau-thai-vifon-60g.jpg",
    "thung-24-goi-mien-lau-thai-vifon-60g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói miến sườn heo Vifon 58g",
    170000,
    "images/products/thung-24-goi-mien-suon-heo-vifon-58g.jpg",
    "thung-24-goi-mien-suon-heo-vifon-58g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói miến măng vịt Vifon 58g",
    170000,
    "images/products/thung-24-goi-mien-mang-vit-vifon-58g.jpg",
    "thung-24-goi-mien-mang-vit-vifon-58g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói hủ tiếu Mỹ Tho Chin-su Hủ tiếu story hải sản 77g",
    199000,
    "images/products/thung-30-goi-hu-tieu-my-tho-chin-su-hu-tieu-story-hai-san-77g.jpg",
    "thung-30-goi-hu-tieu-my-tho-chin-su-hu-tieu-story-hai-san-77g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 gói miến sườn heo Vifon 58g",
    29000,
    "images/products/loc-4-goi-mien-suon-heo-vifon-58g.jpg",
    "loc-4-goi-mien-suon-heo-vifon-58g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 gói miến măng vịt Vifon 58g",
    29000,
    "images/products/loc-4-goi-mien-mang-vit-vifon-58g.jpg",
    "loc-4-goi-mien-mang-vit-vifon-58g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói hủ tiếu Nam Vang Nhịp Sống 70g",
    280000,
    "images/products/thung-30-goi-hu-tieu-nam-vang-nhip-song-70g.png",
    "thung-30-goi-hu-tieu-nam-vang-nhip-song-70g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói miến trộn Phú Hương hải sản cay gói 66g",
    288000,
    "images/products/thung-24-goi-mien-tron-phu-huong-hai-san-cay-goi-66g.png",
    "thung-24-goi-mien-tron-phu-huong-hai-san-cay-goi-66g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói miến trộn Phú Hương gà xào chua ngọt gói 69g",
    288000,
    "images/products/thung-24-goi-mien-tron-phu-huong-ga-xao-chua-ngot-goi-69g.png",
    "thung-24-goi-mien-tron-phu-huong-ga-xao-chua-ngot-goi-69g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói miến Phú Hương sườn heo 55g",
    256000,
    "images/products/thung-24-goi-mien-phu-huong-suon-heo-55g.jpg",
    "thung-24-goi-mien-phu-huong-suon-heo-55g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Miến trộn Phú Hương hải sản cay gói 66g",
    13200,
    "images/products/mien-tron-phu-huong-hai-san-cay-goi-66g.png",
    "mien-tron-phu-huong-hai-san-cay-goi-66g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Miến trộn Phú Hương gà xào chua ngọt gói 69g",
    13200,
    "images/products/mien-tron-phu-huong-ga-xao-chua-ngot-goi-69g.png",
    "mien-tron-phu-huong-ga-xao-chua-ngot-goi-69g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 gói miến Phú Hương sườn heo 55g",
    45000,
    "images/products/loc-4-goi-mien-phu-huong-suon-heo-55g.jpg",
    "loc-4-goi-mien-phu-huong-suon-heo-55g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 gói hủ tiếu Nam Vang Nhịp Sống 69g",
    48000,
    "images/products/loc-5-goi-hu-tieu-nam-vang-nhip-song-69g.jpg",
    "loc-5-goi-hu-tieu-nam-vang-nhip-song-69g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hủ tiếu Mỹ Tho Chin-su hủ tiếu story hải sản 77g",
    10300,
    "images/products/hu-tieu-my-tho-chin-su-hu-tieu-story-hai-san-77g.jpg",
    "hu-tieu-my-tho-chin-su-hu-tieu-story-hai-san-77g",
    1000,
    5,
    1,
    7,
    63
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói phở gà Vifon 75g",
    195000,
    "images/products/thung-24-goi-pho-ga-vifon-75g.jpg",
    "thung-24-goi-pho-ga-vifon-75g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói phở bò Vifon 75g",
    195000,
    "images/products/thung-24-goi-pho-bo-vifon-75g.jpg",
    "thung-24-goi-pho-bo-vifon-75g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói phở bò Vifon 65g",
    210000,
    "images/products/thung-30-goi-pho-bo-vifon-65g.jpg",
    "thung-30-goi-pho-bo-vifon-65g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói phở gà Vifon 65g",
    210000,
    "images/products/thung-30-goi-pho-ga-vifon-65g.jpg",
    "thung-30-goi-pho-ga-vifon-65g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 gói bún giò heo Hằng Nga 75g",
    43500,
    "images/products/loc-5-goi-bun-gio-heo-hang-nga-75g.jpg",
    "loc-5-goi-bun-gio-heo-hang-nga-75g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bún bò Huế Hằng Nga 73g",
    8900,
    "images/products/bun-bo-hue-hang-nga-73g.jpg",
    "bun-bo-hue-hang-nga-73g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 gói phở bò tái lăn Đệ Nhất gói 68g",
    53000,
    "images/products/loc-5-goi-pho-bo-tai-lan-e-nhat-goi-68g.jpg",
    "loc-5-goi-pho-bo-tai-lan-e-nhat-goi-68g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 gói phở ăn liền Đệ Nhất đặc biệt lõi bò gầu giòn gói 67g",
    54000,
    "images/products/loc-5-goi-pho-an-lien-e-nhat-ac-biet-loi-bo-gau-gion-goi-67g.jpg",
    "loc-5-goi-pho-an-lien-e-nhat-ac-biet-loi-bo-gau-gion-goi-67g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 gói phở gà Đệ Nhất gói 65g",
    42000,
    "images/products/loc-5-goi-pho-ga-e-nhat-goi-65g.jpg",
    "loc-5-goi-pho-ga-e-nhat-goi-65g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói phở Đệ Nhất đặc biệt lõi bò gầu giòn 67g",
    300000,
    "images/products/thung-30-goi-pho-e-nhat-ac-biet-loi-bo-gau-gion-67g.jpg",
    "thung-30-goi-pho-e-nhat-ac-biet-loi-bo-gau-gion-67g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phở Đệ Nhất đặc biệt lõi bò gầu giòn 67g",
    10800,
    "images/products/pho-e-nhat-ac-biet-loi-bo-gau-gion-67g.jpg",
    "pho-e-nhat-ac-biet-loi-bo-gau-gion-67g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 gói phở bò Đệ Nhất 68g",
    40000,
    "images/products/loc-5-goi-pho-bo-e-nhat-68g.jpg",
    "loc-5-goi-pho-bo-e-nhat-68g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "THung 30 gói phở bò tái lăn Đệ Nhất 68g",
    306000,
    "images/products/thung-30-goi-pho-bo-tai-lan-e-nhat-68g.jpg",
    "thung-30-goi-pho-bo-tai-lan-e-nhat-68g",
    1000,
    5,
    1,
    7,
    64
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cháo yến thịt rau củ Yến Việt Nest Grow+ 50g",
    12000,
    "images/products/chao-yen-thit-rau-cu-yen-viet-nest-grow-50g.jpg",
    "chao-yen-thit-rau-cu-yen-viet-nest-grow-50g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cháo yến thịt bằm Yến Việt Nest IQ Kids 50g",
    10000,
    "images/products/chao-yen-thit-bam-yen-viet-nest-iq-kids-50g.jpg",
    "chao-yen-thit-bam-yen-viet-nest-iq-kids-50g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cháo tươi gà nấm đông cô Cây Thị 240g",
    27000,
    "images/products/chao-tuoi-ga-nam-ong-co-cay-thi-240g.jpg",
    "chao-tuoi-ga-nam-ong-co-cay-thi-240g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cháo tươi cá chẽm khoai môn Cây Thị 240g",
    27000,
    "images/products/chao-tuoi-ca-chem-khoai-mon-cay-thi-240g.jpg",
    "chao-tuoi-ca-chem-khoai-mon-cay-thi-240g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cháo tươi hải sản thập cẩm Cây Thị 240g",
    27000,
    "images/products/chao-tuoi-hai-san-thap-cam-cay-thi-240g.jpg",
    "chao-tuoi-hai-san-thap-cam-cay-thi-240g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cháo tươi tôm rau ngót Cây Thị 240g",
    25000,
    "images/products/chao-tuoi-tom-rau-ngot-cay-thi-240g.jpg",
    "chao-tuoi-tom-rau-ngot-cay-thi-240g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 50 gói cháo thịt bằm Gấu Đỏ 50g",
    170000,
    "images/products/thung-50-goi-chao-thit-bam-gau-o-50g.jpg",
    "thung-50-goi-chao-thit-bam-gau-o-50g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 50 gói cháo gà Gấu Đỏ 50g",
    170000,
    "images/products/thung-50-goi-chao-ga-gau-o-50g.jpg",
    "thung-50-goi-chao-ga-gau-o-50g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cháo yến hải sản rong biển Yến Việt 50g",
    11000,
    "images/products/chao-yen-hai-san-rong-bien-yen-viet-50g.jpg",
    "chao-yen-hai-san-rong-bien-yen-viet-50g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 30 gói cháo tổ yến gold Yến Lộc Phát thịt bằm 50g",
    265000,
    "images/products/thung-30-goi-chao-to-yen-gold-yen-loc-phat-thit-bam-50g.jpg",
    "thung-30-goi-chao-to-yen-gold-yen-loc-phat-thit-bam-50g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cháo tổ yến gold Yến Lộc Phát thịt bằm gói 50g",
    9500,
    "images/products/chao-to-yen-gold-yen-loc-phat-thit-bam-goi-50g.jpg",
    "chao-to-yen-gold-yen-loc-phat-thit-bam-goi-50g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cháo tươi ếch đậu hà lan Cây Thị 240g",
    25000,
    "images/products/chao-tuoi-ech-au-ha-lan-cay-thi-240g.jpg",
    "chao-tuoi-ech-au-ha-lan-cay-thi-240g",
    1000,
    5,
    1,
    7,
    65
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui gạo lứt Nuffam gói 210g",
    18000,
    "images/products/nui-gao-lut-nuffam-goi-210g.jpg",
    "nui-gao-lut-nuffam-goi-210g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui ống dài Nuffam gói 400g",
    23000,
    "images/products/nui-ong-dai-nuffam-goi-400g.jpg",
    "nui-ong-dai-nuffam-goi-400g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui rau củ ống dài Nuffam gói 350g",
    21000,
    "images/products/nui-rau-cu-ong-dai-nuffam-goi-350g.jpg",
    "nui-rau-cu-ong-dai-nuffam-goi-350g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui trứng ống xoắn cao cấp Erici gói 400g",
    22000/400g,
    "images/products/nui-trung-ong-xoan-cao-cap-erici-goi-400g.jpg",
    "nui-trung-ong-xoan-cao-cap-erici-goi-400g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui rau củ xoắn Safoco gói 300g",
    21000/300g,
    "images/products/nui-rau-cu-xoan-safoco-goi-300g.jpg",
    "nui-rau-cu-xoan-safoco-goi-300g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui ống lớn Safoco gói 400g",
    30000/400g,
    "images/products/nui-ong-lon-safoco-goi-400g.jpg",
    "nui-ong-lon-safoco-goi-400g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui rau củ dạng xoắn Song Long 400g",
    25500,
    "images/products/nui-rau-cu-dang-xoan-song-long-400g.jpg",
    "nui-rau-cu-dang-xoan-song-long-400g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui gạo lứt Song Long 400g",
    25500,
    "images/products/nui-gao-lut-song-long-400g.jpg",
    "nui-gao-lut-song-long-400g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui rau củ ống dài Song Long gói 400g",
    25500,
    "images/products/nui-rau-cu-ong-dai-song-long-goi-400g.jpg",
    "nui-rau-cu-ong-dai-song-long-goi-400g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui rau củ chữ C Mezian gói 200g",
    13900,
    "images/products/nui-rau-cu-chu-c-mezian-goi-200g.jpg",
    "nui-rau-cu-chu-c-mezian-goi-200g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui Elbows số 35 Biondi gói 500g",
    36000/500g,
    "images/products/nui-elbows-so-35-biondi-goi-500g.jpg",
    "nui-elbows-so-35-biondi-goi-500g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui xoắn trivelle số 17 Biondi gói 500g",
    36000/500g,
    "images/products/nui-xoan-trivelle-so-17-biondi-goi-500g.jpg",
    "nui-xoan-trivelle-so-17-biondi-goi-500g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nui xoắn cao cấp Meizan gói 300g",
    20500/300g,
    "images/products/nui-xoan-cao-cap-meizan-goi-300g.jpg",
    "nui-xoan-cao-cap-meizan-goi-300g",
    1000,
    5,
    1,
    7,
    68
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì trứng cao cấp Meizan gói 250g",
    16000/250g,
    "images/products/mi-trung-cao-cap-meizan-goi-250g.jpg",
    "mi-trung-cao-cap-meizan-goi-250g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì chùm ngây không chiên New Way gói 280g",
    24000/200g,
    "images/products/mi-chum-ngay-khong-chien-new-way-goi-280g.jpg",
    "mi-chum-ngay-khong-chien-new-way-goi-280g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì Spaghetti số 4 Biondi gói 500g",
    34500/500g,
    "images/products/mi-spaghetti-so-4-biondi-goi-500g.jpg",
    "mi-spaghetti-so-4-biondi-goi-500g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì trứng sợi lớn Safoco gói 500g",
    30000/500g,
    "images/products/mi-trung-soi-lon-safoco-goi-500g.jpg",
    "mi-trung-soi-lon-safoco-goi-500g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì trứng sợi nhỏ Safoco gói 500g",
    30000/500g,
    "images/products/mi-trung-soi-nho-safoco-goi-500g.jpg",
    "mi-trung-soi-nho-safoco-goi-500g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì chay cao cấp Meizan gói 250g",
    18000/250g,
    "images/products/mi-chay-cao-cap-meizan-goi-250g.jpg",
    "mi-chay-cao-cap-meizan-goi-250g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì udon tươi Ông Chà Và gói 800g",
    49000,
    "images/products/mi-udon-tuoi-ong-cha-va-goi-800g.jpg",
    "mi-udon-tuoi-ong-cha-va-goi-800g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì Somen sợi mảnh Ông Chà Và gói 300g",
    40000,
    "images/products/mi-somen-soi-manh-ong-cha-va-goi-300g.jpg",
    "mi-somen-soi-manh-ong-cha-va-goi-300g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì Soba sợi dẹp Ông Chà Và gói 300g",
    40000,
    "images/products/mi-soba-soi-dep-ong-cha-va-goi-300g.jpg",
    "mi-soba-soi-dep-ong-cha-va-goi-300g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì Udon sợi dẹp Ông Chà Và gói 300g",
    40000,
    "images/products/mi-udon-soi-dep-ong-cha-va-goi-300g.jpg",
    "mi-udon-soi-dep-ong-cha-va-goi-300g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì Spaghetti Regina gói 400g",
    25000,
    "images/products/mi-spaghetti-regina-goi-400g.jpg",
    "mi-spaghetti-regina-goi-400g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì Spaghetti Olivoilà hộp 500g",
    51500/500g,
    "images/products/mi-spaghetti-olivoila-hop-500g.jpg",
    "mi-spaghetti-olivoila-hop-500g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì Ý Linguine Agnesi gói 500g",
    62000/500g,
    "images/products/mi-y-linguine-agnesi-goi-500g.jpg",
    "mi-y-linguine-agnesi-goi-500g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mì Ý Spaghetti Agnesi gói 500g",
    62000/500g,
    "images/products/mi-y-spaghetti-agnesi-goi-500g.jpg",
    "mi-y-spaghetti-agnesi-goi-500g",
    1000,
    5,
    1,
    7,
    69
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tokbokki phô mai Yopokki 120g",
    35000,
    "images/products/tokbokki-pho-mai-yopokki-120g.jpg",
    "tokbokki-pho-mai-yopokki-120g",
    1000,
    5,
    1,
    7,
    70
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tokbokki cay ngọt Yopokki 140g",
    35000,
    "images/products/tokbokki-cay-ngot-yopokki-140g.jpg",
    "tokbokki-cay-ngot-yopokki-140g",
    1000,
    5,
    1,
    7,
    70
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo Hàn Quốc có xốt HT Food 400g",
    39000/400g,
    "images/products/banh-gao-han-quoc-co-xot-ht-food-400g.jpg",
    "banh-gao-han-quoc-co-xot-ht-food-400g",
    1000,
    5,
    1,
    7,
    70
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tokbokki phô mai O'food 105g",
    33000,
    "images/products/tokbokki-pho-mai-ofood-105g.jpg",
    "tokbokki-pho-mai-ofood-105g",
    1000,
    5,
    1,
    7,
    70
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem sữa dừa Merino ly 53g",
    9000,
    "images/products/kem-sua-dua-merino-ly-53g.jpg",
    "kem-sua-dua-merino-ly-53g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem Magnum Almond Wall's cây 64.5g",
    30000,
    "images/products/kem-magnum-almond-walls-cay-645g.jpg",
    "kem-magnum-almond-walls-cay-645g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem dừa Vinamilk mịn hộp 220g",
    30000,
    "images/products/kem-dua-vinamilk-min-hop-220g.jpg",
    "kem-dua-vinamilk-min-hop-220g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem socola vani dâu Wall's 3in1 Neo hộp 390g",
    77000,
    "images/products/kem-socola-vani-dau-walls-3in1-neo-hop-390g.jpg",
    "kem-socola-vani-dau-walls-3in1-neo-hop-390g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem sầu riêng Vinamilk mịn hộp 220g",
    30000,
    "images/products/kem-sau-rieng-vinamilk-min-hop-220g.jpg",
    "kem-sau-rieng-vinamilk-min-hop-220g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem Dâu Vinamilk mịn hộp 220g",
    30000,
    "images/products/kem-dau-vinamilk-min-hop-220g.jpg",
    "kem-dau-vinamilk-min-hop-220g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem Topten Vanila Wall's cây 60g",
    12900,
    "images/products/kem-topten-vanila-walls-cay-60g.jpg",
    "kem-topten-vanila-walls-cay-60g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem Topten Socola Wall's cây 60g",
    12900,
    "images/products/kem-topten-socola-walls-cay-60g.jpg",
    "kem-topten-socola-walls-cay-60g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "4 cây kem Merino Super Teen 60g",
    36000,
    "images/products/4-cay-kem-merino-super-teen-60g.jpg",
    "4-cay-kem-merino-super-teen-60g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem Socola Merino Super Teen cây 60g",
    9000,
    "images/products/kem-socola-merino-super-teen-cay-60g.jpg",
    "kem-socola-merino-super-teen-cay-60g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa chua dẻo phô mai Merino gói 50g",
    6200,
    "images/products/sua-chua-deo-pho-mai-merino-goi-50g.jpg",
    "sua-chua-deo-pho-mai-merino-goi-50g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem cacao sô cô la Merino Yeah! cây 68g",
    9000,
    "images/products/kem-cacao-so-co-la-merino-yeah-cay-68g.jpg",
    "kem-cacao-so-co-la-merino-yeah-cay-68g",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem viên socola tròn Joyday cây 58ml",
    17900,
    "images/products/kem-vien-socola-tron-joyday-cay-58ml.jpg",
    "kem-vien-socola-tron-joyday-cay-58ml",
    1000,
    5,
    1,
    8,
    71
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa chua có đường Nutimilk 100g (12 lốc)",
    175000,
    "images/products/thung-48-hop-sua-chua-co-uong-nutimilk-100g-12-loc.jpg",
    "thung-48-hop-sua-chua-co-uong-nutimilk-100g-12-loc",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa chua Star có đường Vinamilk 100g",
    234000,
    "images/products/thung-48-hop-sua-chua-star-co-uong-vinamilk-100g.jpg",
    "thung-48-hop-sua-chua-star-co-uong-vinamilk-100g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa chua có đường Vinamilk 100g",
    276000,
    "images/products/thung-48-hop-sua-chua-co-uong-vinamilk-100g.jpg",
    "thung-48-hop-sua-chua-co-uong-vinamilk-100g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa chua ăn có đường Lothamilk 100g",
    175000,
    "images/products/thung-48-hop-sua-chua-an-co-uong-lothamilk-100g.jpg",
    "thung-48-hop-sua-chua-an-co-uong-lothamilk-100g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa chua ăn ít đường Nutimilk 100g",
    175000,
    "images/products/thung-48-hop-sua-chua-an-it-uong-nutimilk-100g.jpg",
    "thung-48-hop-sua-chua-an-it-uong-nutimilk-100g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa chua ăn thanh trùng DeliFres+ thạch dừa dưa lưới 80g",
    24000,
    "images/products/loc-4-hop-sua-chua-an-thanh-trung-delifres-thach-dua-dua-luoi-80g.jpg",
    "loc-4-hop-sua-chua-an-thanh-trung-delifres-thach-dua-dua-luoi-80g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 48 hộp sữa chua nha đam Nutimilk 100g (12 lốc)",
    210000,
    "images/products/thung-48-hop-sua-chua-nha-am-nutimilk-100g-12-loc.jpg",
    "thung-48-hop-sua-chua-nha-am-nutimilk-100g-12-loc",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa chua ăn không đường Nutimilk 100g",
    27000,
    "images/products/loc-4-hop-sua-chua-an-khong-uong-nutimilk-100g.jpg",
    "loc-4-hop-sua-chua-an-khong-uong-nutimilk-100g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa chua Nutimilk có đường 100g",
    26500,
    "images/products/loc-4-hop-sua-chua-nutimilk-co-uong-100g.jpg",
    "loc-4-hop-sua-chua-nutimilk-co-uong-100g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa chua Nutimilk nha đam 100g",
    31000,
    "images/products/loc-4-hop-sua-chua-nutimilk-nha-am-100g.jpg",
    "loc-4-hop-sua-chua-nutimilk-nha-am-100g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa chua ăn ít đường Nutimilk 100g",
    26500,
    "images/products/loc-4-hop-sua-chua-an-it-uong-nutimilk-100g.jpg",
    "loc-4-hop-sua-chua-an-it-uong-nutimilk-100g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa chua Lothamilk có đường 100g",
    27000,
    "images/products/loc-4-hop-sua-chua-lothamilk-co-uong-100g.jpg",
    "loc-4-hop-sua-chua-lothamilk-co-uong-100g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa chua Vinamilk không đường 100g",
    26000,
    "images/products/loc-4-hop-sua-chua-vinamilk-khong-uong-100g.jpg",
    "loc-4-hop-sua-chua-vinamilk-khong-uong-100g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 hộp sữa chua ăn thanh trùng DeliFres+ nha đam 80g",
    24000,
    "images/products/loc-4-hop-sua-chua-an-thanh-trung-delifres-nha-am-80g.jpg",
    "loc-4-hop-sua-chua-an-thanh-trung-delifres-nha-am-80g",
    1000,
    5,
    1,
    8,
    72
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 50 chai sữa chua uống có đường Nutimilk Nuvi 65ml",
    141000,
    "images/products/thung-50-chai-sua-chua-uong-co-uong-nutimilk-nuvi-65ml.jpg",
    "thung-50-chai-sua-chua-uong-co-uong-nutimilk-nuvi-65ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 50 chai sữa chua dưa gang Vinamilk Probi 65ml",
    223000,
    "images/products/thung-50-chai-sua-chua-dua-gang-vinamilk-probi-65ml.jpg",
    "thung-50-chai-sua-chua-dua-gang-vinamilk-probi-65ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai sữa chua Vinamilk Probi việt quất 130ml",
    198000,
    "images/products/thung-24-chai-sua-chua-vinamilk-probi-viet-quat-130ml.jpg",
    "thung-24-chai-sua-chua-vinamilk-probi-viet-quat-130ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 chai sữa chua có đường Vinamilk Probi 130ml",
    198000,
    "images/products/thung-24-chai-sua-chua-co-uong-vinamilk-probi-130ml.jpg",
    "thung-24-chai-sua-chua-co-uong-vinamilk-probi-130ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 chai sữa chua có đường NutiFood 65ml",
    24000,
    "images/products/loc-5-chai-sua-chua-co-uong-nutifood-65ml.jpg",
    "loc-5-chai-sua-chua-co-uong-nutifood-65ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 chai sữa chua ít đường Vinamilk Probi 130ml",
    37500/4 chai,
    "images/products/loc-4-chai-sua-chua-it-uong-vinamilk-probi-130ml.jpg",
    "loc-4-chai-sua-chua-it-uong-vinamilk-probi-130ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 chai sữa uống lên men Yakult 65ml",
    25000,
    "images/products/loc-5-chai-sua-uong-len-men-yakult-65ml.jpg",
    "loc-5-chai-sua-uong-len-men-yakult-65ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 chai sữa chua dưa gang Vinamilk Probi 65ml",
    26000,
    "images/products/loc-5-chai-sua-chua-dua-gang-vinamilk-probi-65ml.jpg",
    "loc-5-chai-sua-chua-dua-gang-vinamilk-probi-65ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 chai sữa chua ít đường Vinamilk Probi 65ml",
    26000/5 chai,
    "images/products/loc-5-chai-sua-chua-it-uong-vinamilk-probi-65ml.jpg",
    "loc-5-chai-sua-chua-it-uong-vinamilk-probi-65ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 5 chai sữa lên men ít đường Yakult 65ml",
    26000,
    "images/products/loc-5-chai-sua-len-men-it-uong-yakult-65ml.jpg",
    "loc-5-chai-sua-len-men-it-uong-yakult-65ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 chai sữa hương cam Betagen 85ml",
    25000,
    "images/products/loc-4-chai-sua-huong-cam-betagen-85ml.jpg",
    "loc-4-chai-sua-huong-cam-betagen-85ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 4 chai sữa hương dâu Betagen 85ml",
    25000,
    "images/products/loc-4-chai-sua-huong-dau-betagen-85ml.jpg",
    "loc-4-chai-sua-huong-dau-betagen-85ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "4 chai sữa chua ít đường Betagen 85ml",
    24000,
    "images/products/4-chai-sua-chua-it-uong-betagen-85ml.jpg",
    "4-chai-sua-chua-it-uong-betagen-85ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 50 chai sữa chua cam Vinamilk Probi 65ml",
    268000,
    "images/products/thung-50-chai-sua-chua-cam-vinamilk-probi-65ml.jpg",
    "thung-50-chai-sua-chua-cam-vinamilk-probi-65ml",
    1000,
    5,
    1,
    8,
    73
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai sợi Paysan Breton gói 70g",
    44000,
    "images/products/pho-mai-soi-paysan-breton-goi-70g.jpg",
    "pho-mai-soi-paysan-breton-goi-70g",
    1000,
    5,
    1,
    8,
    74
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai hun khói Nguyễn Hồng 200g",
    129000,
    "images/products/pho-mai-hun-khoi-nguyen-hong-200g.jpg",
    "pho-mai-hun-khoi-nguyen-hong-200g",
    1000,
    5,
    1,
    8,
    74
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai Con Bò Cười Light 120g (8 miếng)",
    40500/120g,
    "images/products/pho-mai-con-bo-cuoi-light-120g-8-mieng.jpg",
    "pho-mai-con-bo-cuoi-light-120g-8-mieng",
    1000,
    5,
    1,
    8,
    74
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai lát Con Bò Cười Burger 200g (10 lát)",
    71000/200g,
    "images/products/pho-mai-lat-con-bo-cuoi-burger-200g-10-lat.jpg",
    "pho-mai-lat-con-bo-cuoi-burger-200g-10-lat",
    1000,
    5,
    1,
    8,
    74
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai lát Con Bò Cười Sandwich 200g (10 lát)",
    71000/200g,
    "images/products/pho-mai-lat-con-bo-cuoi-sandwich-200g-10-lat.jpg",
    "pho-mai-lat-con-bo-cuoi-sandwich-200g-10-lat",
    1000,
    5,
    1,
    8,
    74
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai vị truyền thống Con Bò Cười hộp 224g (16 miếng)",
    67500,
    "images/products/pho-mai-vi-truyen-thong-con-bo-cuoi-hop-224g-16-mieng.jpg",
    "pho-mai-vi-truyen-thong-con-bo-cuoi-hop-224g-16-mieng",
    1000,
    5,
    1,
    8,
    74
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai mozzarella bào Bottega Zelachi gói 200g",
    94500,
    "images/products/pho-mai-mozzarella-bao-bottega-zelachi-goi-200g.jpg",
    "pho-mai-mozzarella-bao-bottega-zelachi-goi-200g",
    1000,
    5,
    1,
    8,
    74
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai vị dâu Con Bò Cười Belcube 78g (15 viên)",
    52000/78g,
    "images/products/pho-mai-vi-dau-con-bo-cuoi-belcube-78g-15-vien.jpg",
    "pho-mai-vi-dau-con-bo-cuoi-belcube-78g-15-vien",
    1000,
    5,
    1,
    8,
    74
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai lát Zott Sandwich 200g (12 lát)",
    65000/200g,
    "images/products/pho-mai-lat-zott-sandwich-200g-12-lat.jpg",
    "pho-mai-lat-zott-sandwich-200g-12-lat",
    1000,
    5,
    1,
    8,
    74
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai vị sữa Con Bò Cười Le Cube gói 78g (15 miếng)",
    52000,
    "images/products/pho-mai-vi-sua-con-bo-cuoi-le-cube-goi-78g-15-mieng.jpg",
    "pho-mai-vi-sua-con-bo-cuoi-le-cube-goi-78g-15-mieng",
    1000,
    5,
    1,
    8,
    74
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Panna Cotta đào mật ong Tâm Lợi hũ 100ml",
    17900,
    "images/products/panna-cotta-ao-mat-ong-tam-loi-hu-100ml.jpg",
    "panna-cotta-ao-mat-ong-tam-loi-hu-100ml",
    1000,
    5,
    1,
    8,
    75
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Rau câu thanh long sữa dừa Tâm Lợi hũ 100g",
    10500,
    "images/products/rau-cau-thanh-long-sua-dua-tam-loi-hu-100g.jpg",
    "rau-cau-thanh-long-sua-dua-tam-loi-hu-100g",
    1000,
    5,
    1,
    8,
    75
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước yến nha đam Sài Gòn Milk chai 300ml",
    14000/300ml,
    "images/products/nuoc-yen-nha-am-sai-gon-milk-chai-300ml.jpg",
    "nuoc-yen-nha-am-sai-gon-milk-chai-300ml",
    1000,
    5,
    1,
    8,
    75
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa hạt sen Yessy chai 330ml",
    14000/330ml,
    "images/products/sua-hat-sen-yessy-chai-330ml.jpg",
    "sua-hat-sen-yessy-chai-330ml",
    1000,
    5,
    1,
    8,
    75
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa bắp Yessy chai 330ml",
    14000/330ml,
    "images/products/sua-bap-yessy-chai-330ml.jpg",
    "sua-bap-yessy-chai-330ml",
    1000,
    5,
    1,
    8,
    75
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mủ trôm nha đam hạt chia Yessy chai 330ml",
    16000/330ml,
    "images/products/mu-trom-nha-am-hat-chia-yessy-chai-330ml.jpg",
    "mu-trom-nha-am-hat-chia-yessy-chai-330ml",
    1000,
    5,
    1,
    8,
    75
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước chanh dây hạt chia Sài Gòn Milk 300ml",
    14000,
    "images/products/nuoc-chanh-day-hat-chia-sai-gon-milk-300ml.jpg",
    "nuoc-chanh-day-hat-chia-sai-gon-milk-300ml",
    1000,
    5,
    1,
    8,
    75
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sâm bí đao nha đam Sài Gòn chai 300ml",
    15000,
    "images/products/sam-bi-ao-nha-am-sai-gon-chai-300ml.jpg",
    "sam-bi-ao-nha-am-sai-gon-chai-300ml",
    1000,
    5,
    1,
    8,
    75
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 2 Bánh flan Caramel cafe sữa dừa Ánh Hồng hũ 82g",
    26000,
    "images/products/loc-2-banh-flan-caramel-cafe-sua-dua-anh-hong-hu-82g.jpg",
    "loc-2-banh-flan-caramel-cafe-sua-dua-anh-hong-hu-82g",
    1000,
    5,
    1,
    8,
    75
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa bắp Sài Gòn chai 300ml",
    15000/330ml,
    "images/products/sua-bap-sai-gon-chai-300ml.jpg",
    "sua-bap-sai-gon-chai-300ml",
    1000,
    5,
    1,
    8,
    75
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò tôm thịt M.Ngon 400g",
    39000,
    "images/products/cha-gio-tom-thit-mngon-400g.jpg",
    "cha-gio-tom-thit-mngon-400g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò da xốp chay Trần Gia 300g",
    31500,
    "images/products/cha-gio-da-xop-chay-tran-gia-300g.jpg",
    "cha-gio-da-xop-chay-tran-gia-300g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò đặc biệt hải sản Cầu Tre gói 500g",
    59000,
    "images/products/cha-gio-ac-biet-hai-san-cau-tre-goi-500g.jpg",
    "cha-gio-ac-biet-hai-san-cau-tre-goi-500g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò da xốp mực Trần Gia 300g",
    41500,
    "images/products/cha-gio-da-xop-muc-tran-gia-300g.jpg",
    "cha-gio-da-xop-muc-tran-gia-300g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò đặc biệt nhân thịt Cầu Tre gói 500g",
    64500,
    "images/products/cha-gio-ac-biet-nhan-thit-cau-tre-goi-500g.jpg",
    "cha-gio-ac-biet-nhan-thit-cau-tre-goi-500g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò xốp tôm thịt Cholimex 500g",
    52000,
    "images/products/cha-gio-xop-tom-thit-cholimex-500g.jpg",
    "cha-gio-xop-tom-thit-cholimex-500g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò da xốp nhân thịt Cầu Tre gói 500g",
    75000,
    "images/products/cha-gio-da-xop-nhan-thit-cau-tre-goi-500g.jpg",
    "cha-gio-da-xop-nhan-thit-cau-tre-goi-500g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo chiên ăn liền - Chả giò, xúc xích, dầu ăn",
    177500,
    "images/products/combo-chien-an-lien---cha-gio-xuc-xich-dau-an.jpg",
    "combo-chien-an-lien---cha-gio-xuc-xich-dau-an",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò rế con tôm Vissan 300g",
    59000,
    "images/products/cha-gio-re-con-tom-vissan-300g.jpg",
    "cha-gio-re-con-tom-vissan-300g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò rế thịt Vissan 500g",
    64500,
    "images/products/cha-gio-re-thit-vissan-500g.jpg",
    "cha-gio-re-thit-vissan-500g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò nhân thịt Cầu Tre gói 500g",
    60500,
    "images/products/cha-gio-nhan-thit-cau-tre-goi-500g.jpg",
    "cha-gio-nhan-thit-cau-tre-goi-500g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Phô mai da xốp nhân tôm mayonnaise Cầu Tre 300g",
    70000,
    "images/products/pho-mai-da-xop-nhan-tom-mayonnaise-cau-tre-300g.jpg",
    "pho-mai-da-xop-nhan-tom-mayonnaise-cau-tre-300g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả giò da xốp tôm và thịt Cầu Tre gói 400g",
    73000,
    "images/products/cha-gio-da-xop-tom-va-thit-cau-tre-goi-400g.jpg",
    "cha-gio-da-xop-tom-va-thit-cau-tre-goi-400g",
    1000,
    5,
    1,
    9,
    76
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh Ho-ttoeok phô mai Mozzarella Kitkool 300g",
    45250,
    "images/products/banh-ho-ttoeok-pho-mai-mozzarella-kitkool-300g.jpg",
    "banh-ho-ttoeok-pho-mai-mozzarella-kitkool-300g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh phô mai KCook gói 330g",
    45250/330g,
    "images/products/banh-pho-mai-kcook-goi-330g.jpg",
    "banh-pho-mai-kcook-goi-330g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Pizza xúc xích xông khói nấm hương Hoàng Phát 180g",
    25000/180g,
    "images/products/pizza-xuc-xich-xong-khoi-nam-huong-hoang-phat-180g.jpg",
    "pizza-xuc-xich-xong-khoi-nam-huong-hoang-phat-180g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Pizza phô mai Manna 120g",
    25000/120g,
    "images/products/pizza-pho-mai-manna-120g.jpg",
    "pizza-pho-mai-manna-120g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Pizza hải sản vị Ý Manna 120g",
    25000/120g,
    "images/products/pizza-hai-san-vi-y-manna-120g.jpg",
    "pizza-hai-san-vi-y-manna-120g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bao nhân thịt trứng cút C.P 125g",
    13900/125g,
    "images/products/banh-bao-nhan-thit-trung-cut-cp-125g.jpg",
    "banh-bao-nhan-thit-trung-cut-cp-125g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bao nhân thịt heo trứng muối Thọ Phát 400g",
    43500/400g,
    "images/products/banh-bao-nhan-thit-heo-trung-muoi-tho-phat-400g.jpg",
    "banh-bao-nhan-thit-heo-trung-muoi-tho-phat-400g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bao cadé Thọ Phát 240g",
    18500/240g,
    "images/products/banh-bao-cade-tho-phat-240g.jpg",
    "banh-bao-cade-tho-phat-240g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bao nhân khoai môn C.P 270g",
    21000/270g,
    "images/products/banh-bao-nhan-khoai-mon-cp-270g.jpg",
    "banh-bao-nhan-khoai-mon-cp-270g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo Hàn Quốc phô mai có xốt HT Food 400g",
    51500/400g,
    "images/products/banh-gao-han-quoc-pho-mai-co-xot-ht-food-400g.jpg",
    "banh-gao-han-quoc-pho-mai-co-xot-ht-food-400g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bao nhân đậu xanh Thọ Phát 300g",
    28000/300g,
    "images/products/banh-bao-nhan-au-xanh-tho-phat-300g.jpg",
    "banh-bao-nhan-au-xanh-tho-phat-300g",
    1000,
    5,
    1,
    9,
    77
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả lụa bì ớt xiêm xanh G Kitchen cây 450g",
    69000,
    "images/products/cha-lua-bi-ot-xiem-xanh-g-kitchen-cay-450g.jpg",
    "cha-lua-bi-ot-xiem-xanh-g-kitchen-cay-450g",
    1000,
    5,
    1,
    9,
    78
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả lụa G Kitchen cây 500g",
    102500/500g,
    "images/products/cha-lua-g-kitchen-cay-500g.jpg",
    "cha-lua-g-kitchen-cay-500g",
    1000,
    5,
    1,
    9,
    78
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả lụa huế Hoa Doanh gói 200g",
    29000,
    "images/products/cha-lua-hue-hoa-doanh-goi-200g.jpg",
    "cha-lua-hue-hoa-doanh-goi-200g",
    1000,
    5,
    1,
    9,
    78
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Giò lụa hảo hạng MEATDeli cây 300g",
    47000,
    "images/products/gio-lua-hao-hang-meatdeli-cay-300g.jpg",
    "gio-lua-hao-hang-meatdeli-cay-300g",
    1000,
    5,
    1,
    9,
    78
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả lụa bì MEATDeli cây 50g",
    7800,
    "images/products/cha-lua-bi-meatdeli-cay-50g.jpg",
    "cha-lua-bi-meatdeli-cay-50g",
    1000,
    5,
    1,
    9,
    78
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Giò thủ G Kitchen cây 475g",
    91000/475g,
    "images/products/gio-thu-g-kitchen-cay-475g.jpg",
    "gio-thu-g-kitchen-cay-475g",
    1000,
    5,
    1,
    9,
    78
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Giò thủ Le Gourmet 200g",
    35000/200g,
    "images/products/gio-thu-le-gourmet-200g.jpg",
    "gio-thu-le-gourmet-200g",
    1000,
    5,
    1,
    9,
    78
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả lụa bì ớt xiêm xanh 450g và giò thủ G Kitchen 475g",
    160000,
    "images/products/cha-lua-bi-ot-xiem-xanh-450g-va-gio-thu-g-kitchen-475g.jpg",
    "cha-lua-bi-ot-xiem-xanh-450g-va-gio-thu-g-kitchen-475g",
    1000,
    5,
    1,
    9,
    78
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả lụa bì ớt xiêm xanh MEATDeli cây 300g",
    71000,
    "images/products/cha-lua-bi-ot-xiem-xanh-meatdeli-cay-300g.jpg",
    "cha-lua-bi-ot-xiem-xanh-meatdeli-cay-300g",
    1000,
    5,
    1,
    9,
    78
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả lụa bì vị mala MEATDeli cây 50g",
    13000,
    "images/products/cha-lua-bi-vi-mala-meatdeli-cay-50g.jpg",
    "cha-lua-bi-vi-mala-meatdeli-cay-50g",
    1000,
    5,
    1,
    9,
    78
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả cốm nếp thơm MEATDeli gói 200g",
    35000,
    "images/products/cha-com-nep-thom-meatdeli-goi-200g.jpg",
    "cha-com-nep-thom-meatdeli-goi-200g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả chiên MEATDeli gói 300g",
    57000,
    "images/products/cha-chien-meatdeli-goi-300g.jpg",
    "cha-chien-meatdeli-goi-300g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá viên cao cấp C.P gói 250g",
    26000/250g,
    "images/products/ca-vien-cao-cap-cp-goi-250g.jpg",
    "ca-vien-cao-cap-cp-goi-250g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Viên hải sản tam sắc Kitkool gói 200g",
    37000,
    "images/products/vien-hai-san-tam-sac-kitkool-goi-200g.jpg",
    "vien-hai-san-tam-sac-kitkool-goi-200g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả cá basa viên thì là Nhất Tâm gói 200g",
    27000,
    "images/products/cha-ca-basa-vien-thi-la-nhat-tam-goi-200g.jpg",
    "cha-ca-basa-vien-thi-la-nhat-tam-goi-200g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá viên rau củ Việt Sin 200g",
    25000,
    "images/products/ca-vien-rau-cu-viet-sin-200g.jpg",
    "ca-vien-rau-cu-viet-sin-200g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bò viên Hoa Doanh gói 200g",
    37000/200g,
    "images/products/bo-vien-hoa-doanh-goi-200g.jpg",
    "bo-vien-hoa-doanh-goi-200g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo thả lẩu - 3 bịch cá bò tôm viên 200g",
    89000,
    "images/products/combo-tha-lau---3-bich-ca-bo-tom-vien-200g.jpg",
    "combo-tha-lau---3-bich-ca-bo-tom-vien-200g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Viên hải sản rau củ LC FOODS 200g",
    31000,
    "images/products/vien-hai-san-rau-cu-lc-foods-200g.jpg",
    "vien-hai-san-rau-cu-lc-foods-200g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bò viên FCook gói 200g",
    32000,
    "images/products/bo-vien-fcook-goi-200g.jpg",
    "bo-vien-fcook-goi-200g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chả cá hải sản Hoa Doanh gói 60g",
    12100,
    "images/products/cha-ca-hai-san-hoa-doanh-goi-60g.jpg",
    "cha-ca-hai-san-hoa-doanh-goi-60g",
    1000,
    5,
    1,
    9,
    82
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu phụ Làng Mơ Ichiban hộp 500g",
    16400/500g,
    "images/products/au-phu-lang-mo-ichiban-hop-500g.jpg",
    "au-phu-lang-mo-ichiban-hop-500g",
    1000,
    5,
    1,
    9,
    83
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu hũ chiên Vị Nguyên hộp 300g",
    17500/300g,
    "images/products/au-hu-chien-vi-nguyen-hop-300g.jpg",
    "au-hu-chien-vi-nguyen-hop-300g",
    1000,
    5,
    1,
    9,
    83
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tàu hũ mềm Ome Ichiban hộp 330g",
    13900,
    "images/products/tau-hu-mem-ome-ichiban-hop-330g.png",
    "tau-hu-mem-ome-ichiban-hop-330g",
    1000,
    5,
    1,
    9,
    83
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tàu hũ trắng Ichi Sakura cây 240g",
    10000/240g,
    "images/products/tau-hu-trang-ichi-sakura-cay-240g.png",
    "tau-hu-trang-ichi-sakura-cay-240g",
    1000,
    5,
    1,
    9,
    83
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tàu hũ non Ichi Sakura hộp 350g",
    12000/350g,
    "images/products/tau-hu-non-ichi-sakura-hop-350g.png",
    "tau-hu-non-ichi-sakura-hop-350g",
    1000,
    5,
    1,
    9,
    83
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tàu hũ trứng Ichi Sakura cây 160g",
    12900/160g,
    "images/products/tau-hu-trung-ichi-sakura-cay-160g.png",
    "tau-hu-trung-ichi-sakura-cay-160g",
    1000,
    5,
    1,
    9,
    83
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tàu hũ chiên Ichi Sakura gói 500g",
    29000/500g,
    "images/products/tau-hu-chien-ichi-sakura-goi-500g.jpg",
    "tau-hu-chien-ichi-sakura-goi-500g",
    1000,
    5,
    1,
    9,
    83
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu hũ lụa Vị Nguyên cây 220g",
    9000/220g,
    "images/products/au-hu-lua-vi-nguyen-cay-220g.png",
    "au-hu-lua-vi-nguyen-cay-220g",
    1000,
    5,
    1,
    9,
    83
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu hũ ta Vị Nguyên hộp 280g",
    13500,
    "images/products/au-hu-ta-vi-nguyen-hop-280g.png",
    "au-hu-ta-vi-nguyen-hop-280g",
    1000,
    5,
    1,
    9,
    83
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu hũ non Vị Nguyên hộp 280g",
    13000,
    "images/products/au-hu-non-vi-nguyen-hop-280g.png",
    "au-hu-non-vi-nguyen-hop-280g",
    1000,
    5,
    1,
    9,
    83
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bò bít tết Úc Mr.T khay 200g",
    102000,
    "images/products/bo-bit-tet-uc-mrt-khay-200g.jpg",
    "bo-bit-tet-uc-mrt-khay-200g",
    1000,
    5,
    1,
    9,
    84
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá trứng đông lạnh SG Food 200g",
    29500/200g,
    "images/products/ca-trung-ong-lanh-sg-food-200g.jpg",
    "ca-trung-ong-lanh-sg-food-200g",
    1000,
    5,
    1,
    9,
    84
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt ba rọi bò Mỹ đông lạnh Thảo Tiến 300g",
    99000/300g,
    "images/products/thit-ba-roi-bo-my-ong-lanh-thao-tien-300g.jpg",
    "thit-ba-roi-bo-my-ong-lanh-thao-tien-300g",
    1000,
    5,
    1,
    9,
    84
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá trứng đông lạnh Tân Hải Hòa 200g",
    33000/200g,
    "images/products/ca-trung-ong-lanh-tan-hai-hoa-200g.jpg",
    "ca-trung-ong-lanh-tan-hai-hoa-200g",
    1000,
    5,
    1,
    9,
    84
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bào ngư đông lạnh Tân Hải Hòa khay 300g",
    143000,
    "images/products/bao-ngu-ong-lanh-tan-hai-hoa-khay-300g.jpg",
    "bao-ngu-ong-lanh-tan-hai-hoa-khay-300g",
    1000,
    5,
    1,
    9,
    84
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tôm khô size XS Lam Điền hũ 100g",
    79000,
    "images/products/tom-kho-size-xs-lam-ien-hu-100g.jpg",
    "tom-kho-size-xs-lam-ien-hu-100g",
    1000,
    5,
    1,
    9,
    84
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tôm khô size L Lam Điền hũ 100g",
    119000,
    "images/products/tom-kho-size-l-lam-ien-hu-100g.jpg",
    "tom-kho-size-l-lam-ien-hu-100g",
    1000,
    5,
    1,
    9,
    84
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt ba chỉ bò Mỹ cuộn Orifood 300g",
    115000/300g,
    "images/products/thit-ba-chi-bo-my-cuon-orifood-300g.jpg",
    "thit-ba-chi-bo-my-cuon-orifood-300g",
    1000,
    5,
    1,
    9,
    84
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dưa leo rừng chua ngọt Phú An Khang gói 200g",
    14500,
    "images/products/dua-leo-rung-chua-ngot-phu-an-khang-goi-200g.jpg",
    "dua-leo-rung-chua-ngot-phu-an-khang-goi-200g",
    1000,
    5,
    1,
    9,
    86
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cải sậy chua ngọt Mạnh Nghĩa gói 500g",
    26000,
    "images/products/cai-say-chua-ngot-manh-nghia-goi-500g.jpg",
    "cai-say-chua-ngot-manh-nghia-goi-500g",
    1000,
    5,
    1,
    9,
    86
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cà pháo trắng Ngọc Liên hũ 365g",
    26500,
    "images/products/ca-phao-trang-ngoc-lien-hu-365g.png",
    "ca-phao-trang-ngoc-lien-hu-365g",
    1000,
    5,
    1,
    9,
    86
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Há cảo mini Cầu Tre 500g",
    58000,
    "images/products/ha-cao-mini-cau-tre-500g.jpg",
    "ha-cao-mini-cau-tre-500g",
    1000,
    5,
    1,
    9,
    87
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Há cảo hải sản Cầu Tre 500g",
    67300,
    "images/products/ha-cao-hai-san-cau-tre-500g.jpg",
    "ha-cao-hai-san-cau-tre-500g",
    1000,
    5,
    1,
    9,
    87
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh healthy mandu tôm Bibigo 300g",
    72000/300g,
    "images/products/banh-healthy-mandu-tom-bibigo-300g.jpg",
    "banh-healthy-mandu-tom-bibigo-300g",
    1000,
    5,
    1,
    9,
    87
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sủi cảo nhân thịt TH True Food gói 300g",
    62000,
    "images/products/sui-cao-nhan-thit-th-true-food-goi-300g.jpg",
    "sui-cao-nhan-thit-th-true-food-goi-300g",
    1000,
    5,
    1,
    9,
    87
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh xếp ăn sáng nhân thịt Bibigo 132g",
    26000,
    "images/products/banh-xep-an-sang-nhan-thit-bibigo-132g.jpg",
    "banh-xep-an-sang-nhan-thit-bibigo-132g",
    1000,
    5,
    1,
    9,
    87
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh xếp nhân thịt Bibigo 420g",
    80000,
    "images/products/banh-xep-nhan-thit-bibigo-420g.jpg",
    "banh-xep-nhan-thit-bibigo-420g",
    1000,
    5,
    1,
    9,
    87
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hoành thánh tôm thịt Vissan 200g",
    38000,
    "images/products/hoanh-thanh-tom-thit-vissan-200g.jpg",
    "hoanh-thanh-tom-thit-vissan-200g",
    1000,
    5,
    1,
    9,
    87
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Há cảo mini tôm thịt Việt Sin 500g",
    77000,
    "images/products/ha-cao-mini-tom-thit-viet-sin-500g.jpg",
    "ha-cao-mini-tom-thit-viet-sin-500g",
    1000,
    5,
    1,
    9,
    87
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo viên thả lẩu Nhất Tâm 300g",
    32000/300g,
    "images/products/combo-vien-tha-lau-nhat-tam-300g.jpg",
    "combo-vien-tha-lau-nhat-tam-300g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lẩu đuôi bò 500g",
    139000/500g,
    "images/products/lau-uoi-bo-500g.jpg",
    "lau-uoi-bo-500g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lẩu gà lá giang 500g",
    109000/500g,
    "images/products/lau-ga-la-giang-500g.jpg",
    "lau-ga-la-giang-500g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lẩu bò 500g",
    223000/500g,
    "images/products/lau-bo-500g.jpg",
    "lau-bo-500g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thanh surimi cua 3N Foods 250g",
    70000,
    "images/products/thanh-surimi-cua-3n-foods-250g.jpg",
    "thanh-surimi-cua-3n-foods-250g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lẩu thái SG Food 500g",
    88500/500g,
    "images/products/lau-thai-sg-food-500g.jpg",
    "lau-thai-sg-food-500g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xốt lẩu kim chi Cholimex 280g",
    33000,
    "images/products/xot-lau-kim-chi-cholimex-280g.jpg",
    "xot-lau-kim-chi-cholimex-280g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xốt gia vị lẩu Thái Chinsu 180g",
    31000,
    "images/products/xot-gia-vi-lau-thai-chinsu-180g.jpg",
    "xot-gia-vi-lau-thai-chinsu-180g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá viên cốm non Fcook Hoa Doanh gói 250g",
    30000,
    "images/products/ca-vien-com-non-fcook-hoa-doanh-goi-250g.jpg",
    "ca-vien-com-non-fcook-hoa-doanh-goi-250g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bò viên phở Fcook Hoa Doanh gói 200g",
    33000,
    "images/products/bo-vien-pho-fcook-hoa-doanh-goi-200g.jpg",
    "bo-vien-pho-fcook-hoa-doanh-goi-200g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Cá viên Kitkool gói 500g",
    73000,
    "images/products/ca-vien-kitkool-goi-500g.jpg",
    "ca-vien-kitkool-goi-500g",
    1000,
    5,
    1,
    9,
    88
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy bơ Kokola 400g",
    55000/xô,
    "images/products/banh-quy-bo-kokola-400g.jpg",
    "banh-quy-bo-kokola-400g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh cracker kem dẻo vị dừa sầu riêng Bibica Gooka 360g",
    45500/hộp,
    "images/products/banh-cracker-kem-deo-vi-dua-sau-rieng-bibica-gooka-360g.jpg",
    "banh-cracker-kem-deo-vi-dua-sau-rieng-bibica-gooka-360g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh cracker vị rau AFC Dinh Dưỡng 8 gói",
    22000/hộp,
    "images/products/banh-cracker-vi-rau-afc-dinh-duong-8-goi.jpg",
    "banh-cracker-vi-rau-afc-dinh-duong-8-goi",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy vị rau củ Richy Kenju 192g",
    33000/gói,
    "images/products/banh-quy-vi-rau-cu-richy-kenju-192g.jpg",
    "banh-quy-vi-rau-cu-richy-kenju-192g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy chà bông Richy Kenju 192g",
    33000/gói,
    "images/products/banh-quy-cha-bong-richy-kenju-192g.jpg",
    "banh-quy-cha-bong-richy-kenju-192g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh cracker lúa mì AFC Dinh Dưỡng 8 cái",
    22000/hộp,
    "images/products/banh-cracker-lua-mi-afc-dinh-duong-8-cai.jpg",
    "banh-cracker-lua-mi-afc-dinh-duong-8-cai",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh cá vị gà BBQ Orion Marine Boy 35g",
    13500/hộp,
    "images/products/banh-ca-vi-ga-bbq-orion-marine-boy-35g.jpg",
    "banh-ca-vi-ga-bbq-orion-marine-boy-35g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bơ trứng Richy Karo 270g",
    37000/gói,
    "images/products/banh-bo-trung-richy-karo-270g.jpg",
    "banh-bo-trung-richy-karo-270g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy kem dẻo Richy Kenju Nougat kem sữa 186g",
    46000/gói,
    "images/products/banh-quy-kem-deo-richy-kenju-nougat-kem-sua-186g.jpg",
    "banh-quy-kem-deo-richy-kenju-nougat-kem-sua-186g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy kem việt quất Oreo 119.6g",
    17500/gói,
    "images/products/banh-quy-kem-viet-quat-oreo-1196g.jpg",
    "banh-quy-kem-viet-quat-oreo-1196g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy kem vani Oreo 119.6g",
    17500/gói,
    "images/products/banh-quy-kem-vani-oreo-1196g.jpg",
    "banh-quy-kem-vani-oreo-1196g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 20 hộp bánh quy socola Orion Miz 54g",
    290000/thùng,
    "images/products/thung-20-hop-banh-quy-socola-orion-miz-54g.jpg",
    "thung-20-hop-banh-quy-socola-orion-miz-54g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 20 hộp bánh cá vị rong biển Orion Marine Boy 35g",
    260000/thùng,
    "images/products/thung-20-hop-banh-ca-vi-rong-bien-orion-marine-boy-35g.jpg",
    "thung-20-hop-banh-ca-vi-rong-bien-orion-marine-boy-35g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 20 hộp bánh cá vị tôm nướng Orion Marine Boy 35g",
    260000/thùng,
    "images/products/thung-20-hop-banh-ca-vi-tom-nuong-orion-marine-boy-35g.jpg",
    "thung-20-hop-banh-ca-vi-tom-nuong-orion-marine-boy-35g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 20 hộp bánh cá vị gà BBQ Orion Marine Boy 35g",
    260000/thùng,
    "images/products/thung-20-hop-banh-ca-vi-ga-bbq-orion-marine-boy-35g.jpg",
    "thung-20-hop-banh-ca-vi-ga-bbq-orion-marine-boy-35g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy socola dâu Parle Platina Hide & Seek 112.5g",
    26500/gói,
    "images/products/banh-quy-socola-dau-parle-platina-hide--seek-1125g.jpg",
    "banh-quy-socola-dau-parle-platina-hide--seek-1125g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy socola Parle Platina Hide & Seek 112.5g",
    26500/gói,
    "images/products/banh-quy-socola-parle-platina-hide--seek-1125g.jpg",
    "banh-quy-socola-parle-platina-hide--seek-1125g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh cracker kem dẻo vị tảo Bibica Gooka 180g",
    31500/hộp,
    "images/products/banh-cracker-kem-deo-vi-tao-bibica-gooka-180g.jpg",
    "banh-cracker-kem-deo-vi-tao-bibica-gooka-180g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh phô mai lắc Orion 31.6g",
    13700/hộp,
    "images/products/banh-pho-mai-lac-orion-316g.jpg",
    "banh-pho-mai-lac-orion-316g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy dâu kem socola Imperial 100g",
    18400/gói,
    "images/products/banh-quy-dau-kem-socola-imperial-100g.jpg",
    "banh-quy-dau-kem-socola-imperial-100g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy socola kem dâu Imperial 100g",
    18400/gói,
    "images/products/banh-quy-socola-kem-dau-imperial-100g.jpg",
    "banh-quy-socola-kem-dau-imperial-100g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy kem dẻo Richy Kenju Nougat Latte 155g",
    48500/gói,
    "images/products/banh-quy-kem-deo-richy-kenju-nougat-latte-155g.jpg",
    "banh-quy-kem-deo-richy-kenju-nougat-latte-155g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy mạch nha trứng muối Franzzi 102g",
    33000/gói,
    "images/products/banh-quy-mach-nha-trung-muoi-franzzi-102g.jpg",
    "banh-quy-mach-nha-trung-muoi-franzzi-102g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh trứng sữa chua hạt điều Tipo 126g",
    33500/hộp,
    "images/products/banh-trung-sua-chua-hat-ieu-tipo-126g.jpg",
    "banh-trung-sua-chua-hat-ieu-tipo-126g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy kẹp kem phô mai Lexus 150g",
    28000/hộp,
    "images/products/banh-quy-kep-kem-pho-mai-lexus-150g.jpg",
    "banh-quy-kep-kem-pho-mai-lexus-150g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gấu nhân caramel Meiji 40g",
    24500/hộp,
    "images/products/banh-gau-nhan-caramel-meiji-40g.jpg",
    "banh-gau-nhan-caramel-meiji-40g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh cracker vị cốm AFC 5 gói",
    25000/hộp,
    "images/products/banh-cracker-vi-com-afc-5-goi.jpg",
    "banh-cracker-vi-com-afc-5-goi",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh khoai tây tảo biển TOK 36.5g",
    12100/gói,
    "images/products/banh-khoai-tay-tao-bien-tok-365g.jpg",
    "banh-khoai-tay-tao-bien-tok-365g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh khoai tây phô mai TOK 36.5g",
    12100/gói,
    "images/products/banh-khoai-tay-pho-mai-tok-365g.jpg",
    "banh-khoai-tay-pho-mai-tok-365g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh quy caramel flan AFC 109g",
    24500/hộp,
    "images/products/banh-quy-caramel-flan-afc-109g.jpg",
    "banh-quy-caramel-flan-afc-109g",
    1000,
    5,
    1,
    10,
    89
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo vị phô mai Play Nutrition gói 108g",
    19000/gói,
    "images/products/banh-gao-vi-pho-mai-play-nutrition-goi-108g.jpg",
    "banh-gao-vi-pho-mai-play-nutrition-goi-108g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo vị phô mai Rice Crispy Rice Biscuit of Taiwan gói 320g",
    56250/gói,
    "images/products/banh-gao-vi-pho-mai-rice-crispy-rice-biscuit-of-taiwan-goi-320g.jpg",
    "banh-gao-vi-pho-mai-rice-crispy-rice-biscuit-of-taiwan-goi-320g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo vị cốm sen Orion An gói 168g",
    32000/gói,
    "images/products/banh-gao-vi-com-sen-orion-an-goi-168g.jpg",
    "banh-gao-vi-com-sen-orion-an-goi-168g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo vị rong biển Play Nutrition gói 108g",
    38000/gói,
    "images/products/banh-gao-vi-rong-bien-play-nutrition-goi-108g.jpg",
    "banh-gao-vi-rong-bien-play-nutrition-goi-108g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo nướng vị tảo biển Orion An gói 111.3g",
    23000/gói,
    "images/products/banh-gao-nuong-vi-tao-bien-orion-an-goi-1113g.jpg",
    "banh-gao-nuong-vi-tao-bien-orion-an-goi-1113g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo nướng vị tự nhiên Orion An gói 151.2g",
    23000/gói,
    "images/products/banh-gao-nuong-vi-tu-nhien-orion-an-goi-1512g.jpg",
    "banh-gao-nuong-vi-tu-nhien-orion-an-goi-1512g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 thanh bánh gạo mầm Gaba mè rang hạt điều FnV",
    40000/gói,
    "images/products/6-thanh-banh-gao-mam-gaba-me-rang-hat-ieu-fnv.jpg",
    "6-thanh-banh-gao-mam-gaba-me-rang-hat-ieu-fnv",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo vị ngọt Richy gói 303g",
    39000/gói,
    "images/products/banh-gao-vi-ngot-richy-goi-303g.jpg",
    "banh-gao-vi-ngot-richy-goi-303g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo vị khoai tây phô mai nướng Orion An gói 100.8g",
    23000/gói,
    "images/products/banh-gao-vi-khoai-tay-pho-mai-nuong-orion-an-goi-1008g.jpg",
    "banh-gao-vi-khoai-tay-pho-mai-nuong-orion-an-goi-1008g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo Nhật vị Shouyu mật ong Ichi gói 100g",
    21000/gói,
    "images/products/banh-gao-nhat-vi-shouyu-mat-ong-ichi-goi-100g.jpg",
    "banh-gao-nhat-vi-shouyu-mat-ong-ichi-goi-100g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo Nhật mini vị mật ong Ichi 120g",
    29500/gói,
    "images/products/banh-gao-nhat-mini-vi-mat-ong-ichi-120g.jpg",
    "banh-gao-nhat-mini-vi-mat-ong-ichi-120g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh gạo nướng chà bông Orion An gói 145.6g",
    38000/gói,
    "images/products/banh-gao-nuong-cha-bong-orion-an-goi-1456g.jpg",
    "banh-gao-nuong-cha-bong-orion-an-goi-1456g",
    1000,
    5,
    1,
    10,
    90
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Yến mạch trái cây Sunrise bịch 300g",
    60000,
    "images/products/yen-mach-trai-cay-sunrise-bich-300g.png",
    "yen-mach-trai-cay-sunrise-bich-300g",
    1000,
    5,
    1,
    10,
    92
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Yến mạch nguyên chất Oatmeal Cereal gói 350g",
    56000,
    "images/products/yen-mach-nguyen-chat-oatmeal-cereal-goi-350g.png",
    "yen-mach-nguyen-chat-oatmeal-cereal-goi-350g",
    1000,
    5,
    1,
    10,
    92
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ngũ cốc ăn sáng Nestlé Milo gói 70g",
    31500,
    "images/products/ngu-coc-an-sang-nestle-milo-goi-70g.jpg",
    "ngu-coc-an-sang-nestle-milo-goi-70g",
    1000,
    5,
    1,
    10,
    92
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Granola Sunrise gói 300g",
    114000,
    "images/products/granola-sunrise-goi-300g.jpg",
    "granola-sunrise-goi-300g",
    1000,
    5,
    1,
    10,
    92
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột ngũ cốc Vitapro bịch 400g",
    35000,
    "images/products/bot-ngu-coc-vitapro-bich-400g.png",
    "bot-ngu-coc-vitapro-bich-400g",
    1000,
    5,
    1,
    10,
    92
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột đậu xanh hạt sen mật ong Vitapro bịch 420g",
    35000,
    "images/products/bot-au-xanh-hat-sen-mat-ong-vitapro-bich-420g.png",
    "bot-au-xanh-hat-sen-mat-ong-vitapro-bich-420g",
    1000,
    5,
    1,
    10,
    92
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt chia Sunrise gói 300g",
    108000,
    "images/products/hat-chia-sunrise-goi-300g.jpg",
    "hat-chia-sunrise-goi-300g",
    1000,
    5,
    1,
    10,
    92
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Yến mạch nguyên chất Yumfood hũ 800g",
    146000,
    "images/products/yen-mach-nguyen-chat-yumfood-hu-800g.png",
    "yen-mach-nguyen-chat-yumfood-hu-800g",
    1000,
    5,
    1,
    10,
    92
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Yến mạch nguyên chất Yumfood gói 400g",
    91000,
    "images/products/yen-mach-nguyen-chat-yumfood-goi-400g.png",
    "yen-mach-nguyen-chat-yumfood-goi-400g",
    1000,
    5,
    1,
    10,
    92
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ngũ cốc vị socola Nestlé Milo hộp 170g",
    70500,
    "images/products/ngu-coc-vi-socola-nestle-milo-hop-170g.png",
    "ngu-coc-vi-socola-nestle-milo-hop-170g",
    1000,
    5,
    1,
    10,
    92
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh chocopie Orion Dark ca cao 180g",
    34500/hộp,
    "images/products/banh-chocopie-orion-dark-ca-cao-180g.jpg",
    "banh-chocopie-orion-dark-ca-cao-180g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh chocopie Orion 198g",
    34500/hộp,
    "images/products/banh-chocopie-orion-198g.jpg",
    "banh-chocopie-orion-198g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bouchee Lotte Chocolat phô mai 162g",
    32500/hộp,
    "images/products/banh-bouchee-lotte-chocolat-pho-mai-162g.jpg",
    "banh-bouchee-lotte-chocolat-pho-mai-162g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bouchee Lotte Chocolat socola 324g",
    59000/hộp,
    "images/products/banh-bouchee-lotte-chocolat-socola-324g.jpg",
    "banh-bouchee-lotte-chocolat-socola-324g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh kiểu âu Orion Opéra socola 168g",
    34000/hộp,
    "None",
    "banh-kieu-au-orion-opera-socola-168g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bouchee Lotte Chocolat socola 162g",
    32500/hộp,
    "images/products/banh-bouchee-lotte-chocolat-socola-162g.jpg",
    "banh-bouchee-lotte-chocolat-socola-162g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh socola pie Lotte Chocolat 169.8g",
    32500/hộp,
    "images/products/banh-socola-pie-lotte-chocolat-1698g.jpg",
    "banh-socola-pie-lotte-chocolat-1698g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh Oreo Pie socola dâu 180g",
    40000/hộp,
    "images/products/banh-oreo-pie-socola-dau-180g.jpg",
    "banh-oreo-pie-socola-dau-180g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh chocopie Orion dưa hấu 336g",
    64500/hộp,
    "images/products/banh-chocopie-orion-dua-hau-336g.jpg",
    "banh-chocopie-orion-dua-hau-336g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh longpie socola Hải Hà 216g",
    28000/gói,
    "images/products/banh-longpie-socola-hai-ha-216g.jpg",
    "banh-longpie-socola-hai-ha-216g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh longpie Hải Hà hương cốm 216g",
    27500/gói,
    "images/products/banh-longpie-hai-ha-huong-com-216g.jpg",
    "banh-longpie-hai-ha-huong-com-216g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh Oreo Cadbury socola 180g",
    37500/hộp,
    "images/products/banh-oreo-cadbury-socola-180g.jpg",
    "banh-oreo-cadbury-socola-180g",
    1000,
    5,
    1,
    10,
    94
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh trứng tươi chà bông Karo Richy túi 156g",
    29000/túi,
    "images/products/banh-trung-tuoi-cha-bong-karo-richy-tui-156g.jpg",
    "banh-trung-tuoi-cha-bong-karo-richy-tui-156g",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bông lan tươi vị socola GOLD100 gói 100g",
    15000/gói,
    "images/products/banh-bong-lan-tuoi-vi-socola-gold100-goi-100g.jpg",
    "banh-bong-lan-tuoi-vi-socola-gold100-goi-100g",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bông lan tươi vị dâu GOLD100 gói 100g",
    15000/gói,
    "images/products/banh-bong-lan-tuoi-vi-dau-gold100-goi-100g.jpg",
    "banh-bong-lan-tuoi-vi-dau-gold100-goi-100g",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bông lan tươi vị phô mai GOLD100 gói 100g",
    15000/gói,
    "images/products/banh-bong-lan-tuoi-vi-pho-mai-gold100-goi-100g.jpg",
    "banh-bong-lan-tuoi-vi-pho-mai-gold100-goi-100g",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bông lan tươi vị lá lúa mạch GOLD100 gói 100g",
    15000/gói,
    "images/products/banh-bong-lan-tuoi-vi-la-lua-mach-gold100-goi-100g.jpg",
    "banh-bong-lan-tuoi-vi-la-lua-mach-gold100-goi-100g",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gói 5 cái bánh sợi thịt gà kem trứng lava C'est Bon",
    22000/gói,
    "images/products/goi-5-cai-banh-soi-thit-ga-kem-trung-lava-cest-bon.jpg",
    "goi-5-cai-banh-soi-thit-ga-kem-trung-lava-cest-bon",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gói 5 cái bánh bông lan sợi thịt gà Orion C'est Bon",
    22000/gói,
    "images/products/goi-5-cai-banh-bong-lan-soi-thit-ga-orion-cest-bon.jpg",
    "goi-5-cai-banh-bong-lan-soi-thit-ga-orion-cest-bon",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp 20 cái bánh bông lan kem bơ sữa Hura Layercake",
    41000/hộp,
    "images/products/hop-20-cai-banh-bong-lan-kem-bo-sua-hura-layercake.jpg",
    "hop-20-cai-banh-bong-lan-kem-bo-sua-hura-layercake",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gói 6 cái bánh ăn sáng xốt phô mai dừa Hura",
    34500/gói,
    "images/products/goi-6-cai-banh-an-sang-xot-pho-mai-dua-hura.jpg",
    "goi-6-cai-banh-an-sang-xot-pho-mai-dua-hura",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bông lan tươi vị sữa tươi Nue 33g",
    5000/gói,
    "images/products/banh-bong-lan-tuoi-vi-sua-tuoi-nue-33g.jpg",
    "banh-bong-lan-tuoi-vi-sua-tuoi-nue-33g",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh bông lan tươi vị phô mai Nue 33g",
    5000/gói,
    "images/products/banh-bong-lan-tuoi-vi-pho-mai-nue-33g.jpg",
    "banh-bong-lan-tuoi-vi-pho-mai-nue-33g",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 20 gói bánh sợi thịt gà kem trứng muối C'est Bon",
    435000/thùng,
    "images/products/thung-20-goi-banh-soi-thit-ga-kem-trung-muoi-cest-bon.jpg",
    "thung-20-goi-banh-soi-thit-ga-kem-trung-muoi-cest-bon",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 20 gói bánh sợi thịt gà sốt kem phô mai Orion C'est Bon",
    435000/thùng,
    "images/products/thung-20-goi-banh-soi-thit-ga-sot-kem-pho-mai-orion-cest-bon.jpg",
    "thung-20-goi-banh-soi-thit-ga-sot-kem-pho-mai-orion-cest-bon",
    1000,
    5,
    1,
    10,
    95
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mì hoa cúc Otto gói 300g",
    29000/gói,
    "images/products/banh-mi-hoa-cuc-otto-goi-300g.jpg",
    "banh-mi-hoa-cuc-otto-goi-300g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh Dorayaki nhân đậu đỏ Ichioka gói 69g",
    10000/gói,
    "images/products/banh-dorayaki-nhan-au-o-ichioka-goi-69g.jpg",
    "banh-dorayaki-nhan-au-o-ichioka-goi-69g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mochi vị đào trắng Umiki gói 180g",
    19000/gói,
    "images/products/banh-mochi-vi-ao-trang-umiki-goi-180g.jpg",
    "banh-mochi-vi-ao-trang-umiki-goi-180g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mochi vị khoai môn Umiki 180g",
    19000/gói,
    "images/products/banh-mochi-vi-khoai-mon-umiki-180g.jpg",
    "banh-mochi-vi-khoai-mon-umiki-180g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh pía đậu xanh sầu riêng Phúc An gói 300g",
    52000/gói,
    "images/products/banh-pia-au-xanh-sau-rieng-phuc-an-goi-300g.jpg",
    "banh-pia-au-xanh-sau-rieng-phuc-an-goi-300g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mì gà nướng xốt Hồng Kông Kido's Bakery gói 55g",
    15000/gói,
    "images/products/banh-mi-ga-nuong-xot-hong-kong-kidos-bakery-goi-55g.jpg",
    "banh-mi-ga-nuong-xot-hong-kong-kidos-bakery-goi-55g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mì nướng vị bơ tỏi C'est Bon Orion gói 108g",
    21000/gói,
    "images/products/banh-mi-nuong-vi-bo-toi-cest-bon-orion-goi-108g.jpg",
    "banh-mi-nuong-vi-bo-toi-cest-bon-orion-goi-108g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mì sandwich khoai tây Fresta Richy 275g",
    20000/gói,
    "images/products/banh-mi-sandwich-khoai-tay-fresta-richy-275g.jpg",
    "banh-mi-sandwich-khoai-tay-fresta-richy-275g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mì tươi socola Otto 90g",
    8000/gói,
    "images/products/banh-mi-tuoi-socola-otto-90g.jpg",
    "banh-mi-tuoi-socola-otto-90g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mì chà bông Staff 55g",
    8400/gói,
    "images/products/banh-mi-cha-bong-staff-55g.jpg",
    "banh-mi-cha-bong-staff-55g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mì Hữu Nghị Staff 90g",
    8000/gói,
    "images/products/banh-mi-huu-nghi-staff-90g.jpg",
    "banh-mi-huu-nghi-staff-90g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo 4 gói bánh bông lan tam giác",
    60000/4 gói,
    "images/products/combo-4-goi-banh-bong-lan-tam-giac.jpg",
    "combo-4-goi-banh-bong-lan-tam-giac",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mì tươi khoai môn 24+ Phúc An 33g",
    5000/gói,
    "images/products/banh-mi-tuoi-khoai-mon-24-phuc-an-33g.jpg",
    "banh-mi-tuoi-khoai-mon-24-phuc-an-33g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh mì tươi socola 24+ Phúc An 33g",
    5000/gói,
    "images/products/banh-mi-tuoi-socola-24-phuc-an-33g.jpg",
    "banh-mi-tuoi-socola-24-phuc-an-33g",
    1000,
    5,
    1,
    10,
    96
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo socola M&M's siêu giòn gói 30g",
    19500/gói,
    "images/products/keo-socola-mms-sieu-gion-goi-30g.jpg",
    "keo-socola-mms-sieu-gion-goi-30g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo socola nhân đậu phộng M&M's gói 40g",
    19000/gói,
    "images/products/keo-socola-nhan-au-phong-mms-goi-40g.jpg",
    "keo-socola-nhan-au-phong-mms-goi-40g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo socola sữa M&M's gói 40g",
    19000/gói,
    "images/products/keo-socola-sua-mms-goi-40g.jpg",
    "keo-socola-sua-mms-goi-40g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo trứng socola Wolfoo quả 20g",
    20000/trứng,
    "images/products/keo-trung-socola-wolfoo-qua-20g.jpg",
    "keo-trung-socola-wolfoo-qua-20g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo trứng socola sữa Play More 20g",
    27000/trứng,
    "images/products/keo-trung-socola-sua-play-more-20g.jpg",
    "keo-trung-socola-sua-play-more-20g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh xốp KitKat phủ socola 2 thanh",
    8400/thanh,
    "images/products/banh-xop-kitkat-phu-socola-2-thanh.jpg",
    "banh-xop-kitkat-phu-socola-2-thanh",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh xốp phủ socola KitKat 35g",
    16800/gói,
    "images/products/banh-xop-phu-socola-kitkat-35g.jpg",
    "banh-xop-phu-socola-kitkat-35g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo socola Snickers thanh 51g",
    22000/thanh,
    "images/products/keo-socola-snickers-thanh-51g.jpg",
    "keo-socola-snickers-thanh-51g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh xốp phủ trà xanh KitKat gói 35g",
    27500/gói,
    "images/products/banh-xop-phu-tra-xanh-kitkat-goi-35g.jpg",
    "banh-xop-phu-tra-xanh-kitkat-goi-35g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo socola đen hạnh nhân Snickers 40g",
    26000/gói,
    "images/products/keo-socola-en-hanh-nhan-snickers-40g.jpg",
    "keo-socola-en-hanh-nhan-snickers-40g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo socola Đức Hạnh Chobisca",
    189000/kg,
    "images/products/keo-socola-uc-hanh-chobisca.jpg",
    "keo-socola-uc-hanh-chobisca",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo socola sữa Lacasitos bút chì màu 20g",
    41000/ống,
    "images/products/keo-socola-sua-lacasitos-but-chi-mau-20g.jpg",
    "keo-socola-sua-lacasitos-but-chi-mau-20g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Socola sữa M&M's ống 28g",
    36500/ống,
    "images/products/socola-sua-mms-ong-28g.jpg",
    "socola-sua-mms-ong-28g",
    1000,
    5,
    1,
    10,
    97
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum Hubba Bubba truyền thống 56g",
    37500/hộp,
    "images/products/keo-gum-hubba-bubba-truyen-thong-56g.jpg",
    "keo-gum-hubba-bubba-truyen-thong-56g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum Hubba Bubba dâu tây 56g",
    37500/hộp,
    "images/products/keo-gum-hubba-bubba-dau-tay-56g.jpg",
    "keo-gum-hubba-bubba-dau-tay-56g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum Hubba Bubba nho 56g",
    37500/hộp,
    "images/products/keo-gum-hubba-bubba-nho-56g.jpg",
    "keo-gum-hubba-bubba-nho-56g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum Hubba Bubba mâm xôi 56.7g",
    37500/hộp,
    "images/products/keo-gum-hubba-bubba-mam-xoi-567g.jpg",
    "keo-gum-hubba-bubba-mam-xoi-567g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum Cool Air Fresh Cube chanh 40g",
    32000/hũ,
    "images/products/keo-gum-cool-air-fresh-cube-chanh-40g.jpg",
    "keo-gum-cool-air-fresh-cube-chanh-40g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum Cool Air Fresh Cube bạc hà 40g",
    32000/hũ,
    "images/products/keo-gum-cool-air-fresh-cube-bac-ha-40g.jpg",
    "keo-gum-cool-air-fresh-cube-bac-ha-40g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum Cool Air bạc hà 146g",
    48000/hũ,
    "images/products/keo-gum-cool-air-bac-ha-146g.jpg",
    "keo-gum-cool-air-bac-ha-146g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum không đường Mentos dưa hấu 61.25g",
    24400/hũ,
    "images/products/keo-gum-khong-uong-mentos-dua-hau-6125g.jpg",
    "keo-gum-khong-uong-mentos-dua-hau-6125g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo ngậm không đường Mentos đào bạc hà 35g",
    38000/hộp,
    "images/products/keo-ngam-khong-uong-mentos-ao-bac-ha-35g.jpg",
    "keo-ngam-khong-uong-mentos-ao-bac-ha-35g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum cuộn Lotte Doraemon cam 56g",
    36000/hộp,
    "images/products/keo-gum-cuon-lotte-doraemon-cam-56g.jpg",
    "keo-gum-cuon-lotte-doraemon-cam-56g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum cuộn Lotte Doraemon dâu 56g",
    36000/hộp,
    "images/products/keo-gum-cuon-lotte-doraemon-dau-56g.jpg",
    "keo-gum-cuon-lotte-doraemon-dau-56g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum thổi Chupa Chups tô màu 27g",
    9680/hũ,
    "images/products/keo-gum-thoi-chupa-chups-to-mau-27g.jpg",
    "keo-gum-thoi-chupa-chups-to-mau-27g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum Lotte Pokemon dâu 3g",
    31000/hộp,
    "images/products/keo-gum-lotte-pokemon-dau-3g.jpg",
    "keo-gum-lotte-pokemon-dau-3g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo gum Lotte Xylitol Lime Mint 159.5g",
    57500/gói,
    "images/products/keo-gum-lotte-xylitol-lime-mint-1595g.jpg",
    "keo-gum-lotte-xylitol-lime-mint-1595g",
    1000,
    5,
    1,
    10,
    100
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt điều phô mai Vinahe gói 100g",
    35000/gói,
    "images/products/hat-ieu-pho-mai-vinahe-goi-100g.jpg",
    "hat-ieu-pho-mai-vinahe-goi-100g",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt điều vị tỏi ớt Vinahe gói 100g",
    35000/gói,
    "images/products/hat-ieu-vi-toi-ot-vinahe-goi-100g.jpg",
    "hat-ieu-vi-toi-ot-vinahe-goi-100g",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt điều vỏ lụa rang muối Vinahe gói 100g",
    35000/gói,
    "images/products/hat-ieu-vo-lua-rang-muoi-vinahe-goi-100g.jpg",
    "hat-ieu-vo-lua-rang-muoi-vinahe-goi-100g",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt điều bóc vỏ Bà Tư Bình Phước hộp 160g",
    69000/hộp,
    "images/products/hat-ieu-boc-vo-ba-tu-binh-phuoc-hop-160g.jpg",
    "hat-ieu-boc-vo-ba-tu-binh-phuoc-hop-160g",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt điều vỏ lụa Bà Tư Bình Phước hộp 160g",
    59000/hộp,
    "images/products/hat-ieu-vo-lua-ba-tu-binh-phuoc-hop-160g.jpg",
    "hat-ieu-vo-lua-ba-tu-binh-phuoc-hop-160g",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt hướng dương Yến Nhung gói 50g",
    10000/gói,
    "images/products/hat-huong-duong-yen-nhung-goi-50g.jpg",
    "hat-huong-duong-yen-nhung-goi-50g",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt đậu mix hoa quả tổng hợp Cam Nguyên",
    63000/300g,
    "images/products/hat-au-mix-hoa-qua-tong-hop-cam-nguyen.jpg",
    "hat-au-mix-hoa-qua-tong-hop-cam-nguyen",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu phộng vị mực cay Poca 80g",
    12000/gói,
    "images/products/au-phong-vi-muc-cay-poca-80g.jpg",
    "au-phong-vi-muc-cay-poca-80g",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hạt dẻ cười Yến Nhung gói 50g",
    45000/gói,
    "images/products/hat-de-cuoi-yen-nhung-goi-50g.jpg",
    "hat-de-cuoi-yen-nhung-goi-50g",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu Hà Lan vị bò nướng kay Jojo gói 70g",
    14000/gói,
    "images/products/au-ha-lan-vi-bo-nuong-kay-jojo-goi-70g.jpg",
    "au-ha-lan-vi-bo-nuong-kay-jojo-goi-70g",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Đậu Hà Lan vị wasabi Jojo gói 70g",
    14000/gói,
    "images/products/au-ha-lan-vi-wasabi-jojo-goi-70g.jpg",
    "au-ha-lan-vi-wasabi-jojo-goi-70g",
    1000,
    5,
    1,
    10,
    102
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thạch dừa Ánh Hồng lốc 6 ly 190g",
    33500/lốc,
    "images/products/thach-dua-anh-hong-loc-6-ly-190g.jpg",
    "thach-dua-anh-hong-loc-6-ly-190g",
    1000,
    5,
    1,
    10,
    103
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo thạch Zai Zai Đức Hạnh thanh vuông",
    15000/Túi 200g,
    "images/products/keo-thach-zai-zai-uc-hanh-thanh-vuong.jpg",
    "keo-thach-zai-zai-uc-hanh-thanh-vuong",
    1000,
    5,
    1,
    10,
    103
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo thạch Zai Zai Đức Hạnh thanh dài",
    15000/200g,
    "images/products/keo-thach-zai-zai-uc-hanh-thanh-dai.jpg",
    "keo-thach-zai-zai-uc-hanh-thanh-dai",
    1000,
    5,
    1,
    10,
    103
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo thạch Zai Zai Plus trà sữa trân châu Đức Hạnh gói 320g",
    30500/gói,
    "images/products/keo-thach-zai-zai-plus-tra-sua-tran-chau-uc-hanh-goi-320g.jpg",
    "keo-thach-zai-zai-plus-tra-sua-tran-chau-uc-hanh-goi-320g",
    1000,
    5,
    1,
    10,
    103
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo thạch Zai Zai gói 320g (dạng thanh dài)",
    30500/gói,
    "images/products/keo-thach-zai-zai-goi-320g-dang-thanh-dai.jpg",
    "keo-thach-zai-zai-goi-320g-dang-thanh-dai",
    1000,
    5,
    1,
    10,
    103
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo thạch Zai Zai gói 160g (dạng gói vuông)",
    18000/gói,
    "images/products/keo-thach-zai-zai-goi-160g-dang-goi-vuong.jpg",
    "keo-thach-zai-zai-goi-160g-dang-goi-vuong",
    1000,
    5,
    1,
    10,
    103
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kẹo thạch Zai Zai gói 210g (dạng thanh dài)",
    21500/gói,
    "images/products/keo-thach-zai-zai-goi-210g-dang-thanh-dai.jpg",
    "keo-thach-zai-zai-goi-210g-dang-thanh-dai",
    1000,
    5,
    1,
    10,
    103
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chà bông gà C&B hũ 100g",
    39000/hũ,
    "images/products/cha-bong-ga-cb-hu-100g.jpg",
    "cha-bong-ga-cb-hu-100g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Mực rim me Đầm Sen hũ 150g",
    69000/hũ,
    "images/products/muc-rim-me-am-sen-hu-150g.jpg",
    "muc-rim-me-am-sen-hu-150g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Ruốc cá hồi nhập khẩu Nguyễn Hoàng hũ 80g",
    79500/hũ,
    "images/products/ruoc-ca-hoi-nhap-khau-nguyen-hoang-hu-80g.jpg",
    "ruoc-ca-hoi-nhap-khau-nguyen-hoang-hu-80g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chà bông heo C&B hũ 100g",
    51000/hũ,
    "images/products/cha-bong-heo-cb-hu-100g.jpg",
    "cha-bong-heo-cb-hu-100g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chà bông heo C&B hũ 150g",
    75000/hũ,
    "images/products/cha-bong-heo-cb-hu-150g.jpg",
    "cha-bong-heo-cb-hu-150g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khô gà cay lá chanh Posi gói 50g",
    24000/gói,
    "images/products/kho-ga-cay-la-chanh-posi-goi-50g.jpg",
    "kho-ga-cay-la-chanh-posi-goi-50g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khô mực xé sợi vị cay Posi gói 50g",
    34000/gói,
    "images/products/kho-muc-xe-soi-vi-cay-posi-goi-50g.jpg",
    "kho-muc-xe-soi-vi-cay-posi-goi-50g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thịt bò khô Posi gói 45g",
    38000/gói,
    "images/products/thit-bo-kho-posi-goi-45g.jpg",
    "thit-bo-kho-posi-goi-45g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khô heo vị cháy tỏi Posi gói 50g",
    30000/gói,
    "images/products/kho-heo-vi-chay-toi-posi-goi-50g.jpg",
    "kho-heo-vi-chay-toi-posi-goi-50g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân gà Cung Đình Hey Yo gói 32g",
    11000/gói,
    "images/products/chan-ga-cung-inh-hey-yo-goi-32g.jpg",
    "chan-ga-cung-inh-hey-yo-goi-32g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân gà bách thảo Hey Yo gói 45g",
    11000/gói,
    "images/products/chan-ga-bach-thao-hey-yo-goi-45g.jpg",
    "chan-ga-bach-thao-hey-yo-goi-45g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chà bông cá hồi tươi SG Food gói 35g",
    30500/gói,
    "images/products/cha-bong-ca-hoi-tuoi-sg-food-goi-35g.jpg",
    "cha-bong-ca-hoi-tuoi-sg-food-goi-35g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chân gà vị mật ong Chef Biggy gói 30g",
    11600/gói,
    "images/products/chan-ga-vi-mat-ong-chef-biggy-goi-30g.jpg",
    "chan-ga-vi-mat-ong-chef-biggy-goi-30g",
    1000,
    5,
    1,
    10,
    104
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Da heo mắm hành Kodochi gói 100g",
    44000/gói,
    "images/products/da-heo-mam-hanh-kodochi-goi-100g.jpg",
    "da-heo-mam-hanh-kodochi-goi-100g",
    1000,
    5,
    1,
    10,
    105
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tóp mỡ cháy tỏi Kodochi gói 100g",
    44000/gói,
    "images/products/top-mo-chay-toi-kodochi-goi-100g.jpg",
    "top-mo-chay-toi-kodochi-goi-100g",
    1000,
    5,
    1,
    10,
    105
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Da heo quay đặc biệt Kodochi gói 100g",
    44000/gói,
    "images/products/da-heo-quay-ac-biet-kodochi-goi-100g.jpg",
    "da-heo-quay-ac-biet-kodochi-goi-100g",
    1000,
    5,
    1,
    10,
    105
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng rong biển Kodochi gói 50g",
    15000/gói,
    "images/products/banh-trang-rong-bien-kodochi-goi-50g.jpg",
    "banh-trang-rong-bien-kodochi-goi-50g",
    1000,
    5,
    1,
    10,
    105
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng thập cẩm Kodochi gói 50g",
    15000/gói,
    "images/products/banh-trang-thap-cam-kodochi-goi-50g.jpg",
    "banh-trang-thap-cam-kodochi-goi-50g",
    1000,
    5,
    1,
    10,
    105
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh tráng xike Kodochi gói 50g",
    15000/gói,
    "images/products/banh-trang-xike-kodochi-goi-50g.jpg",
    "banh-trang-xike-kodochi-goi-50g",
    1000,
    5,
    1,
    10,
    105
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói thanh gạo lứt hạt óc chó rong biển FnV",
    960000/thùng,
    "images/products/thung-24-goi-thanh-gao-lut-hat-oc-cho-rong-bien-fnv.jpg",
    "thung-24-goi-thanh-gao-lut-hat-oc-cho-rong-bien-fnv",
    1000,
    5,
    1,
    10,
    105
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói thanh gạo lứt hạnh nhân chà bông FnV",
    960000/thùng,
    "images/products/thung-24-goi-thanh-gao-lut-hanh-nhan-cha-bong-fnv.jpg",
    "thung-24-goi-thanh-gao-lut-hanh-nhan-cha-bong-fnv",
    1000,
    5,
    1,
    10,
    105
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh thuyền hạt dinh dưỡng Oh Smile Nuts gói 100g",
    39000/gói,
    "images/products/banh-thuyen-hat-dinh-duong-oh-smile-nuts-goi-100g.jpg",
    "banh-thuyen-hat-dinh-duong-oh-smile-nuts-goi-100g",
    1000,
    5,
    1,
    10,
    105
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bánh rong biển kẹp hạt Oh Smile Nuts gói 100g",
    39000/gói,
    "images/products/banh-rong-bien-kep-hat-oh-smile-nuts-goi-100g.jpg",
    "banh-rong-bien-kep-hat-oh-smile-nuts-goi-100g",
    1000,
    5,
    1,
    10,
    105
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tẩy trang Hazeline tràm trà Cica 375ml",
    106000,
    "images/products/nuoc-tay-trang-hazeline-tram-tra-cica-375ml.jpg",
    "nuoc-tay-trang-hazeline-tram-tra-cica-375ml",
    1000,
    5,
    1,
    11,
    108
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tẩy trang Simple làm sạch lớp trang điểm 400ml",
    159000,
    "images/products/nuoc-tay-trang-simple-lam-sach-lop-trang-iem-400ml.jpg",
    "nuoc-tay-trang-simple-lam-sach-lop-trang-iem-400ml",
    1000,
    5,
    1,
    11,
    108
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bông tẩy trang tròn 3D Calla 200 miếng",
    39000,
    "images/products/bong-tay-trang-tron-3d-calla-200-mieng.jpg",
    "bong-tay-trang-tron-3d-calla-200-mieng",
    1000,
    5,
    1,
    11,
    108
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 3 gói bông tẩy trang PoP-Puf 2 công dụng 90 miếng",
    52500,
    "images/products/loc-3-goi-bong-tay-trang-pop-puf-2-cong-dung-90-mieng.jpg",
    "loc-3-goi-bong-tay-trang-pop-puf-2-cong-dung-90-mieng",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bông tẩy trang vuông Kokimi 240 miếng",
    57000,
    "images/products/bong-tay-trang-vuong-kokimi-240-mieng.jpg",
    "bong-tay-trang-vuong-kokimi-240-mieng",
    1000,
    5,
    1,
    11,
    108
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bông tẩy trang tròn Mihoo 200 miếng",
    59000,
    "images/products/bong-tay-trang-tron-mihoo-200-mieng.jpg",
    "bong-tay-trang-tron-mihoo-200-mieng",
    1000,
    5,
    1,
    11,
    108
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bông tẩy trang tròn Mihoo 150 miếng",
    49500,
    "images/products/bong-tay-trang-tron-mihoo-150-mieng.jpg",
    "bong-tay-trang-tron-mihoo-150-mieng",
    1000,
    5,
    1,
    11,
    108
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bông tẩy trang tròn Puri 130 miếng",
    36000,
    "images/products/bong-tay-trang-tron-puri-130-mieng.jpg",
    "bong-tay-trang-tron-puri-130-mieng",
    1000,
    5,
    1,
    11,
    108
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bông tẩy trang Puri 150 miếng",
    36000,
    "images/products/bong-tay-trang-puri-150-mieng.jpg",
    "bong-tay-trang-puri-150-mieng",
    1000,
    5,
    1,
    11,
    108
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tẩy trang Senka kiểm soát nhờn 230ml",
    125000,
    "images/products/nuoc-tay-trang-senka-kiem-soat-nhon-230ml.jpg",
    "nuoc-tay-trang-senka-kiem-soat-nhon-230ml",
    1000,
    5,
    1,
    11,
    108
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Clear 9 thảo dược cổ truyền 330ml",
    85000,
    "images/products/dau-goi-clear-9-thao-duoc-co-truyen-330ml.jpg",
    "dau-goi-clear-9-thao-duoc-co-truyen-330ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Clear Men Cool Sport bạc hà sạch gàu 330ml",
    92000,
    "images/products/dau-goi-clear-men-cool-sport-bac-ha-sach-gau-330ml.jpg",
    "dau-goi-clear-men-cool-sport-bac-ha-sach-gau-330ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội sạch gàu Clear mát lạnh bạc hà 330ml",
    85000,
    "images/products/dau-goi-sach-gau-clear-mat-lanh-bac-ha-330ml.jpg",
    "dau-goi-sach-gau-clear-mat-lanh-bac-ha-330ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Tsubaki sạch dầu mát lạnh 490ml",
    151000,
    "images/products/dau-goi-tsubaki-sach-dau-mat-lanh-490ml.jpg",
    "dau-goi-tsubaki-sach-dau-mat-lanh-490ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Tsubaki dưỡng tóc bóng mượt 490ml",
    151000,
    "images/products/dau-goi-tsubaki-duong-toc-bong-muot-490ml.jpg",
    "dau-goi-tsubaki-duong-toc-bong-muot-490ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Tsubaki phục hồi hư tổn 490ml",
    151000,
    "images/products/dau-goi-tsubaki-phuc-hoi-hu-ton-490ml.jpg",
    "dau-goi-tsubaki-phuc-hoi-hu-ton-490ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Clear Men bạc hà mát lạnh 612ml",
    225000,
    "images/products/dau-goi-clear-men-bac-ha-mat-lanh-612ml.jpg",
    "dau-goi-clear-men-bac-ha-mat-lanh-612ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội sạch gàu Clear mát lạnh bạc hà 854ml",
    211000,
    "images/products/dau-goi-sach-gau-clear-mat-lanh-bac-ha-854ml.jpg",
    "dau-goi-sach-gau-clear-mat-lanh-bac-ha-854ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội dược liệu Thái Dương 3 hương hoa đào 500ml",
    134000,
    "images/products/dau-goi-duoc-lieu-thai-duong-3-huong-hoa-ao-500ml.jpg",
    "dau-goi-duoc-lieu-thai-duong-3-huong-hoa-ao-500ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Sunsilk óng mượt rạng ngời 631ml",
    160000,
    "images/products/dau-goi-sunsilk-ong-muot-rang-ngoi-631ml.jpg",
    "dau-goi-sunsilk-ong-muot-rang-ngoi-631ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Head & Shoulders bạc hà sạch gàu 850ml",
    191000,
    "images/products/dau-goi-head--shoulders-bac-ha-sach-gau-850ml.jpg",
    "dau-goi-head--shoulders-bac-ha-sach-gau-850ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Sunsilk óng mượt rạng ngời 874ml",
    169000,
    "images/products/dau-goi-sunsilk-ong-muot-rang-ngoi-874ml.jpg",
    "dau-goi-sunsilk-ong-muot-rang-ngoi-874ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội xả Palmolive dưỡng ẩm 600ml",
    98500,
    "images/products/dau-goi-xa-palmolive-duong-am-600ml.jpg",
    "dau-goi-xa-palmolive-duong-am-600ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Selsun giảm gàu 100ml",
    101000,
    "images/products/dau-goi-selsun-giam-gau-100ml.jpg",
    "dau-goi-selsun-giam-gau-100ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu gội Lifebuoy tóc dày óng ả 621ml",
    114000,
    "images/products/dau-goi-lifebuoy-toc-day-ong-a-621ml.jpg",
    "dau-goi-lifebuoy-toc-day-ong-a-621ml",
    1000,
    5,
    1,
    11,
    109
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu xả Sunsilk Natural phục hồi tóc hư tổn 330ml",
    85000,
    "images/products/dau-xa-sunsilk-natural-phuc-hoi-toc-hu-ton-330ml.jpg",
    "dau-xa-sunsilk-natural-phuc-hoi-toc-hu-ton-330ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem xả Dove phục hồi hư tổn 622ml",
    146000,
    "images/products/kem-xa-dove-phuc-hoi-hu-ton-622ml.jpg",
    "kem-xa-dove-phuc-hoi-hu-ton-622ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu xả Sunsilk Natural ngăn gãy rụng tóc 330ml",
    85000,
    "images/products/dau-xa-sunsilk-natural-ngan-gay-rung-toc-330ml.jpg",
    "dau-xa-sunsilk-natural-ngan-gay-rung-toc-330ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu xả Tsubaki sạch dầu mát lạnh 490ml",
    151000,
    "images/products/dau-xa-tsubaki-sach-dau-mat-lanh-490ml.jpg",
    "dau-xa-tsubaki-sach-dau-mat-lanh-490ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu xả Tsubaki dưỡng tóc bóng mượt 490ml",
    151000,
    "images/products/dau-xa-tsubaki-duong-toc-bong-muot-490ml.jpg",
    "dau-xa-tsubaki-duong-toc-bong-muot-490ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu xả Tresemmé Keratin Smooth vào nếp suôn mượt 642ml",
    184500,
    "images/products/dau-xa-tresemme-keratin-smooth-vao-nep-suon-muot-642ml.jpg",
    "dau-xa-tresemme-keratin-smooth-vao-nep-suon-muot-642ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu xả Sunsilk óng mượt rạng ngời 653ml",
    153000,
    "images/products/dau-xa-sunsilk-ong-muot-rang-ngoi-653ml.jpg",
    "dau-xa-sunsilk-ong-muot-rang-ngoi-653ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu xả Sunsilk mềm mượt diệu kỳ 653ml",
    157000,
    "images/products/dau-xa-sunsilk-mem-muot-dieu-ky-653ml.jpg",
    "dau-xa-sunsilk-mem-muot-dieu-ky-653ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu xả Pantene ngăn rụng tóc 300ml",
    129000,
    "images/products/dau-xa-pantene-ngan-rung-toc-300ml.jpg",
    "dau-xa-pantene-ngan-rung-toc-300ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem xả Dove ngăn tóc gãy rụng 327ml",
    114000,
    "images/products/kem-xa-dove-ngan-toc-gay-rung-327ml.jpg",
    "kem-xa-dove-ngan-toc-gay-rung-327ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu xả Rejoice siêu mềm mượt chai 320ml",
    90000,
    "images/products/dau-xa-rejoice-sieu-mem-muot-chai-320ml.jpg",
    "dau-xa-rejoice-sieu-mem-muot-chai-320ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem xả Pantene phục hồi hư tổn 150ml",
    66500,
    "images/products/kem-xa-pantene-phuc-hoi-hu-ton-150ml.jpg",
    "kem-xa-pantene-phuc-hoi-hu-ton-150ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dầu xả TRESemmé Salon Rebond giảm gãy rụng 490ml",
    136000,
    "images/products/dau-xa-tresemme-salon-rebond-giam-gay-rung-490ml.jpg",
    "dau-xa-tresemme-salon-rebond-giam-gay-rung-490ml",
    1000,
    5,
    1,
    11,
    110
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm Hazeline yến mạch dâu tằm 796ml",
    87500,
    "images/products/sua-tam-hazeline-yen-mach-dau-tam-796ml.jpg",
    "sua-tam-hazeline-yen-mach-dau-tam-796ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm nước hoa Lux phong lan 562ml",
    124000,
    "images/products/sua-tam-nuoc-hoa-lux-phong-lan-562ml.jpg",
    "sua-tam-nuoc-hoa-lux-phong-lan-562ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm nâng tông Hazeline sữa chua hoa linh lan 667ml",
    120000,
    "images/products/sua-tam-nang-tong-hazeline-sua-chua-hoa-linh-lan-667ml.jpg",
    "sua-tam-nang-tong-hazeline-sua-chua-hoa-linh-lan-667ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm Purité hương hoa anh đào 850ml",
    166000,
    "images/products/sua-tam-purite-huong-hoa-anh-ao-850ml.jpg",
    "sua-tam-purite-huong-hoa-anh-ao-850ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm mềm mịn Purité hoa hồng 850ml",
    166000,
    "images/products/sua-tam-mem-min-purite-hoa-hong-850ml.jpg",
    "sua-tam-mem-min-purite-hoa-hong-850ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm trắng da Gervenne hương việt quất & lan Nam Phi 900g",
    79000,
    "images/products/sua-tam-trang-da-gervenne-huong-viet-quat--lan-nam-phi-900g.jpg",
    "sua-tam-trang-da-gervenne-huong-viet-quat--lan-nam-phi-900g",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm nâng tông Hazeline sữa chua hương đào 667ml",
    120000,
    "images/products/sua-tam-nang-tong-hazeline-sua-chua-huong-ao-667ml.jpg",
    "sua-tam-nang-tong-hazeline-sua-chua-huong-ao-667ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm Lifebuoy than hoạt tính & cám gạo 784ml",
    168000,
    "images/products/sua-tam-lifebuoy-than-hoat-tinh--cam-gao-784ml.jpg",
    "sua-tam-lifebuoy-than-hoat-tinh--cam-gao-784ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm Hazeline matcha lựu đỏ 796ml",
    87500,
    "images/products/sua-tam-hazeline-matcha-luu-o-796ml.jpg",
    "sua-tam-hazeline-matcha-luu-o-796ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm Lifebuoy matcha & khổ qua 784ml",
    162000,
    "images/products/sua-tam-lifebuoy-matcha--kho-qua-784ml.jpg",
    "sua-tam-lifebuoy-matcha--kho-qua-784ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm Lifebuoy bảo vệ vượt trội 784ml",
    164000,
    "images/products/sua-tam-lifebuoy-bao-ve-vuot-troi-784ml.jpg",
    "sua-tam-lifebuoy-bao-ve-vuot-troi-784ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm nước hoa dưỡng da Enchanteur Deluxe Charming 650g",
    165000,
    "images/products/sua-tam-nuoc-hoa-duong-da-enchanteur-deluxe-charming-650g.jpg",
    "sua-tam-nuoc-hoa-duong-da-enchanteur-deluxe-charming-650g",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa tắm Lifebuoy thảo dược & hoa sen 784ml",
    162000,
    "images/products/sua-tam-lifebuoy-thao-duoc--hoa-sen-784ml.jpg",
    "sua-tam-lifebuoy-thao-duoc--hoa-sen-784ml",
    1000,
    5,
    1,
    11,
    111
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng P/S trắng răng than hoạt tính 230g",
    35000,
    "images/products/kem-anh-rang-ps-trang-rang-than-hoat-tinh-230g.jpg",
    "kem-anh-rang-ps-trang-rang-than-hoat-tinh-230g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng P/S muối hồng và hoa cúc 230g",
    35000,
    "images/products/kem-anh-rang-ps-muoi-hong-va-hoa-cuc-230g.jpg",
    "kem-anh-rang-ps-muoi-hong-va-hoa-cuc-230g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bộ kem đánh răng và bàn chải Colgate muối than hoạt tính 150g",
    27500,
    "images/products/bo-kem-anh-rang-va-ban-chai-colgate-muoi-than-hoat-tinh-150g.jpg",
    "bo-kem-anh-rang-va-ban-chai-colgate-muoi-than-hoat-tinh-150g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bộ đôi kem đánh răng Colgate MaxFresh 225g",
    60000,
    "images/products/bo-oi-kem-anh-rang-colgate-maxfresh-225g.jpg",
    "bo-oi-kem-anh-rang-colgate-maxfresh-225g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng Colgate ngừa sâu răng 225g",
    29000,
    "images/products/kem-anh-rang-colgate-ngua-sau-rang-225g.jpg",
    "kem-anh-rang-colgate-ngua-sau-rang-225g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng Colgate Total Active Fresh 150g",
    42500,
    "images/products/kem-anh-rang-colgate-total-active-fresh-150g.png",
    "kem-anh-rang-colgate-total-active-fresh-150g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bộ bàn chải đánh răng và kem đánh răng Colgate MaxFresh than tre 225g",
    43000,
    "images/products/bo-ban-chai-anh-rang-va-kem-anh-rang-colgate-maxfresh-than-tre-225g.jpg",
    "bo-ban-chai-anh-rang-va-kem-anh-rang-colgate-maxfresh-than-tre-225g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng Closeup White Now trắng tự nhiên 100g",
    62000,
    "images/products/kem-anh-rang-closeup-white-now-trang-tu-nhien-100g.jpg",
    "kem-anh-rang-closeup-white-now-trang-tu-nhien-100g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng Sensodyne trắng răng 100g",
    78000,
    "images/products/kem-anh-rang-sensodyne-trang-rang-100g.jpg",
    "kem-anh-rang-sensodyne-trang-rang-100g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng Closeup White Now tinh thể Blue Sapphire 100g",
    62000,
    "images/products/kem-anh-rang-closeup-white-now-tinh-the-blue-sapphire-100g.jpg",
    "kem-anh-rang-closeup-white-now-tinh-the-blue-sapphire-100g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng Closeup hương bạc hà 230g",
    36500,
    "images/products/kem-anh-rang-closeup-huong-bac-ha-230g.jpg",
    "kem-anh-rang-closeup-huong-bac-ha-230g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng Colgate MaxFresh bạc hà 225g",
    41000,
    "images/products/kem-anh-rang-colgate-maxfresh-bac-ha-225g.jpg",
    "kem-anh-rang-colgate-maxfresh-bac-ha-225g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng P/S ngừa sâu răng 230g",
    36000,
    "images/products/kem-anh-rang-ps-ngua-sau-rang-230g.jpg",
    "kem-anh-rang-ps-ngua-sau-rang-230g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem đánh răng Closeup tinh thể băng tuyết 230g",
    36500,
    "images/products/kem-anh-rang-closeup-tinh-the-bang-tuyet-230g.jpg",
    "kem-anh-rang-closeup-tinh-the-bang-tuyet-230g",
    1000,
    5,
    1,
    11,
    112
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 bàn chải P/S lông tơ siêu mảnh",
    58500,
    "images/products/3-ban-chai-ps-long-to-sieu-manh.jpg",
    "3-ban-chai-ps-long-to-sieu-manh",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 bàn chải P/S than bạc kháng khuẩn 99.9% lông tơ siêu mảnh",
    43000,
    "images/products/2-ban-chai-ps-than-bac-khang-khuan-999-long-to-sieu-manh.jpg",
    "2-ban-chai-ps-than-bac-khang-khuan-999-long-to-sieu-manh",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bộ bàn chải và tăm chỉ Oral-Clean Optima",
    24500,
    "images/products/bo-ban-chai-va-tam-chi-oral-clean-optima.jpg",
    "bo-ban-chai-va-tam-chi-oral-clean-optima",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 bàn chải Colgate 360 Charcoal Spiral",
    55000,
    "images/products/2-ban-chai-colgate-360-charcoal-spiral.jpg",
    "2-ban-chai-colgate-360-charcoal-spiral",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 bàn chải đánh răng Colgate Cushion Clean",
    75000,
    "images/products/2-ban-chai-anh-rang-colgate-cushion-clean.jpg",
    "2-ban-chai-anh-rang-colgate-cushion-clean",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 bàn chải Colgate Cushion Clean",
    75000,
    "images/products/2-ban-chai-colgate-cushion-clean.jpg",
    "2-ban-chai-colgate-cushion-clean",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bộ 2 bàn chải đánh răng P/S 4D sạch sâu",
    66000,
    "images/products/bo-2-ban-chai-anh-rang-ps-4d-sach-sau.jpg",
    "bo-2-ban-chai-anh-rang-ps-4d-sach-sau",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bàn chải P/S lông tơ mềm mảnh",
    19500,
    "images/products/ban-chai-ps-long-to-mem-manh.jpg",
    "ban-chai-ps-long-to-mem-manh",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 bàn chải P/S lông tơ mềm mại siêu mảnh",
    40000,
    "images/products/3-ban-chai-ps-long-to-mem-mai-sieu-manh.jpg",
    "3-ban-chai-ps-long-to-mem-mai-sieu-manh",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "5 bàn chải đánh răng P/S Lông tơ mềm mại",
    71000,
    "images/products/5-ban-chai-anh-rang-ps-long-to-mem-mai.jpg",
    "5-ban-chai-anh-rang-ps-long-to-mem-mai",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bàn chải đánh răng Closeup Precision Clean",
    51500,
    "images/products/ban-chai-anh-rang-closeup-precision-clean.jpg",
    "ban-chai-anh-rang-closeup-precision-clean",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 bàn chải Closeup Precision Clean siêu mềm",
    73500,
    "images/products/2-ban-chai-closeup-precision-clean-sieu-mem.jpg",
    "2-ban-chai-closeup-precision-clean-sieu-mem",
    1000,
    5,
    1,
    11,
    114
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "10 cuộn giấy Bless You À La Vie 2 lớp",
    75000,
    "images/products/10-cuon-giay-bless-you-a-la-vie-2-lop.jpg",
    "10-cuon-giay-bless-you-a-la-vie-2-lop",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 cuộn giấy vệ sinh Elène xanh ngọc 3 lớp",
    53000,
    "images/products/6-cuon-giay-ve-sinh-elene-xanh-ngoc-3-lop.jpg",
    "6-cuon-giay-ve-sinh-elene-xanh-ngoc-3-lop",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 cuộn giấy vệ sinh Puri 2 lớp",
    49000,
    "images/products/6-cuon-giay-ve-sinh-puri-2-lop.jpg",
    "6-cuon-giay-ve-sinh-puri-2-lop",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 cuộn giấy PREMIER VinaRoll 3 lớp",
    63000,
    "images/products/6-cuon-giay-premier-vinaroll-3-lop.jpg",
    "6-cuon-giay-premier-vinaroll-3-lop",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 cuộn giấy Puri 3 lớp không lõi",
    63000,
    "images/products/6-cuon-giay-puri-3-lop-khong-loi.jpg",
    "6-cuon-giay-puri-3-lop-khong-loi",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 cuộn giấy Puri Premium Quality 3 lớp",
    61000,
    "images/products/6-cuon-giay-puri-premium-quality-3-lop.jpg",
    "6-cuon-giay-puri-premium-quality-3-lop",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "10 cuộn giấy vệ sinh Puri 3 lớp",
    126000,
    "images/products/10-cuon-giay-ve-sinh-puri-3-lop.jpg",
    "10-cuon-giay-ve-sinh-puri-3-lop",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "10 cuộn giấy vệ sinh không lõi Softly 2 lớp",
    35000,
    "images/products/10-cuon-giay-ve-sinh-khong-loi-softly-2-lop.jpg",
    "10-cuon-giay-ve-sinh-khong-loi-softly-2-lop",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "10 cuộn giấy Bless You L'amour 3 lớp",
    139000,
    "images/products/10-cuon-giay-bless-you-lamour-3-lop.jpg",
    "10-cuon-giay-bless-you-lamour-3-lop",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 cuộn giấy Saigon Clean 2 lớp",
    34000,
    "images/products/6-cuon-giay-saigon-clean-2-lop.jpg",
    "6-cuon-giay-saigon-clean-2-lop",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "12 cuộn giấy Saigon Care 2 lớp không lõi",
    38500,
    "images/products/12-cuon-giay-saigon-care-2-lop-khong-loi.jpg",
    "12-cuon-giay-saigon-care-2-lop-khong-loi",
    1000,
    5,
    1,
    11,
    115
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "4 gói khăn giấy treo Hannah-Seyo không mùi 4 lớp 1280 tờ",
    99000,
    "images/products/4-goi-khan-giay-treo-hannah-seyo-khong-mui-4-lop-1280-to.jpg",
    "4-goi-khan-giay-treo-hannah-seyo-khong-mui-4-lop-1280-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo 10 hộp khăn giấy Puri 2 lớp 180 tờ",
    145000,
    "images/products/combo-10-hop-khan-giay-puri-2-lop-180-to.jpg",
    "combo-10-hop-khan-giay-puri-2-lop-180-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo 10 gói khăn giấy Puri 2 lớp 250 tờ",
    105000,
    "images/products/combo-10-goi-khan-giay-puri-2-lop-250-to.jpg",
    "combo-10-goi-khan-giay-puri-2-lop-250-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 40 hộp khăn giấy Puri 2 lớp 180 tờ",
    560000,
    "images/products/thung-40-hop-khan-giay-puri-2-lop-180-to.jpg",
    "thung-40-hop-khan-giay-puri-2-lop-180-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo 10 gói khăn giấy Puri 2 lớp 220 tờ",
    139000,
    "images/products/combo-10-goi-khan-giay-puri-2-lop-220-to.jpg",
    "combo-10-goi-khan-giay-puri-2-lop-220-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 60 gói khăn giấy Puri 2 lớp 220 tờ",
    810000,
    "images/products/thung-60-goi-khan-giay-puri-2-lop-220-to.jpg",
    "thung-60-goi-khan-giay-puri-2-lop-220-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn giấy treo Hannah-Seyo không mùi 4 lớp 1280 tờ",
    39000,
    "images/products/khan-giay-treo-hannah-seyo-khong-mui-4-lop-1280-to.jpg",
    "khan-giay-treo-hannah-seyo-khong-mui-4-lop-1280-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "5 gói khăn giấy Puri 2 lớp 250 tờ",
    65000,
    "images/products/5-goi-khan-giay-puri-2-lop-250-to.jpg",
    "5-goi-khan-giay-puri-2-lop-250-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn giấy Puri 2 lớp 250 tờ",
    15000,
    "images/products/khan-giay-puri-2-lop-250-to.jpg",
    "khan-giay-puri-2-lop-250-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "5 gói khăn giấy Puri 2 lớp 220 tờ",
    85000,
    "images/products/5-goi-khan-giay-puri-2-lop-220-to.jpg",
    "5-goi-khan-giay-puri-2-lop-220-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn giấy Puri 2 lớp 220 tờ",
    19000,
    "images/products/khan-giay-puri-2-lop-220-to.jpg",
    "khan-giay-puri-2-lop-220-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 40 gói khăn giấy Puri 3 lớp 200 tờ",
    720000,
    "images/products/thung-40-goi-khan-giay-puri-3-lop-200-to.jpg",
    "thung-40-goi-khan-giay-puri-3-lop-200-to",
    1000,
    5,
    1,
    11,
    116
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói khăn ướt em bé Puri cao cấp hương phấn gói 100 miếng",
    450000,
    "images/products/thung-24-goi-khan-uot-em-be-puri-cao-cap-huong-phan-goi-100-mieng.jpg",
    "thung-24-goi-khan-uot-em-be-puri-cao-cap-huong-phan-goi-100-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 60 gói khăn ướt KinKin không mùi 30 miếng",
    540000,
    "images/products/thung-60-goi-khan-uot-kinkin-khong-mui-30-mieng.jpg",
    "thung-60-goi-khan-uot-kinkin-khong-mui-30-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói khăn ướt YKO không mùi 90 miếng",
    459000,
    "images/products/thung-24-goi-khan-uot-yko-khong-mui-90-mieng.jpg",
    "thung-24-goi-khan-uot-yko-khong-mui-90-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 24 gói khăn ướt Puri không mùi gói 80 miếng",
    459000,
    "images/products/thung-24-goi-khan-uot-puri-khong-mui-goi-80-mieng.jpg",
    "thung-24-goi-khan-uot-puri-khong-mui-goi-80-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo 10 gói khăn ướt KinKin không mùi 30 miếng",
    99000,
    "images/products/combo-10-goi-khan-uot-kinkin-khong-mui-30-mieng.jpg",
    "combo-10-goi-khan-uot-kinkin-khong-mui-30-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo 3 gói Khăn ướt cao cấp YKO không mùi 90 miếng",
    65000,
    "images/products/combo-3-goi-khan-uot-cao-cap-yko-khong-mui-90-mieng.jpg",
    "combo-3-goi-khan-uot-cao-cap-yko-khong-mui-90-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn ướt Puri hương phấn gói 80 miếng",
    37000,
    "images/products/khan-uot-puri-huong-phan-goi-80-mieng.jpg",
    "khan-uot-puri-huong-phan-goi-80-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 gói khăn ướt Puri không mùi gói 100 miếng",
    105000,
    "images/products/3-goi-khan-uot-puri-khong-mui-goi-100-mieng.jpg",
    "3-goi-khan-uot-puri-khong-mui-goi-100-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 gói khăn ướt em bé Puri cao cấp hương phấn gói 100 miếng",
    105000,
    "images/products/3-goi-khan-uot-em-be-puri-cao-cap-huong-phan-goi-100-mieng.jpg",
    "3-goi-khan-uot-em-be-puri-cao-cap-huong-phan-goi-100-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo 3 gói khăn ướt Puri không mùi gói 80 miếng",
    65000,
    "images/products/combo-3-goi-khan-uot-puri-khong-mui-goi-80-mieng.jpg",
    "combo-3-goi-khan-uot-puri-khong-mui-goi-80-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo 10 gói khăn ướt em bé Puri chiết xuất lô hội gói 20 miếng",
    99000,
    "images/products/combo-10-goi-khan-uot-em-be-puri-chiet-xuat-lo-hoi-goi-20-mieng.jpg",
    "combo-10-goi-khan-uot-em-be-puri-chiet-xuat-lo-hoi-goi-20-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Combo 10 gói khăn ướt Puri không mùi gói 20 miếng",
    69000,
    "images/products/combo-10-goi-khan-uot-puri-khong-mui-goi-20-mieng.jpg",
    "combo-10-goi-khan-uot-puri-khong-mui-goi-20-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 gói Khăn ướt có nắp KinKin không mùi 100 miếng",
    119000,
    "images/products/6-goi-khan-uot-co-nap-kinkin-khong-mui-100-mieng.jpg",
    "6-goi-khan-uot-co-nap-kinkin-khong-mui-100-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 96 gói khăn ướt Puri không mùi gói 20 miếng",
    624000,
    "images/products/thung-96-goi-khan-uot-puri-khong-mui-goi-20-mieng.jpg",
    "thung-96-goi-khan-uot-puri-khong-mui-goi-20-mieng",
    1000,
    5,
    1,
    11,
    117
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng siêu ban đêm Kotex  12 miếng 28cm",
    31000,
    "images/products/bang-sieu-ban-em-kotex-12-mieng-28cm.jpg",
    "bang-sieu-ban-em-kotex-12-mieng-28cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng ban ngày Kotex khô thoáng 23cm",
    30500,
    "images/products/bang-ban-ngay-kotex-kho-thoang-23cm.jpg",
    "bang-ban-ngay-kotex-kho-thoang-23cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng hàng ngày Kotex siêu mềm 15cm",
    19500,
    "images/products/bang-hang-ngay-kotex-sieu-mem-15cm.jpg",
    "bang-hang-ngay-kotex-sieu-mem-15cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng ban ngày Kotex Maxcool 23cm",
    36000,
    "images/products/bang-ban-ngay-kotex-maxcool-23cm.jpg",
    "bang-ban-ngay-kotex-maxcool-23cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 6 gói băng ban ngày Diana siêu thấm 23cm",
    119500,
    "images/products/loc-6-goi-bang-ban-ngay-diana-sieu-tham-23cm.jpg",
    "loc-6-goi-bang-ban-ngay-diana-sieu-tham-23cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lốc 6 gói băng vệ sinh Diana Sensi siêu mỏng cánh 8 miếng",
    119500,
    "images/products/loc-6-goi-bang-ve-sinh-diana-sensi-sieu-mong-canh-8-mieng.jpg",
    "loc-6-goi-bang-ve-sinh-diana-sensi-sieu-mong-canh-8-mieng",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng ban ngày Diana Sensi Cool Fresh 23cm",
    55000,
    "images/products/bang-ban-ngay-diana-sensi-cool-fresh-23cm.jpg",
    "bang-ban-ngay-diana-sensi-cool-fresh-23cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng ban ngày Diana Sensi siêu mỏng 23cm",
    51000,
    "images/products/bang-ban-ngay-diana-sensi-sieu-mong-23cm.jpg",
    "bang-ban-ngay-diana-sensi-sieu-mong-23cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng ban ngày Diana siêu thấm 23cm",
    48000,
    "images/products/bang-ban-ngay-diana-sieu-tham-23cm.jpg",
    "bang-ban-ngay-diana-sieu-tham-23cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng ban ngày Diana Sensi Cool 23cm",
    52000,
    "images/products/bang-ban-ngay-diana-sensi-cool-23cm.jpg",
    "bang-ban-ngay-diana-sensi-cool-23cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng ban đêm Diana chống tràn 35cm",
    72000,
    "images/products/bang-ban-em-diana-chong-tran-35cm.jpg",
    "bang-ban-em-diana-chong-tran-35cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng hàng ngày Diana Sensi Cool Fresh 15.5cm",
    43000,
    "images/products/bang-hang-ngay-diana-sensi-cool-fresh-155cm.jpg",
    "bang-hang-ngay-diana-sensi-cool-fresh-155cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Băng ban ngày Laurier Fresh and Free siêu thấm 22cm",
    46000,
    "images/products/bang-ban-ngay-laurier-fresh-and-free-sieu-tham-22cm.jpg",
    "bang-ban-ngay-laurier-fresh-and-free-sieu-tham-22cm",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 chiếc băng quần Diana Comfy Night M - L",
    30500,
    "images/products/2-chiec-bang-quan-diana-comfy-night-m---l.jpg",
    "2-chiec-bang-quan-diana-comfy-night-m---l",
    1000,
    5,
    1,
    11,
    118
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lăn khử mùi Dove Serum Vitamin C&E 45ml",
    102000,
    "images/products/lan-khu-mui-dove-serum-vitamin-ce-45ml.jpg",
    "lan-khu-mui-dove-serum-vitamin-ce-45ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lăn khử mùi Dove Serum Collagen 45ml",
    102000,
    "images/products/lan-khu-mui-dove-serum-collagen-45ml.jpg",
    "lan-khu-mui-dove-serum-collagen-45ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt khử mùi cho nam AXE Black 135ml",
    64500,
    "images/products/xit-khu-mui-cho-nam-axe-black-135ml.jpg",
    "xit-khu-mui-cho-nam-axe-black-135ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt ngăn mùi AXE Aqua Bergamot 135ml",
    140000,
    "images/products/xit-ngan-mui-axe-aqua-bergamot-135ml.jpg",
    "xit-ngan-mui-axe-aqua-bergamot-135ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lăn ngăn mùi Nivea Men phân tử bạc 50ml",
    57000/50ml,
    "images/products/lan-ngan-mui-nivea-men-phan-tu-bac-50ml.jpg",
    "lan-ngan-mui-nivea-men-phan-tu-bac-50ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lăn ngăn mùi Nivea Men khô thoáng 50ml",
    48000/50ml,
    "images/products/lan-ngan-mui-nivea-men-kho-thoang-50ml.jpg",
    "lan-ngan-mui-nivea-men-kho-thoang-50ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp khử mùi Old Spice Pure Sport High Endurance 85g",
    153000/85g,
    "images/products/sap-khu-mui-old-spice-pure-sport-high-endurance-85g.jpg",
    "sap-khu-mui-old-spice-pure-sport-high-endurance-85g",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lăn khử mùi X-Men For Boss Intense 50ml",
    79000/50ml,
    "images/products/lan-khu-mui-x-men-for-boss-intense-50ml.jpg",
    "lan-khu-mui-x-men-for-boss-intense-50ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt khử mùi X-Men For Boss Intense 150ml",
    117000/150ml,
    "images/products/xit-khu-mui-x-men-for-boss-intense-150ml.jpg",
    "xit-khu-mui-x-men-for-boss-intense-150ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp khử mùi Old Spice Bearglove Anti-Perspirant Deodorant 73g",
    194000,
    "images/products/sap-khu-mui-old-spice-bearglove-anti-perspirant-deodorant-73g.jpg",
    "sap-khu-mui-old-spice-bearglove-anti-perspirant-deodorant-73g",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lăn khử mùi Romano Gentleman khô thoáng vượt trội 50ml",
    68000,
    "images/products/lan-khu-mui-romano-gentleman-kho-thoang-vuot-troi-50ml.jpg",
    "lan-khu-mui-romano-gentleman-kho-thoang-vuot-troi-50ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lăn khử mùi Rexona Shower Clean Brightening sáng da 45ml",
    84000,
    "images/products/lan-khu-mui-rexona-shower-clean-brightening-sang-da-45ml.jpg",
    "lan-khu-mui-rexona-shower-clean-brightening-sang-da-45ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lăn khử mùi Lashe dưỡng sáng da 50ml",
    85500,
    "images/products/lan-khu-mui-lashe-duong-sang-da-50ml.jpg",
    "lan-khu-mui-lashe-duong-sang-da-50ml",
    1000,
    5,
    1,
    11,
    121
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dao cạo râu 3 lưỡi Gillette Mach 3 Clean Shave",
    168000,
    "images/products/dao-cao-rau-3-luoi-gillette-mach-3-clean-shave.jpg",
    "dao-cao-rau-3-luoi-gillette-mach-3-clean-shave",
    1000,
    5,
    1,
    11,
    123
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "6 cây dao cạo râu 2 lưỡi Gillette cán vàng",
    42000,
    "images/products/6-cay-dao-cao-rau-2-luoi-gillette-can-vang.jpg",
    "6-cay-dao-cao-rau-2-luoi-gillette-can-vang",
    1000,
    5,
    1,
    11,
    123
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lưỡi cạo râu 2 lưỡi Gillette Flexi Vibe 2Up",
    34000,
    "images/products/luoi-cao-rau-2-luoi-gillette-flexi-vibe-2up.png",
    "luoi-cao-rau-2-luoi-gillette-flexi-vibe-2up",
    1000,
    5,
    1,
    11,
    123
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dao cạo râu Gillette Flexi Vibe 1Up +4 lưỡi",
    79000,
    "images/products/dao-cao-rau-gillette-flexi-vibe-1up-4-luoi.jpg",
    "dao-cao-rau-gillette-flexi-vibe-1up-4-luoi",
    1000,
    5,
    1,
    11,
    123
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "7 cây dao cạo Gillette Blue 2 Flexi",
    52500,
    "images/products/7-cay-dao-cao-gillette-blue-2-flexi.jpg",
    "7-cay-dao-cao-gillette-blue-2-flexi",
    1000,
    5,
    1,
    11,
    123
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "10 cây dao cạo Gillette Super Thin II 2 lưỡi",
    61500,
    "images/products/10-cay-dao-cao-gillette-super-thin-ii-2-luoi.jpg",
    "10-cay-dao-cao-gillette-super-thin-ii-2-luoi",
    1000,
    5,
    1,
    11,
    123
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 cây dao cạo Gillette Blue III mát lạnh 3 lưỡi",
    58000,
    "images/products/2-cay-dao-cao-gillette-blue-iii-mat-lanh-3-luoi.png",
    "2-cay-dao-cao-gillette-blue-iii-mat-lanh-3-luoi",
    1000,
    5,
    1,
    11,
    123
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bọt cạo râu Gillette hương chanh 175g",
    109000,
    "images/products/bot-cao-rau-gillette-huong-chanh-175g.jpg",
    "bot-cao-rau-gillette-huong-chanh-175g",
    1000,
    5,
    1,
    11,
    123
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 cây dao cạo Gillette Blue III Simple 3 lưỡi",
    37000,
    "images/products/2-cay-dao-cao-gillette-blue-iii-simple-3-luoi.jpg",
    "2-cay-dao-cao-gillette-blue-iii-simple-3-luoi",
    1000,
    5,
    1,
    11,
    123
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "4 cây dao cạo 3 lưỡi Gillette Venus Simply",
    102000,
    "images/products/4-cay-dao-cao-3-luoi-gillette-venus-simply.jpg",
    "4-cay-dao-cao-3-luoi-gillette-venus-simply",
    1000,
    5,
    1,
    11,
    123
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp vuốt tóc Romano Matte Wax 68g",
    86500/68g,
    "images/products/sap-vuot-toc-romano-matte-wax-68g.jpg",
    "sap-vuot-toc-romano-matte-wax-68g",
    1000,
    5,
    1,
    11,
    130
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp vuốt tóc Romano Clay Wax 68g",
    86500/68g,
    "images/products/sap-vuot-toc-romano-clay-wax-68g.jpg",
    "sap-vuot-toc-romano-clay-wax-68g",
    1000,
    5,
    1,
    11,
    130
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp vuốt tóc X-Men Salon Solution Matte Pomade 70g",
    81000/70g,
    "images/products/sap-vuot-toc-x-men-salon-solution-matte-pomade-70g.jpg",
    "sap-vuot-toc-x-men-salon-solution-matte-pomade-70g",
    1000,
    5,
    1,
    11,
    130
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp vuốt tóc X-Men Salon Solution Clay Wax 70g",
    81000/70g,
    "images/products/sap-vuot-toc-x-men-salon-solution-clay-wax-70g.jpg",
    "sap-vuot-toc-x-men-salon-solution-clay-wax-70g",
    1000,
    5,
    1,
    11,
    130
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp vuốt tóc dày bồng Gatsby Mat 25g",
    33000,
    "images/products/sap-vuot-toc-day-bong-gatsby-mat-25g.jpg",
    "sap-vuot-toc-day-bong-gatsby-mat-25g",
    1000,
    5,
    1,
    11,
    130
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gel dưỡng tóc Double Rich tạo kiểu giữ nếp tự nhiên 250ml",
    84000/50ml,
    "images/products/gel-duong-toc-double-rich-tao-kieu-giu-nep-tu-nhien-250ml.jpg",
    "gel-duong-toc-double-rich-tao-kieu-giu-nep-tu-nhien-250ml",
    1000,
    5,
    1,
    11,
    130
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp vuốt tóc dày bồng Gatsby Mat 75g",
    63000/75g,
    "images/products/sap-vuot-toc-day-bong-gatsby-mat-75g.jpg",
    "sap-vuot-toc-day-bong-gatsby-mat-75g",
    1000,
    5,
    1,
    11,
    130
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gel vuốt tóc giữ nếp lâu Romano Classic 150g",
    54000,
    "images/products/gel-vuot-toc-giu-nep-lau-romano-classic-150g.jpg",
    "gel-vuot-toc-giu-nep-lau-romano-classic-150g",
    1000,
    5,
    1,
    11,
    130
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gel vuốt tóc cứng X-Men Strong Hold 150g",
    63000,
    "images/products/gel-vuot-toc-cung-x-men-strong-hold-150g.jpg",
    "gel-vuot-toc-cung-x-men-strong-hold-150g",
    1000,
    5,
    1,
    11,
    130
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem tẩy lông Cléo da nhạy cảm 50g",
    80000/50g,
    "images/products/kem-tay-long-cleo-da-nhay-cam-50g.jpg",
    "kem-tay-long-cleo-da-nhay-cam-50g",
    1000,
    5,
    1,
    11,
    131
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem tẩy lông Cléo da thường 50g",
    80000/50g,
    "images/products/kem-tay-long-cleo-da-thuong-50g.jpg",
    "kem-tay-long-cleo-da-thuong-50g",
    1000,
    5,
    1,
    11,
    131
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa rửa mặt Bioré sạch nhờn 100g",
    42000,
    "images/products/sua-rua-mat-biore-sach-nhon-100g.jpg",
    "sua-rua-mat-biore-sach-nhon-100g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa rửa mặt Nivea dưỡng trắng 100g",
    64000,
    "images/products/sua-rua-mat-nivea-duong-trang-100g.jpg",
    "sua-rua-mat-nivea-duong-trang-100g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem rửa mặt Acnes ngừa mụn 100g",
    64000,
    "images/products/kem-rua-mat-acnes-ngua-mun-100g.jpg",
    "kem-rua-mat-acnes-ngua-mun-100g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa rửa mặt Acnes mờ sẹo 100g",
    64000,
    "images/products/sua-rua-mat-acnes-mo-seo-100g.jpg",
    "sua-rua-mat-acnes-mo-seo-100g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa rửa mặt Simple giúp da sạch thoáng 150ml",
    112000,
    "images/products/sua-rua-mat-simple-giup-da-sach-thoang-150ml.jpg",
    "sua-rua-mat-simple-giup-da-sach-thoang-150ml",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa rửa mặt Hazeline giảm mụn 100g",
    46500,
    "images/products/sua-rua-mat-hazeline-giam-mun-100g.jpg",
    "sua-rua-mat-hazeline-giam-mun-100g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem rửa mặt Hada Labo dưỡng ẩm 80g",
    91500,
    "images/products/kem-rua-mat-hada-labo-duong-am-80g.jpg",
    "kem-rua-mat-hada-labo-duong-am-80g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gel rửa mặt Simple giảm nhờn 150ml",
    139000,
    "images/products/gel-rua-mat-simple-giam-nhon-150ml.jpg",
    "gel-rua-mat-simple-giam-nhon-150ml",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem rửa mặt Hada Labo dưỡng trắng 80g",
    87500,
    "images/products/kem-rua-mat-hada-labo-duong-trang-80g.jpg",
    "kem-rua-mat-hada-labo-duong-trang-80g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gel rửa mặt Hazeline ngừa mụn 100g",
    57500,
    "images/products/gel-rua-mat-hazeline-ngua-mun-100g.jpg",
    "gel-rua-mat-hazeline-ngua-mun-100g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa rửa mặt Nivea Men dưỡng sáng da 100g",
    104000,
    "images/products/sua-rua-mat-nivea-men-duong-sang-da-100g.jpg",
    "sua-rua-mat-nivea-men-duong-sang-da-100g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa rửa mặt cho da mụn Senka 100g",
    121000,
    "images/products/sua-rua-mat-cho-da-mun-senka-100g.jpg",
    "sua-rua-mat-cho-da-mun-senka-100g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sữa rửa mặt Senka săn chắc da 120g",
    125000,
    "images/products/sua-rua-mat-senka-san-chac-da-120g.jpg",
    "sua-rua-mat-senka-san-chac-da-120g",
    1000,
    5,
    1,
    11,
    132
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước giặt OMO Matic tinh dầu thơm 4.1kg",
    215000,
    "images/products/nuoc-giat-omo-matic-tinh-dau-thom-41kg.jpg",
    "nuoc-giat-omo-matic-tinh-dau-thom-41kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước giặt Surf hương nước hoa túi 3.1kg",
    95000,
    "images/products/nuoc-giat-surf-huong-nuoc-hoa-tui-31kg.jpg",
    "nuoc-giat-surf-huong-nuoc-hoa-tui-31kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 4 túi nước giặt Lix sạch thơm nắng hạ 3.5kg",
    410000,
    "images/products/thung-4-tui-nuoc-giat-lix-sach-thom-nang-ha-35kg.jpg",
    "thung-4-tui-nuoc-giat-lix-sach-thom-nang-ha-35kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 4 túi nước giặt Lix ngàn hoa 3.5kg",
    410000,
    "images/products/thung-4-tui-nuoc-giat-lix-ngan-hoa-35kg.jpg",
    "thung-4-tui-nuoc-giat-lix-ngan-hoa-35kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước giặt Lix sạch thơm nắng hạ 3.5kg",
    105000,
    "images/products/nuoc-giat-lix-sach-thom-nang-ha-35kg.jpg",
    "nuoc-giat-lix-sach-thom-nang-ha-35kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước giặt Lix sạch thơm ngàn hoa 3.5kg",
    105000,
    "images/products/nuoc-giat-lix-sach-thom-ngan-hoa-35kg.jpg",
    "nuoc-giat-lix-sach-thom-ngan-hoa-35kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước giặt OMO ngăn mùi ẩm mốc 4.1kg",
    215000,
    "images/products/nuoc-giat-omo-ngan-mui-am-moc-41kg.jpg",
    "nuoc-giat-omo-ngan-mui-am-moc-41kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước giặt OMO Matic hoa oải hương 2.8kg",
    160000,
    "images/products/nuoc-giat-omo-matic-hoa-oai-huong-28kg.jpg",
    "nuoc-giat-omo-matic-hoa-oai-huong-28kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước giặt Surf nước hoa hương phấn 3.1kg",
    95000,
    "images/products/nuoc-giat-surf-nuoc-hoa-huong-phan-31kg.jpg",
    "nuoc-giat-surf-nuoc-hoa-huong-phan-31kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước giặt Lix Matic nước hoa 3.2kg",
    169000,
    "images/products/nuoc-giat-lix-matic-nuoc-hoa-32kg.jpg",
    "nuoc-giat-lix-matic-nuoc-hoa-32kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Thùng 4 túi nước giặt Surf nước hoa 3.1kg",
    335000,
    "images/products/thung-4-tui-nuoc-giat-surf-nuoc-hoa-31kg.jpg",
    "thung-4-tui-nuoc-giat-surf-nuoc-hoa-31kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước giặt OMO Matic cửa trước bền màu 4.1kg",
    210000,
    "images/products/nuoc-giat-omo-matic-cua-truoc-ben-mau-41kg.jpg",
    "nuoc-giat-omo-matic-cua-truoc-ben-mau-41kg",
    1000,
    5,
    1,
    12,
    133
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả Comfort diệu kỳ 3.1 lít",
    179000,
    "images/products/nuoc-xa-comfort-dieu-ky-31-lit.jpg",
    "nuoc-xa-comfort-dieu-ky-31-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả Comfort ban mai 3.1 lít",
    170000,
    "images/products/nuoc-xa-comfort-ban-mai-31-lit.jpg",
    "nuoc-xa-comfort-ban-mai-31-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả Comfort quyến rũ 3.1 lít",
    200000,
    "images/products/nuoc-xa-comfort-quyen-ru-31-lit.jpg",
    "nuoc-xa-comfort-quyen-ru-31-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả Surf vườn hồng Juliet 2.4 lít",
    95000,
    "images/products/nuoc-xa-surf-vuon-hong-juliet-24-lit.jpg",
    "nuoc-xa-surf-vuon-hong-juliet-24-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả Downy huyền bí 3 lít",
    174000,
    "images/products/nuoc-xa-downy-huyen-bi-3-lit.jpg",
    "nuoc-xa-downy-huyen-bi-3-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả Downy nắng mai 3 lít",
    174000,
    "images/products/nuoc-xa-downy-nang-mai-3-lit.jpg",
    "nuoc-xa-downy-nang-mai-3-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả Comfort hương mẫu đơn 3.1 lít",
    209000,
    "images/products/nuoc-xa-comfort-huong-mau-on-31-lit.jpg",
    "nuoc-xa-comfort-huong-mau-on-31-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả Downy đam mê 3 lít",
    209000,
    "images/products/nuoc-xa-downy-am-me-3-lit.jpg",
    "nuoc-xa-downy-am-me-3-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả IZI HOME dịu nhẹ 2.4 lít",
    118000,
    "images/products/nuoc-xa-izi-home-diu-nhe-24-lit.jpg",
    "nuoc-xa-izi-home-diu-nhe-24-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả Downy huyền bí 3.5 lít",
    238000,
    "images/products/nuoc-xa-downy-huyen-bi-35-lit.jpg",
    "nuoc-xa-downy-huyen-bi-35-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả IZI HOME dịu nhẹ 3.2 lít",
    149000,
    "images/products/nuoc-xa-izi-home-diu-nhe-32-lit.jpg",
    "nuoc-xa-izi-home-diu-nhe-32-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước xả Comfort ban mai 3.7 lít",
    230000,
    "images/products/nuoc-xa-comfort-ban-mai-37-lit.jpg",
    "nuoc-xa-comfort-ban-mai-37-lit",
    1000,
    5,
    1,
    12,
    134
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột giặt Surf thơm duyên dáng 5.3kg",
    139000,
    "images/products/bot-giat-surf-thom-duyen-dang-53kg.jpg",
    "bot-giat-surf-thom-duyen-dang-53kg",
    1000,
    5,
    1,
    12,
    135
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột giặt Surf thơm quyến rũ 5.3kg",
    139000,
    "images/products/bot-giat-surf-thom-quyen-ru-53kg.jpg",
    "bot-giat-surf-thom-quyen-ru-53kg",
    1000,
    5,
    1,
    12,
    135
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột giặt Lix sạch thơm 24h 5.5kg",
    118000,
    "images/products/bot-giat-lix-sach-thom-24h-55kg.jpg",
    "bot-giat-lix-sach-thom-24h-55kg",
    1000,
    5,
    1,
    12,
    135
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột giặt IZI HOME trắng ngát hương 6kg",
    109000,
    "images/products/bot-giat-izi-home-trang-ngat-huong-6kg.jpg",
    "bot-giat-izi-home-trang-ngat-huong-6kg",
    1000,
    5,
    1,
    12,
    135
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột giặt Lix hương nước hoa 5.5kg",
    130000,
    "images/products/bot-giat-lix-huong-nuoc-hoa-55kg.jpg",
    "bot-giat-lix-huong-nuoc-hoa-55kg",
    1000,
    5,
    1,
    12,
    135
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột giặt OMO Comfort hoa hồng Pháp 5.1kg",
    215000,
    "images/products/bot-giat-omo-comfort-hoa-hong-phap-51kg.jpg",
    "bot-giat-omo-comfort-hoa-hong-phap-51kg",
    1000,
    5,
    1,
    12,
    135
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột giặt Lix Extra hương hoa 5.5kg",
    118000,
    "images/products/bot-giat-lix-extra-huong-hoa-55kg.jpg",
    "bot-giat-lix-extra-huong-hoa-55kg",
    1000,
    5,
    1,
    12,
    135
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột giặt Lix Extra hương chanh 5.5kg",
    118000,
    "images/products/bot-giat-lix-extra-huong-chanh-55kg.jpg",
    "bot-giat-lix-extra-huong-chanh-55kg",
    1000,
    5,
    1,
    12,
    135
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột giặt OMO sạch bẩn khử mùi 5.5kg",
    215000,
    "images/products/bot-giat-omo-sach-ban-khu-mui-55kg.jpg",
    "bot-giat-omo-sach-ban-khu-mui-55kg",
    1000,
    5,
    1,
    12,
    135
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột giặt OMO Comfort tinh dầu thơm 5.1kg",
    215000,
    "images/products/bot-giat-omo-comfort-tinh-dau-thom-51kg.jpg",
    "bot-giat-omo-comfort-tinh-dau-thom-51kg",
    1000,
    5,
    1,
    12,
    135
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén Sunlight matcha 1.9 lít",
    53000,
    "images/products/nuoc-rua-chen-sunlight-matcha-19-lit.jpg",
    "nuoc-rua-chen-sunlight-matcha-19-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén Sunlight lô hội 1.9 lít",
    53000,
    "images/products/nuoc-rua-chen-sunlight-lo-hoi-19-lit.jpg",
    "nuoc-rua-chen-sunlight-lo-hoi-19-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén IZI HOME trà xanh 1.47 lít",
    31000,
    "images/products/nuoc-rua-chen-izi-home-tra-xanh-147-lit.jpg",
    "nuoc-rua-chen-izi-home-tra-xanh-147-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén IZI HOME sả chanh 1.47 lít",
    31000,
    "images/products/nuoc-rua-chen-izi-home-sa-chanh-147-lit.jpg",
    "nuoc-rua-chen-izi-home-sa-chanh-147-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén IZI HOME trà xanh 735ml",
    21500,
    "images/products/nuoc-rua-chen-izi-home-tra-xanh-735ml.jpg",
    "nuoc-rua-chen-izi-home-tra-xanh-735ml",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén IZI HOME sả chanh 735ml",
    21500,
    "images/products/nuoc-rua-chen-izi-home-sa-chanh-735ml.jpg",
    "nuoc-rua-chen-izi-home-sa-chanh-735ml",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén Sunlight chanh 3.38 lít",
    75000,
    "images/products/nuoc-rua-chen-sunlight-chanh-338-lit.jpg",
    "nuoc-rua-chen-sunlight-chanh-338-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén Sunlight matcha 3.1 lít",
    85000,
    "images/products/nuoc-rua-chen-sunlight-matcha-31-lit.jpg",
    "nuoc-rua-chen-sunlight-matcha-31-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén Sunlight lô hội 3.1 lít",
    93000,
    "images/products/nuoc-rua-chen-sunlight-lo-hoi-31-lit.jpg",
    "nuoc-rua-chen-sunlight-lo-hoi-31-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén Lix chanh 3.43 lít",
    62000,
    "images/products/nuoc-rua-chen-lix-chanh-343-lit.jpg",
    "nuoc-rua-chen-lix-chanh-343-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén Surf chanh sả 3.38 lít",
    55000,
    "images/products/nuoc-rua-chen-surf-chanh-sa-338-lit.jpg",
    "nuoc-rua-chen-surf-chanh-sa-338-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén Lix trà xanh 3.43 lít",
    62000,
    "images/products/nuoc-rua-chen-lix-tra-xanh-343-lit.jpg",
    "nuoc-rua-chen-lix-tra-xanh-343-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén Surf trà xanh, lá dứa 3.38 lít",
    55000,
    "images/products/nuoc-rua-chen-surf-tra-xanh-la-dua-338-lit.jpg",
    "nuoc-rua-chen-surf-tra-xanh-la-dua-338-lit",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa chén Sunlight chanh 725ml",
    29000,
    "images/products/nuoc-rua-chen-sunlight-chanh-725ml.jpg",
    "nuoc-rua-chen-sunlight-chanh-725ml",
    1000,
    5,
    1,
    12,
    136
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn Sunlight bạc hà 3.6kg",
    64000,
    "images/products/nuoc-lau-san-sunlight-bac-ha-36kg.jpg",
    "nuoc-lau-san-sunlight-bac-ha-36kg",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn Sunlight hoa lily & bạch trà 3.6kg",
    64000,
    "images/products/nuoc-lau-san-sunlight-hoa-lily--bach-tra-36kg.jpg",
    "nuoc-lau-san-sunlight-hoa-lily--bach-tra-36kg",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn Sunlight chanh sả 2kg",
    41000,
    "images/products/nuoc-lau-san-sunlight-chanh-sa-2kg.jpg",
    "nuoc-lau-san-sunlight-chanh-sa-2kg",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn Rena dịu nhẹ 1 lít",
    25000/1 lít,
    "images/products/nuoc-lau-san-rena-diu-nhe-1-lit.jpg",
    "nuoc-lau-san-rena-diu-nhe-1-lit",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn Rena chanh sả 4 lít",
    64000/4 lít,
    "images/products/nuoc-lau-san-rena-chanh-sa-4-lit.jpg",
    "nuoc-lau-san-rena-chanh-sa-4-lit",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn Rena bạc hà 3.8 lít",
    55000/38 lít,
    "images/products/nuoc-lau-san-rena-bac-ha-38-lit.jpg",
    "nuoc-lau-san-rena-bac-ha-38-lit",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn Lix siêu sạch thảo mộc 3.2 lít",
    82000,
    "images/products/nuoc-lau-san-lix-sieu-sach-thao-moc-32-lit.jpg",
    "nuoc-lau-san-lix-sieu-sach-thao-moc-32-lit",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn Lix siêu sạch gừng & sả chanh 3.2 lít",
    82000,
    "images/products/nuoc-lau-san-lix-sieu-sach-gung--sa-chanh-32-lit.jpg",
    "nuoc-lau-san-lix-sieu-sach-gung--sa-chanh-32-lit",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn Sunlight lavender 1kg",
    35000/1kg,
    "images/products/nuoc-lau-san-sunlight-lavender-1kg.jpg",
    "nuoc-lau-san-sunlight-lavender-1kg",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn Sunlight chanh sả 1kg",
    39000,
    "images/products/nuoc-lau-san-sunlight-chanh-sa-1kg.jpg",
    "nuoc-lau-san-sunlight-chanh-sa-1kg",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau sàn IZI HOME hoa lily 3.8 lít",
    66500/38 lít,
    "images/products/nuoc-lau-san-izi-home-hoa-lily-38-lit.jpg",
    "nuoc-lau-san-izi-home-hoa-lily-38-lit",
    1000,
    5,
    1,
    12,
    137
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tẩy bồn cầu VIM Zero chanh 750ml",
    31000/750ml,
    "images/products/tay-bon-cau-vim-zero-chanh-750ml.jpg",
    "tay-bon-cau-vim-zero-chanh-750ml",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tẩy bồn cầu & nhà tắm VIM 880ml",
    35000,
    "images/products/tay-bon-cau--nha-tam-vim-880ml.png",
    "tay-bon-cau--nha-tam-vim-880ml",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Viên treo bồn cầu VIM hoa oải hương 50g",
    25000,
    "images/products/vien-treo-bon-cau-vim-hoa-oai-huong-50g.jpg",
    "vien-treo-bon-cau-vim-hoa-oai-huong-50g",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tẩy bồn cầu OKAY 960ml",
    30000,
    "images/products/tay-bon-cau-okay-960ml.jpg",
    "tay-bon-cau-okay-960ml",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột tẩy lồng giặt Mao Bao 300g",
    41000/300g,
    "images/products/bot-tay-long-giat-mao-bao-300g.jpg",
    "bot-tay-long-giat-mao-bao-300g",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột tẩy lồng giặt Sandokkaebi 450g",
    40000,
    "images/products/bot-tay-long-giat-sandokkaebi-450g.jpg",
    "bot-tay-long-giat-sandokkaebi-450g",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tẩy bồn cầu VIM chanh sả 870ml",
    35000,
    "images/products/tay-bon-cau-vim-chanh-sa-870ml.jpg",
    "tay-bon-cau-vim-chanh-sa-870ml",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Gel tẩy nhà tắm VIM lavender 870ml",
    35000/870ml,
    "images/products/gel-tay-nha-tam-vim-lavender-870ml.jpg",
    "gel-tay-nha-tam-vim-lavender-870ml",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Tẩy nhà tắm VIM lavender 870ml và 5 vỉ treo bồn cầu VIM oải hương 250g",
    143000,
    "images/products/tay-nha-tam-vim-lavender-870ml-va-5-vi-treo-bon-cau-vim-oai-huong-250g.jpg",
    "tay-nha-tam-vim-lavender-870ml-va-5-vi-treo-bon-cau-vim-oai-huong-250g",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước rửa tay Lifebuoy 444ml và gel tẩy bồn cầu & nhà tắm VIM 870ml",
    117000,
    "images/products/nuoc-rua-tay-lifebuoy-444ml-va-gel-tay-bon-cau--nha-tam-vim-870ml.jpg",
    "nuoc-rua-tay-lifebuoy-444ml-va-gel-tay-bon-cau--nha-tam-vim-870ml",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "5 vỉ treo bồn cầu VIM hoa oải hương 250g",
    108000,
    "images/products/5-vi-treo-bon-cau-vim-hoa-oai-huong-250g.jpg",
    "5-vi-treo-bon-cau-vim-hoa-oai-huong-250g",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Viên treo bồn cầu VIM chanh 50g",
    25000,
    "images/products/vien-treo-bon-cau-vim-chanh-50g.jpg",
    "vien-treo-bon-cau-vim-chanh-50g",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Viên vệ sinh bồn cầu Hando 275g",
    42000,
    "images/products/vien-ve-sinh-bon-cau-hando-275g.jpg",
    "vien-ve-sinh-bon-cau-hando-275g",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Viên vệ sinh bồn cầu Hando 165g",
    26000,
    "images/products/vien-ve-sinh-bon-cau-hando-165g.jpg",
    "vien-ve-sinh-bon-cau-hando-165g",
    1000,
    5,
    1,
    12,
    138
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt muỗi Raid lavender 520ml",
    54000,
    "images/products/xit-muoi-raid-lavender-520ml.jpg",
    "xit-muoi-raid-lavender-520ml",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt côn trùng Jumbo Vape G cam chanh 600ml",
    69000,
    "images/products/xit-con-trung-jumbo-vape-g-cam-chanh-600ml.jpg",
    "xit-con-trung-jumbo-vape-g-cam-chanh-600ml",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt muỗi Jumbo F10 cam chanh 600ml",
    59000,
    "images/products/xit-muoi-jumbo-f10-cam-chanh-600ml.jpg",
    "xit-muoi-jumbo-f10-cam-chanh-600ml",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt côn trùng Jumbo lavender 600ml",
    69000,
    "images/products/xit-con-trung-jumbo-lavender-600ml.jpg",
    "xit-con-trung-jumbo-lavender-600ml",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt muỗi Jumbo F7 Vape không mùi 600ml",
    59000,
    "images/products/xit-muoi-jumbo-f7-vape-khong-mui-600ml.jpg",
    "xit-muoi-jumbo-f7-vape-khong-mui-600ml",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt côn trùng Jumbo Vape G1 không mùi 600ml",
    72500,
    "images/products/xit-con-trung-jumbo-vape-g1-khong-mui-600ml.jpg",
    "xit-con-trung-jumbo-vape-g1-khong-mui-600ml",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "10 khoanh nhang Jumbo M22 120g",
    8200,
    "images/products/10-khoanh-nhang-jumbo-m22-120g.jpg",
    "10-khoanh-nhang-jumbo-m22-120g",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dung dịch đuổi muỗi ARS Nomat 45ml",
    28000,
    "images/products/dung-dich-uoi-muoi-ars-nomat-45ml.jpg",
    "dung-dich-uoi-muoi-ars-nomat-45ml",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bộ xông đuổi muỗi ARS Nomat 45ml",
    47500,
    "images/products/bo-xong-uoi-muoi-ars-nomat-45ml.jpg",
    "bo-xong-uoi-muoi-ars-nomat-45ml",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt muỗi & côn trùng bay ARS 600ml",
    68500,
    "images/products/xit-muoi--con-trung-bay-ars-600ml.jpg",
    "xit-muoi--con-trung-bay-ars-600ml",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt côn trùng ARS không mùi 600ml",
    70500,
    "images/products/xit-con-trung-ars-khong-mui-600ml.jpg",
    "xit-con-trung-ars-khong-mui-600ml",
    1000,
    5,
    1,
    12,
    139
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Túi thơm Sunflower hoa nhài 30g",
    17000,
    "images/products/tui-thom-sunflower-hoa-nhai-30g.jpg",
    "tui-thom-sunflower-hoa-nhai-30g",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Túi thơm Sunflower hương biển 30g",
    17000,
    "images/products/tui-thom-sunflower-huong-bien-30g.jpg",
    "tui-thom-sunflower-huong-bien-30g",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Túi thơm Sunflower hoa hồng 30g",
    17000,
    "images/products/tui-thom-sunflower-hoa-hong-30g.jpg",
    "tui-thom-sunflower-hoa-hong-30g",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Túi thơm Sunflower hoa oải hương 30g",
    17000,
    "images/products/tui-thom-sunflower-hoa-oai-huong-30g.jpg",
    "tui-thom-sunflower-hoa-oai-huong-30g",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp thơm Glade hoa hồng trắng & mẫu đơn 180g",
    50000,
    "images/products/sap-thom-glade-hoa-hong-trang--mau-on-180g.jpg",
    "sap-thom-glade-hoa-hong-trang--mau-on-180g",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp thơm Glade hương tươi mát 180g",
    50000,
    "images/products/sap-thom-glade-huong-tuoi-mat-180g.jpg",
    "sap-thom-glade-huong-tuoi-mat-180g",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp thơm Ambi Pur downy huyền bí 180g",
    73000,
    "images/products/sap-thom-ambi-pur-downy-huyen-bi-180g.jpg",
    "sap-thom-ambi-pur-downy-huyen-bi-180g",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Sáp thơm Ambi Pur downy đam mê 180g",
    73000,
    "images/products/sap-thom-ambi-pur-downy-am-me-180g.jpg",
    "sap-thom-ambi-pur-downy-am-me-180g",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt phòng Oasis hoa hồng 320ml",
    45500,
    "images/products/xit-phong-oasis-hoa-hong-320ml.jpg",
    "xit-phong-oasis-hoa-hong-320ml",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt phòng Oasis hoa oải hương 320ml",
    45500,
    "images/products/xit-phong-oasis-hoa-oai-huong-320ml.jpg",
    "xit-phong-oasis-hoa-oai-huong-320ml",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt phòng Spring hoa ylang 250ml",
    36000,
    "images/products/xit-phong-spring-hoa-ylang-250ml.jpg",
    "xit-phong-spring-hoa-ylang-250ml",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt phòng Spring hương phấn 250ml",
    36000,
    "images/products/xit-phong-spring-huong-phan-250ml.jpg",
    "xit-phong-spring-huong-phan-250ml",
    1000,
    5,
    1,
    12,
    140
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Xịt lau bếp Sunlight bọt tuyết 500ml",
    31000,
    "images/products/xit-lau-bep-sunlight-bot-tuyet-500ml.jpg",
    "xit-lau-bep-sunlight-bot-tuyet-500ml",
    1000,
    5,
    1,
    12,
    141
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau đa năng Sunlight chanh sả 500ml",
    31000,
    "images/products/nuoc-lau-a-nang-sunlight-chanh-sa-500ml.jpg",
    "nuoc-lau-a-nang-sunlight-chanh-sa-500ml",
    1000,
    5,
    1,
    12,
    141
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "50 tờ khăn lau bếp Hefei Huicheng",
    45000,
    "images/products/50-to-khan-lau-bep-hefei-huicheng.jpg",
    "50-to-khan-lau-bep-hefei-huicheng",
    1000,
    5,
    1,
    12,
    141
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Lau kính Sunlight siêu nhanh 520ml",
    28000/520ml,
    "images/products/lau-kinh-sunlight-sieu-nhanh-520ml.jpg",
    "lau-kinh-sunlight-sieu-nhanh-520ml",
    1000,
    5,
    1,
    12,
    141
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kem tẩy đa năng Sunlight 690g",
    35000/690g,
    "images/products/kem-tay-a-nang-sunlight-690g.jpg",
    "kem-tay-a-nang-sunlight-690g",
    1000,
    5,
    1,
    12,
    141
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau bếp Gift Orange Power 540ml",
    28500,
    "images/products/nuoc-lau-bep-gift-orange-power-540ml.jpg",
    "nuoc-lau-bep-gift-orange-power-540ml",
    1000,
    5,
    1,
    12,
    141
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau kính Lix thơm tươi mát 650ml",
    24000/650ml,
    "images/products/nuoc-lau-kinh-lix-thom-tuoi-mat-650ml.jpg",
    "nuoc-lau-kinh-lix-thom-tuoi-mat-650ml",
    1000,
    5,
    1,
    12,
    141
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước lau kính Gift trà xanh 540ml",
    25000,
    "images/products/nuoc-lau-kinh-gift-tra-xanh-540ml.jpg",
    "nuoc-lau-kinh-gift-tra-xanh-540ml",
    1000,
    5,
    1,
    12,
    141
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bột baking soda Arm & Hammer hộp 454g",
    51500,
    "images/products/bot-baking-soda-arm--hammer-hop-454g.jpg",
    "bot-baking-soda-arm--hammer-hop-454g",
    1000,
    5,
    1,
    12,
    141
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tẩy vải màu AXO thanh khiết 800ml",
    44000,
    "images/products/nuoc-tay-vai-mau-axo-thanh-khiet-800ml.jpg",
    "nuoc-tay-vai-mau-axo-thanh-khiet-800ml",
    1000,
    5,
    1,
    12,
    142
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tẩy vải màu AXO hoa đào 800ml",
    44000,
    "images/products/nuoc-tay-vai-mau-axo-hoa-ao-800ml.jpg",
    "nuoc-tay-vai-mau-axo-hoa-ao-800ml",
    1000,
    5,
    1,
    12,
    142
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tẩy vải màu AXO tươi mát 800ml",
    42000,
    "images/products/nuoc-tay-vai-mau-axo-tuoi-mat-800ml.jpg",
    "nuoc-tay-vai-mau-axo-tuoi-mat-800ml",
    1000,
    5,
    1,
    12,
    142
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tẩy vải màu On1 tropical blossom 784ml",
    37000,
    "images/products/nuoc-tay-vai-mau-on1-tropical-blossom-784ml.jpg",
    "nuoc-tay-vai-mau-on1-tropical-blossom-784ml",
    1000,
    5,
    1,
    12,
    142
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Nước tẩy vải trắng Lix Javel 943ml",
    19000,
    "images/products/nuoc-tay-vai-trang-lix-javel-943ml.jpg",
    "nuoc-tay-vai-trang-lix-javel-943ml",
    1000,
    5,
    1,
    12,
    142
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 cuộn túi đựng rác màu TBP 64x78cm (1kg)",
    63000,
    "images/products/3-cuon-tui-ung-rac-mau-tbp-64x78cm-1kg.jpg",
    "3-cuon-tui-ung-rac-mau-tbp-64x78cm-1kg",
    1000,
    5,
    1,
    14,
    150
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 cuộn túi đựng rác màu TBP 55x65cm (1kg)",
    63000,
    "images/products/3-cuon-tui-ung-rac-mau-tbp-55x65cm-1kg.jpg",
    "3-cuon-tui-ung-rac-mau-tbp-55x65cm-1kg",
    1000,
    5,
    1,
    14,
    150
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 cuộn túi đựng rác màu TBP 45x55cm",
    63000,
    "images/products/3-cuon-tui-ung-rac-mau-tbp-45x55cm.jpg",
    "3-cuon-tui-ung-rac-mau-tbp-45x55cm",
    1000,
    5,
    1,
    14,
    150
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 cuộn túi đựng rác đen TBP 64x78cm (1kg)",
    58000,
    "images/products/3-cuon-tui-ung-rac-en-tbp-64x78cm-1kg.jpg",
    "3-cuon-tui-ung-rac-en-tbp-64x78cm-1kg",
    1000,
    5,
    1,
    14,
    150
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 cuộn túi đựng rác đen TBP 55x65cm (1kg)",
    58000,
    "images/products/3-cuon-tui-ung-rac-en-tbp-55x65cm-1kg.jpg",
    "3-cuon-tui-ung-rac-en-tbp-55x65cm-1kg",
    1000,
    5,
    1,
    14,
    150
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 cuộn túi đựng rác đen TBP 45x55cm",
    58000,
    "images/products/3-cuon-tui-ung-rac-en-tbp-45x55cm.jpg",
    "3-cuon-tui-ung-rac-en-tbp-45x55cm",
    1000,
    5,
    1,
    14,
    150
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "100 cái lưới lọc rác bồn rửa TBP",
    37000,
    "images/products/100-cai-luoi-loc-rac-bon-rua-tbp.jpg",
    "100-cai-luoi-loc-rac-bon-rua-tbp",
    1000,
    5,
    1,
    14,
    150
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 cuộn túi đựng rác đen Biohome 64x78cm (1kg)",
    56000,
    "images/products/3-cuon-tui-ung-rac-en-biohome-64x78cm-1kg.jpg",
    "3-cuon-tui-ung-rac-en-biohome-64x78cm-1kg",
    1000,
    5,
    1,
    14,
    150
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 cuộn túi rác đen Biohome 55x65cm (1kg)",
    56000,
    "images/products/3-cuon-tui-rac-en-biohome-55x65cm-1kg.jpg",
    "3-cuon-tui-rac-en-biohome-55x65cm-1kg",
    1000,
    5,
    1,
    14,
    150
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "3 cuộn túi rác đen Biohome 45x55cm (1kg)",
    56000,
    "images/products/3-cuon-tui-rac-en-biohome-45x55cm-1kg.jpg",
    "3-cuon-tui-rac-en-biohome-45x55cm-1kg",
    1000,
    5,
    1,
    14,
    150
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "4 viên pin tiểu AA Con Ó",
    15900,
    "images/products/4-vien-pin-tieu-aa-con-o.jpg",
    "4-vien-pin-tieu-aa-con-o",
    1000,
    5,
    1,
    14,
    151
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "4 viên pin tiểu AAA Con Ó",
    12300,
    "images/products/4-vien-pin-tieu-aaa-con-o.jpg",
    "4-vien-pin-tieu-aaa-con-o",
    1000,
    5,
    1,
    14,
    151
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "4 viên pin AA Panasonic LR6T",
    63000,
    "images/products/4-vien-pin-aa-panasonic-lr6t.jpg",
    "4-vien-pin-aa-panasonic-lr6t",
    1000,
    5,
    1,
    14,
    151
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 viên pin AA Panasonic LR6T/2B-V",
    34000,
    "images/products/2-vien-pin-aa-panasonic-lr6t2b-v.jpg",
    "2-vien-pin-aa-panasonic-lr6t2b-v",
    1000,
    5,
    1,
    14,
    151
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 viên pin AAA Panasonic Manganese",
    11800,
    "images/products/2-vien-pin-aaa-panasonic-manganese.jpg",
    "2-vien-pin-aaa-panasonic-manganese",
    1000,
    5,
    1,
    14,
    151
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "4 viên pin AA Panasonic Manganese",
    26000,
    "images/products/4-vien-pin-aa-panasonic-manganese.jpg",
    "4-vien-pin-aa-panasonic-manganese",
    1000,
    5,
    1,
    14,
    151
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "2 viên pin AAA Panasonic LR03T",
    34000,
    "images/products/2-vien-pin-aaa-panasonic-lr03t.jpg",
    "2-vien-pin-aaa-panasonic-lr03t",
    1000,
    5,
    1,
    14,
    151
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "4 viên pin AAA Panasonic LR03T",
    63000,
    "images/products/4-vien-pin-aaa-panasonic-lr03t.jpg",
    "4-vien-pin-aaa-panasonic-lr03t",
    1000,
    5,
    1,
    14,
    151
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Túi tái sử dụng Mamamy",
    10000,
    "images/products/tui-tai-su-dung-mamamy.svg",
    "tui-tai-su-dung-mamamy",
    1000,
    5,
    1,
    14,
    152
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Màng bọc thực phẩm PVC 30cm x 100m",
    79000,
    "images/products/mang-boc-thuc-pham-pvc-30cm-x-100m.jpg",
    "mang-boc-thuc-pham-pvc-30cm-x-100m",
    1000,
    5,
    1,
    14,
    152
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "50 giấy thấm dầu 20x22cm",
    55000,
    "images/products/50-giay-tham-dau-20x22cm.jpg",
    "50-giay-tham-dau-20x22cm",
    1000,
    5,
    1,
    14,
    152
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "200 túi đựng thực phẩm 20 x 30 cm",
    28500,
    "images/products/200-tui-ung-thuc-pham-20-x-30-cm.jpg",
    "200-tui-ung-thuc-pham-20-x-30-cm",
    1000,
    5,
    1,
    14,
    152
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "250 túi đựng thực phẩm 17 x 25 cm",
    29500,
    "images/products/250-tui-ung-thuc-pham-17-x-25-cm.jpg",
    "250-tui-ung-thuc-pham-17-x-25-cm",
    1000,
    5,
    1,
    14,
    152
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Túi bọc thực phẩm đa năng TBP 20 cái",
    21000,
    "images/products/tui-boc-thuc-pham-a-nang-tbp-20-cai.jpg",
    "tui-boc-thuc-pham-a-nang-tbp-20-cai",
    1000,
    5,
    1,
    14,
    152
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Màng bọc nhôm Kokusai 30cmx7m",
    37000,
    "images/products/mang-boc-nhom-kokusai-30cmx7m.jpg",
    "mang-boc-nhom-kokusai-30cmx7m",
    1000,
    5,
    1,
    14,
    152
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "20 túi zipper khóa bấm Inochi",
    28500,
    "images/products/20-tui-zipper-khoa-bam-inochi.jpg",
    "20-tui-zipper-khoa-bam-inochi",
    1000,
    5,
    1,
    14,
    152
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Màng bọc thực phẩm Tamiko",
    184000,
    "images/products/mang-boc-thuc-pham-tamiko.jpg",
    "mang-boc-thuc-pham-tamiko",
    1000,
    5,
    1,
    14,
    152
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Màng bọc thực phẩm Las Palms",
    116000,
    "images/products/mang-boc-thuc-pham-las-palms.jpg",
    "mang-boc-thuc-pham-las-palms",
    1000,
    5,
    1,
    14,
    152
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp đựng thực phẩm trữ đông nhựa Hokkaido Inochi 290ml (giao màu ngẫu nhiên)",
    19000,
    "images/products/hop-ung-thuc-pham-tru-ong-nhua-hokkaido-inochi-290ml-giao-mau-ngau-nhien.jpg",
    "hop-ung-thuc-pham-tru-ong-nhua-hokkaido-inochi-290ml-giao-mau-ngau-nhien",
    1000,
    5,
    1,
    14,
    154
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp dựng hành tỏi Hokkaido vuông Inochi (giao màu ngẫu nhiên)",
    19000,
    "images/products/hop-dung-hanh-toi-hokkaido-vuong-inochi-giao-mau-ngau-nhien.jpg",
    "hop-dung-hanh-toi-hokkaido-vuong-inochi-giao-mau-ngau-nhien",
    1000,
    5,
    1,
    14,
    154
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp dựng hành tỏi Hokkaido tròn Inochi (giao màu ngẫu nhiên)",
    19000,
    "images/products/hop-dung-hanh-toi-hokkaido-tron-inochi-giao-mau-ngau-nhien.jpg",
    "hop-dung-hanh-toi-hokkaido-tron-inochi-giao-mau-ngau-nhien",
    1000,
    5,
    1,
    14,
    154
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "10 hộp thực phẩm nhựa Kokusai 1000ml",
    68500,
    "images/products/10-hop-thuc-pham-nhua-kokusai-1000ml.jpg",
    "10-hop-thuc-pham-nhua-kokusai-1000ml",
    1000,
    5,
    1,
    14,
    154
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Hộp dựng hành tỏi Hokkaido oval Inochi (giao màu ngẫu nhiên)",
    19000,
    "images/products/hop-dung-hanh-toi-hokkaido-oval-inochi-giao-mau-ngau-nhien.jpg",
    "hop-dung-hanh-toi-hokkaido-oval-inochi-giao-mau-ngau-nhien",
    1000,
    5,
    1,
    14,
    154
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bộ 3 hộp thực phẩm nhựa tròn Biohome",
    68500,
    "images/products/bo-3-hop-thuc-pham-nhua-tron-biohome.jpg",
    "bo-3-hop-thuc-pham-nhua-tron-biohome",
    1000,
    5,
    1,
    14,
    154
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chảo trơn chống dính đáy từ Sunhouse Saving 20cm",
    64500,
    "images/products/chao-tron-chong-dinh-ay-tu-sunhouse-saving-20cm.jpg",
    "chao-tron-chong-dinh-ay-tu-sunhouse-saving-20cm",
    1000,
    5,
    1,
    14,
    155
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Chảo nhôm chống dính Rainy 26cm",
    136000,
    "images/products/chao-nhom-chong-dinh-rainy-26cm.jpg",
    "chao-nhom-chong-dinh-rainy-26cm",
    1000,
    5,
    1,
    14,
    155
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bộ 2 dao bào vỏ sợi Tân Bách Phát",
    29000,
    "images/products/bo-2-dao-bao-vo-soi-tan-bach-phat.jpg",
    "bo-2-dao-bao-vo-soi-tan-bach-phat",
    1000,
    5,
    1,
    14,
    156
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dao thái inox Tân Bách Phát 28cm",
    26000,
    "images/products/dao-thai-inox-tan-bach-phat-28cm.jpg",
    "dao-thai-inox-tan-bach-phat-28cm",
    1000,
    5,
    1,
    14,
    156
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dao thái cán vàng Tân Bách Phát 28cm",
    29000,
    "images/products/dao-thai-can-vang-tan-bach-phat-28cm.jpg",
    "dao-thai-can-vang-tan-bach-phat-28cm",
    1000,
    5,
    1,
    14,
    156
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Kéo làm cá Tân Bách Phát 22.8cm",
    55500,
    "images/products/keo-lam-ca-tan-bach-phat-228cm.jpg",
    "keo-lam-ca-tan-bach-phat-228cm",
    1000,
    5,
    1,
    14,
    156
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Dây tắm nhựa PE Minitool 25cm",
    47500,
    "images/products/day-tam-nhua-pe-minitool-25cm.jpg",
    "day-tam-nhua-pe-minitool-25cm",
    1000,
    5,
    1,
    14,
    162
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn mặt cotton Shine 28x46cm",
    24500,
    "images/products/khan-mat-cotton-shine-28x46cm.jpg",
    "khan-mat-cotton-shine-28x46cm",
    1000,
    5,
    1,
    14,
    162
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn mặt siêu mềm Shine 30x50cm",
    36000,
    "images/products/khan-mat-sieu-mem-shine-30x50cm.jpg",
    "khan-mat-sieu-mem-shine-30x50cm",
    1000,
    5,
    1,
    14,
    162
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn tắm xơ tre Shine 50x100cm",
    105000,
    "images/products/khan-tam-xo-tre-shine-50x100cm.jpg",
    "khan-tam-xo-tre-shine-50x100cm",
    1000,
    5,
    1,
    14,
    162
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn tắm siêu mềm Shine 50x100cm",
    115000,
    "images/products/khan-tam-sieu-mem-shine-50x100cm.jpg",
    "khan-tam-sieu-mem-shine-50x100cm",
    1000,
    5,
    1,
    14,
    162
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bông tắm 3 nấc Bách hoá XANH 24cm",
    51500,
    "images/products/bong-tam-3-nac-bach-hoa-xanh-24cm.jpg",
    "bong-tam-3-nac-bach-hoa-xanh-24cm",
    1000,
    5,
    1,
    14,
    162
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn tắm sợi tre Vina Towel 60x120cm",
    142000,
    "images/products/khan-tam-soi-tre-vina-towel-60x120cm.jpg",
    "khan-tam-soi-tre-vina-towel-60x120cm",
    1000,
    5,
    1,
    14,
    162
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn mặt sợi tre Viet Hope 28x48cm",
    30000,
    "images/products/khan-mat-soi-tre-viet-hope-28x48cm.jpg",
    "khan-mat-soi-tre-viet-hope-28x48cm",
    1000,
    5,
    1,
    14,
    162
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Khăn tắm cotton Viet Hope 50x100cm",
    100000,
    "images/products/khan-tam-cotton-viet-hope-50x100cm.jpg",
    "khan-tam-cotton-viet-hope-50x100cm",
    1000,
    5,
    1,
    14,
    162
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bông tắm 1 lớp Unibee 15.5cm",
    39000,
    "images/products/bong-tam-1-lop-unibee-155cm.jpeg",
    "bong-tam-1-lop-unibee-155cm",
    1000,
    5,
    1,
    14,
    162
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bút bi Thiên Long TL-089 xanh vỉ 3 cây",
    13700,
    "None",
    "but-bi-thien-long-tl-089-xanh-vi-3-cay",
    1000,
    5,
    1,
    14,
    164
);

INSERT INTO products (product_name, price, img, url, stock, rating, status, category_id, subcategory_id)
VALUES (
    "Bút bi Thiên Long TL-08 xanh vỉ 3 cây",
    14200,
    "images/products/but-bi-thien-long-tl-08-xanh-vi-3-cay.jpg",
    "but-bi-thien-long-tl-08-xanh-vi-3-cay",
    1000,
    5,
    1,
    14,
    164
);