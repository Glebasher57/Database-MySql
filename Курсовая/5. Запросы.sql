-- 1. Вывод id заказа, id пользователя, кол-ва продуктов в заказе, способ оплаты 
-- названия метода доставки и его ид, название сервиса и его ид.

SELECT o.id AS order_id,
  u.id AS user_id,
  COUNT(op.order_id) AS products_amount,
  pt.name AS payment_type,
  dm.name AS delivery_method,
  dm.id AS dm_id,
  ds.name AS delivery_service,
  ds.id AS ds_id 
  FROM users u
    JOIN delivery_services ds    -- Пункты выдачи/службы доставки
    JOIN delivery_methods dm     -- способы доставки
    JOIN payment_types pt
    JOIN orders o
      ON o.user_id = u.id
        AND o.payment_type_id = pt.id
    JOIN orders_products op      -- продукты в заказе
      ON op.order_id = o.id
    JOIN orders_delivery od      -- способ доставки заказа 
      ON od.delivery_method_id = dm.id 
        AND od.delivery_service_id = ds.id
        AND od.order_id = o.id
    GROUP BY o.id
    ORDER BY o.id;

-- вариант с окном

SELECT DISTINCT o.id AS order_id,
  u.id AS user_id,
  COUNT(op.order_id) OVER w AS products_amount,
  pt.name AS payment_type,
  dm.name AS delivery_method,
  dm.id AS dm_id,
  ds.name AS delivery_service,
  ds.id AS ds_id 
  FROM users u
    JOIN delivery_services ds    -- Пункты выдачи/службы доставки
    JOIN delivery_methods dm     -- способы доставки
    JOIN payment_types pt
    JOIN orders o
      ON o.user_id = u.id
        AND o.payment_type_id = pt.id
    JOIN orders_products op      -- продукты в заказе
      ON op.order_id = o.id
    JOIN orders_delivery od      -- способ доставки заказа 
      ON od.delivery_method_id = dm.id 
        AND od.delivery_service_id = ds.id
        AND od.order_id = o.id
    WINDOW w AS (PARTITION BY o.id)
    ORDER BY o.id;

-- При проверке, из-за рандомного заполнения значений таблиц, у некоторых пользователей получились заказы без товаров,
--  и поэтому такие заказы в выборку не попадут. По идее в реальности все должно быть верно.

-- 2. Подсчет конечной стоимости товара включая стоимость товара, скидку пользователя, стоимость свойства товара.

SELECT DISTINCT 
    o.id AS order_id,                             -- id заказа
    prof.user_id AS user_id,                      -- id пользователя
    d.discount AS discount,                       -- скидка
    COUNT(p.id) AS amount_products,               -- кол-во товаров
    SUM(p.price) AS price,                        -- стоимость товаров без скидки и учета свойств
    SUM(pp.property_price) AS properties_price,   -- стоимость свойств товаров
    (SUM(p.price) + SUM(pp.property_price)) * d.discount AS total_price -- итог
  FROM profiles prof
    JOIN products p
    JOIN orders o
      ON o.user_id = prof.user_id
    JOIN orders_products op                       -- товары в заказе
      ON op.order_id = o.id
        AND op.product_id = p.id
    JOIN discounts d                              -- скидки
      ON d.id = prof.discount_id
    JOIN product_properties pp                    -- свойства товара
      ON pp.product_id = p.id
        WHERE IF(pp.property_price IS NULL, 0, pp.property_price)
      GROUP BY o.id
      ORDER BY prof.user_id;