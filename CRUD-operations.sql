/* CRUD OPERATIONS */

---- Create Operations
INSERT INTO category (category_id, name, description) VALUES
(1, 'Entrees', 'Start your meal with our delicious entrees'),
(2, 'Side Dishes', 'Complement your main course with a side dish'),
(3, 'Desserts', 'End your meal on a sweet note with our desserts'),
(4, 'Beverages', 'Refresh yourself with our selection of beverages');

INSERT INTO menu (menu_item_id, category_id, name, description, price, is_available) VALUES
(1, 1, 'Grilled Chicken', 'Juicy grilled chicken served with seasonal vegetables', 12.99, TRUE),
(2, 1, 'Spicy Chicken Wrap', 'Grilled chicken, pepper jack, spicy ranch sauce', 12.50, TRUE),
(3, 1, 'Pasta Salad', 'Pasta with fresh vegetables and Italian dressing', 8.99, TRUE),
(4, 2, 'French Fries', 'Classic cut fries, salted', 4.50, TRUE),
(5, 2, 'Caesar Salad', 'Crisp romaine lettuce with Caesar dressing and croutons', 6.99, TRUE),
(6, 3, 'Chocolate Lava Cake', 'Warm chocolate cake with a gooey center', 5.99, TRUE),
(7, 3, 'Cheesecake', 'Creamy cheesecake with a graham cracker crust', 6.50, TRUE),
(8, 4, 'Lemonade', 'Freshly squeezed lemonade', 2.99, TRUE),
(9, 4, 'Iced Tea', 'Brewed iced tea with a hint of lemon', 2.50, TRUE);

SELECT * FROM category;
SELECT * FROM menu;

---- Update Operations
UPDATE menu
SET price = 3.50
WHERE menu_item_id = 4;

SELECT menu_item_id, name, price
FROM menu 
WHERE menu_item_id = 4;

UPDATE menu
SET price = price + 1.00
WHERE category_id = 4;

SELECT menu_item_id, name, price
FROM menu 
WHERE category_id = 4;

-- Remove Discontinued dishes

DELETE FROM menu
WHERE menu_item_id = 3;

SELECT * FROM menu;

DELETE FROM menu
WHERE menu_item_id = 8;

SELECT * FROM menu;

-- Place New orders with multiple items

INSERT INTO role (role_id, name, description) VALUES
(1, 'Cashier', 'Handles customer orders and payments'),
(2, 'Delivery Driver', 'Delivers orders to customers'),
(3, 'Manager', 'Oversees restaurant operations'),
(4, 'Chef', 'Prepares food orders in the kitchen');

INSERT INTO employee (employee_id, role_id, first_name, last_name, email, phone, hire_date, active) VALUES
(1, 1, 'Kant', 'Logan', 'kant.logan@example.com', '555-551-5678', '2021-09-01', TRUE);

INSERT INTO customer (customer_id, first_name, last_name, email, phone, created_at) VALUES
(1, 'Janet', 'Murphy', 'janet.murphy@example.com', '555-621-1234', NOW());

INSERT INTO address (address_id, customer_id, street, city, postal_code, notes, is_default) VALUES
(1, 1, '123 Portland St', 'Sherbrooke', 'H2X 1Y4', 'Leave at front door', TRUE);

INSERT INTO `order` (order_id, customer_id, cashier_id, delivery_address_id, order_datetime, status, payment_method, payment_status, total_amount) VALUES
(1234, 1, 1, 1, NOW(), 'PENDING', 'ONLINE', 'UNPAID', 25.48);


INSERT INTO order_item (order_id, menu_item_id, quantity, unit_price, line_total) VALUES
(1234, 1, 3, 12.99, 38.97),
(1234, 4, 5, 4.50, 22.50),
(1234, 6, 1, 5.99, 5.99);

UPDATE `order`
SET total_amount = (
    SELECT SUM(line_total)
    FROM order_item
    WHERE order_id = 1234
)
WHERE order_id = 1234;

SELECT * FROM `order` WHERE order_id = 1234;

-- Assign a delivery driver

INSERT INTO employee (employee_id, role_id, first_name, last_name, email, phone, hire_date, active) VALUES
(2, 2, 'Derek', 'Smith', 'derek.smith@restaurant.com', '555-554-6789', '2023-06-01', TRUE);

INSERT INTO delivery (delivery_id, order_id, driver_id, assigned_time, delivery_status) VALUES
(1, 1234, 2, NOW(), 'ASSIGNED');

SELECT * FROM delivery WHERE order_id = 1234;

-- Update Order Status

UPDATE `order`
SET status = 'PREPARING'
WHERE order_id = 1234;

UPDATE `order`
SET status = 'OUT_FOR_DELIVERY'
WHERE order_id = 1234;

UPDATE `order`
SET status = 'DELIVERED', payment_status = 'PAID'
WHERE order_id = 1234;

SELECT order_id, status, payment_status
FROM `order`
WHERE order_id = 1234;

-- List sales per day or per category

SELECT DATE(order_datetime) AS sales_day,
         SUM(total_amount) AS total_sales
FROM `order`
WHERE status = 'DELIVERED'
GROUP BY sales_day
ORDER BY sales_day DESC;

SELECT c.name AS category_name,
         SUM(oi.line_total) AS total_sales
FROM order_item oi
JOIN menu m ON oi.menu_item_id = m.menu_item_id
JOIN category c ON m.category_id = c.category_id
JOIN `order` o ON oi.order_id = o.order_id
WHERE o.status = 'DELIVERED'
GROUP BY c.category_id, c.name
ORDER BY total_sales DESC;

-- Delete an order

DELETE
FROM order_item
WHERE order_id = 2244;

DELETE
FROM `order`
WHERE order_id = 2244 AND status = 'CANCELLED';