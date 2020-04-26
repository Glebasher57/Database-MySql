-- Информация о заказах

CREATE VIEW orders_info AS
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

-- 