-- Stored Procedures & Automated Operations

-- 1- Calculate total order price (Functions)

DELIMITER $$
CREATE FUNCTION sf_calculate_total_order_price(p_order_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

    DECLARE total DECIMAL(10,2);
    SELECT SUM(line_total) INTO total
    FROM order_item
    WHERE order_id = p_order_id;

    RETURN IFNULL(total,0);
END$$
DELIMITER ;

-- Test the function
SELECT sf_calculate_total_order_price(1234) AS total_price;

-- 2- Mark order as delivered and timestamp it (Procedure)

DELIMITER $$
CREATE PROCEDURE sp_mark_order_delivered(IN p_order_id INT)
BEGIN
    UPDATE delivery
    SET delivered_time = NOW(),
        delivery_status = 'DELIVERED'
    WHERE order_id = p_order_id;

    UPDATE `order`
    SET status = 'DELIVERED'
    WHERE order_id = p_order_id;
END$$
DELIMITER ;

-- Test the procedure
CALL sp_mark_order_delivered(1234);

-- 3- Validate if an order can be cancelled (Procedure)

DELIMITER $$
CREATE PROCEDURE sp_validate_cancelled_order(IN p_order_id INT)
BEGIN
    DECLARE current_status VARCHAR(20);

    SELECT status INTO current_status
    FROM `order`
    WHERE order_id = p_order_id;

    IF current_status  = 'PENDING' OR current_status = 'PREPARING' THEN
        UPDATE `order`
        SET status = 'CANCELLED'
        WHERE order_id = p_order_id;

        SELECT 'Order has been successfully cancelled.' AS MESSAGE;
    ELSE
        SELECT CONCAT('Order cannot be cancelled at this stage. Current status: ', current_status) AS MESSAGE;
    END IF;
END$$
DELIMITER ;

-- Test the procedure
CALL sp_validate_cancelled_order(1234);

-- Triggers

-- 1- Automatically update inventory when an item is ordered

DELIMITER $$
CREATE TRIGGER tr_reduce_inventory_after_order
AFTER INSERT ON order_item
FOR EACH ROW
BEGIN
    UPDATE inventory i
    JOIN menu_item_ingreddient mii ON i.inventory_item_id = mii.inventory_item_id
    SET i_current_quantity = i.current_quantity - (mii.quantity_per_unit * NEW.quantity)
    WHERE mii.menu_item_id = NEW.menu_item_id;
END$$
DELIMITER ;

-- Test the trigger by placing a new order
INSERT INTO customer (customer_id, first_name, last_name, email, phone, created_at) VALUES
(2, 'Alice', 'Johnson', 'alice.johnson@example.com', '555-555-1234', NOW());

INSERT INTO address (address_id, customer_id, street, city, postal_code, notes, is_default) VALUES
(2, 2, '456 Maple Street', 'Springfield', '12345', 'Ring the doorbell', TRUE);

INSERT INTO `order` (order_id, customer_id, cashier_id, delivery_address_id, order_datetime, status, payment_method, payment_status, total_amount) VALUES
(2244, 2, 1, 2, NOW(), 'PENDING', 'CARD', 'UNPAID', 15.49);

INSERT INTO order_item (order_id, menu_item_id, quantity, unit_price, line_total) VALUES
(2244, 2, 3, 12.50, 37.50);

SELECT * FROM inventory;

-- 2 - Prevent deletion of a menu item that is used in existing orders

DELIMITER $$
CREATE TRIGGER tr_menu_delete
BEFORE DELETE ON menu
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM order_item
        WHERE menu_item_id = OLD.menu_item_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete menu item as it is associated with existing orders.';
    END IF;
END$$
DELIMITER ;

-- Test the trigger by attempting to delete a menu item used in an order

DELETE FROM menu
WHERE menu_item_id = 1;