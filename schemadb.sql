-- MySQL 8.0.16+ --

CREATE DATABASE IF NOT EXISTS partners_db
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
USE partners_db;

DROP TABLE IF EXISTS delivery_items, deliveries, products, partners, product_types, partner_types;

CREATE TABLE partner_types (
  partner_type_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(50)  NOT NULL,

  CONSTRAINT uq_partner_types_name UNIQUE (name)
) ENGINE=InnoDB;

CREATE TABLE partners (
  partner_id      INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  partner_type_id INT UNSIGNED NOT NULL,
  name            VARCHAR(255) NOT NULL,
  director_name   VARCHAR(255),
  email           VARCHAR(255) NOT NULL,
  phone           VARCHAR(20),
  inn             VARCHAR(12)  NOT NULL,
  legal_address   VARCHAR(500),
  rating          DECIMAL(3,1),

  CONSTRAINT uq_partners_email UNIQUE (email),
  CONSTRAINT uq_partners_inn   UNIQUE (inn),
  CONSTRAINT fk_partners_type  FOREIGN KEY (partner_type_id)
        REFERENCES partner_types (partner_type_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_partners_rating CHECK (rating BETWEEN 0 AND 5)
) ENGINE=InnoDB;

CREATE TABLE product_types (
  product_type_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(100) NOT NULL,

  CONSTRAINT uq_product_types_name UNIQUE (name)
) ENGINE=InnoDB;

CREATE TABLE products (
  product_id      INT UNSIGNED  NOT NULL AUTO_INCREMENT PRIMARY KEY,
  product_type_id INT UNSIGNED  NOT NULL,
  article         VARCHAR(50),
  name            VARCHAR(255)  NOT NULL,
  unit_price      DECIMAL(12,2),

  CONSTRAINT uq_products_article UNIQUE (article),
  CONSTRAINT uq_products_name    UNIQUE (name),
  CONSTRAINT fk_products_type    FOREIGN KEY (product_type_id)
        REFERENCES product_types (product_type_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_products_price CHECK (unit_price >= 0)
) ENGINE=InnoDB;

CREATE TABLE deliveries (
  delivery_id   INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  partner_id    INT UNSIGNED NOT NULL,
  delivery_date DATE         NOT NULL,

  CONSTRAINT fk_deliveries_partner FOREIGN KEY (partner_id)
        REFERENCES partners (partner_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE delivery_items (
  item_id           INT UNSIGNED  NOT NULL AUTO_INCREMENT PRIMARY KEY,
  delivery_id       INT UNSIGNED  NOT NULL,
  product_id        INT UNSIGNED  NOT NULL,
  quantity          INT UNSIGNED  NOT NULL,
  price_at_delivery DECIMAL(12,2) NOT NULL,

  CONSTRAINT fk_items_delivery FOREIGN KEY (delivery_id)
        REFERENCES deliveries (delivery_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_items_product  FOREIGN KEY (product_id)
        REFERENCES products (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_items_quantity CHECK (quantity > 0),
  CONSTRAINT chk_items_price    CHECK (price_at_delivery >= 0),

  INDEX idx_items_delivery (delivery_id),
  INDEX idx_items_product  (product_id)
) ENGINE=InnoDB;

-- ТЕСТОВЫЕ ДАННЫЕ

INSERT INTO partner_types (name) VALUES
('ЗАО'), ('ООО'), ('ПАО'), ('ИП');

INSERT INTO product_types (name) VALUES
('Консоли'), ('Игры'), ('Геймпады'), ('Аксессуары');

INSERT INTO partners (partner_type_id, name, director_name, email, phone, inn, legal_address, rating) VALUES
(2, 'ГеймДистрибьюшн', 'Иванов Иван Иванович',    'ivanov@gamedist.ru',  '+7(999)123-45-67', '7707083893',   'г. Краснодар, ул. Красная, д. 1',   4.5),
(2, 'КонсольОпт',      'Петров Пётр Петрович',    'petrov@consopt.ru',   '+7(999)765-43-21', '7710140679',   'г. Москва, ул. Пушкина, д. 10',     3.8),
(4, 'ПиксельТрейд',    'Сидорова Анна Сергеевна', 'sidorova@pixtrade.ru','+7(999)555-11-22', '772345678901', 'г. Ростов-на-Дону, пр. Мира, д. 7', 5.0);

INSERT INTO products (product_type_id, article, name, unit_price) VALUES
(1, 'ART-1001', 'Игровая консоль PlayStation 5 Slim, 1 ТБ',          64990.00),
(1, 'ART-1002', 'Игровая консоль PlayStation 5 Digital Edition',     54990.00),
(1, 'ART-1003', 'Игровая консоль Nintendo Switch OLED, 64 ГБ',       32990.00),
(1, 'ART-1004', 'Игровая консоль Nintendo Switch Lite',              19990.00),
(2, 'ART-1005', 'Игра для PS5',                                       5490.00),
(2, 'ART-1006', 'Игра для Nintendo Switch, платформер',               4290.00),
(3, 'ART-1007', 'Беспроводной геймпад DualSense для PS5',              7990.00),
(3, 'ART-1008', 'Контроллер Nintendo Switch Pro',                      8490.00),
(3, 'ART-1009', 'Пара контроллеров Joy-Con для Nintendo Switch',       7290.00),
(4, 'ART-1010', 'Зарядная станция для двух геймпадов',                 2690.00),
(4, 'ART-1011', 'Карта памяти microSD 256 ГБ для Nintendo Switch',     3450.00),
(4, 'ART-1012', 'Чехол защитный для портативной консоли',              1290.00);

INSERT INTO deliveries (partner_id, delivery_date) VALUES
(1, '2026-09-01'),
(2, '2026-09-05'),
(1, '2026-09-12');

-- Цены отличаются от прайса: скидки по конкретным поставкам
INSERT INTO delivery_items (delivery_id, product_id, quantity, price_at_delivery) VALUES
(1, 1,  15, 61500.00),
(1, 3,  20, 31200.00),
(1, 7,  40,  7450.00),
(2, 4,  25, 18800.00),
(2, 9,  30,  6900.00),
(3, 5, 100,  5100.00),
(3, 6,  80,  3950.00),
(3, 11, 60,  3200.00);
