CREATE USER 'cashier_user'@'localhost' IDENTIFIED BY 'Cashier123';
CREATE USER 'cook_user'@'localhost' IDENTIFIED BY 'Cook123';
CREATE USER 'manager_user'@'localhost' IDENTIFIED BY 'Manager123';

GRANT SELECT ON db_restaurant.menu TO 'cashier_user'@'localhost';
GRANT SELECT ON db_restaurant.category TO 'cashier_user'@'localhost';
GRANT SELECT, INSERT ON db_restaurant.customer TO 'cashier_user'@'localhost';
GRANT SELECT, INSERT ON db_restaurant.`order` TO 'cashier_user'@'localhost';
GRANT SELECT, INSERT ON db_restaurant.order_item TO 'cashier_user'@'localhost';


GRANT SELECT ON db_restaurant.`order` TO 'cook_user'@'localhost';
GRANT UPDATE (status) ON db_restaurant.`order` TO 'cook_user'@'localhost';

GRANT ALL PRIVILEGES ON db_restaurant.* TO 'manager_user'@'localhost';

SHOW GRANTS FOR 'cashier_user'@'localhost';
SHOW GRANTS FOR 'cook_user'@'localhost';
SHOW GRANTS FOR 'manager_user'@'localhost';