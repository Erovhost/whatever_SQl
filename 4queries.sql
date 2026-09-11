USE partners_db;

-- 1. Список партнёров, отсортированный по названию и выводом общего количества сделанных ими доставок
SELECT
    p.partner_id,
    pt.name AS partner_type,
    p.name,
    p.inn,
    p.phone,
    p.email,
    p.rating,
    COUNT(d.delivery_id) AS deliveries_count
FROM partners p
JOIN partner_types pt ON pt.partner_type_id = p.partner_type_id
LEFT JOIN deliveries d ON d.partner_id = p.partner_id
GROUP BY p.partner_id, pt.name
ORDER BY p.name;


-- 2. Транзакция: рег + первая доставка
BEGIN;

INSERT INTO partners (partner_type_id, name, director_name, email, phone, inn, legal_address, rating)
VALUES (
    (SELECT partner_type_id FROM partner_types WHERE name = 'ООО'),
    'Рога и Копыта',
    'Сидорова Мария Павловна',
    'info@hornsandhooves.ru',
    '+7800223555',
    '7702345678',
    '101000, г. Москва, ул. Пушкина, 5',
    4.5
);

SET @new_partner_id = LAST_INSERT_ID();

INSERT INTO deliveries (partner_id, product_id, quantity, delivery_date, total_amount)
VALUES (
    @new_partner_id,
    (SELECT product_id FROM products WHERE name = 'Кондиционер для белья'),
    20,
    CURRENT_DATE,
    7000.00          
);

COMMIT;

-- 3. История отгрузок конкретного партнёра за период

SET @partner_id = 1;
SET @date_from  = '2026-03-01';
SET @date_to    = '2026-03-31';

SELECT
    p.name           AS partner,
    d.delivery_date,
    pr.name          AS product,
    d.quantity,
    d.total_amount,
    SUM(d.total_amount) OVER () AS period_total   
FROM deliveries d
JOIN partners p  ON p.partner_id  = d.partner_id
JOIN products pr ON pr.product_id = d.product_id
WHERE d.partner_id = @partner_id
  AND d.delivery_date BETWEEN @date_from AND @date_to
ORDER BY d.delivery_date;