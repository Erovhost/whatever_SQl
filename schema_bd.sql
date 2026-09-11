-- MySQL 8.0.16+ --

CREATE DATABASE IF NOT EXISTS partners_db;
USE partners_db;
 
DROP TABLE IF EXISTS deliveries, products, partners, product_types, partner_types;
 
CREATE TABLE partner_types (
  partner_type_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE
);
 
CREATE TABLE partners (
  partner_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  partner_type_id INT UNSIGNED NOT NULL,
  name VARCHAR(255) NOT NULL,
  director_name VARCHAR(255),
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(20),
  inn VARCHAR(12) NOT NULL UNIQUE CHECK (inn REGEXP '^([0-9]{10}|[0-9]{12})$'),
  legal_address VARCHAR(500),
  rating DECIMAL(3,1) CHECK (rating BETWEEN 0 AND 5),
  CONSTRAINT fk_partner_type FOREIGN KEY (partner_type_id)
        REFERENCES partner_types (partner_type_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
 
CREATE TABLE product_types (
  product_type_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);
 
CREATE TABLE products (
  product_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  product_type_id INT UNSIGNED,
  article VARCHAR(50) UNIQUE,
  name VARCHAR(255) NOT NULL UNIQUE,
  min_partner_price DECIMAL(12,2) CHECK (min_partner_price >= 0),
  CONSTRAINT fk_product_type FOREIGN KEY (product_type_id)
        REFERENCES product_types (product_type_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
 
CREATE TABLE deliveries (
  delivery_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  partner_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  quantity INT UNSIGNED NOT NULL CHECK (quantity > 0),
  delivery_date DATE NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
  CONSTRAINT fk_delivery_partner FOREIGN KEY (partner_id)
        REFERENCES partners (partner_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_delivery_product FOREIGN KEY (product_id)
        REFERENCES products (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
