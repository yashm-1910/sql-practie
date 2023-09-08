-- tables
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(100),  
    phone_number VARCHAR(15),
    address TEXT
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(100),  
    phone_number VARCHAR(15),
    address TEXT,
    hire_date DATE,
    job_title VARCHAR(50),
    salary DECIMAL(10, 2)
);

CREATE TABLE product_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    description TEXT,
    price DECIMAL(10, 2),  
    category_id INT REFERENCES product_categories(category_id),
    stock_quantity INT
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date TIMESTAMP,
    total_amount DECIMAL(10, 2)  
);

CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    item_price DECIMAL(10, 2)  
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    payment_date TIMESTAMP,
    payment_amount DECIMAL(10, 2),
    payment_method VARCHAR(50)
);

CREATE TABLE product_reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    customer_id INT REFERENCES customers(customer_id),
    review_text TEXT,
    review_date TIMESTAMP
);

CREATE TABLE shipping_info (
    shipping_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    ship_date TIMESTAMP,
    ship_address TEXT,
    ship_status VARCHAR(50)
);





-- Sample data
INSERT INTO customers (first_name, last_name, email, password, phone_number, address)
VALUES
    ('John', 'Doe', 'john.doe@example.com', 'password1', '+1234567890', '123 Main St'),
    ('Jane', 'Smith', 'jane.smith@example.com', 'password2', '+9876543210', '456 Elm St'),
    ('Alice', 'Johnson', 'alice.johnson@example.com', 'password3', '+1112223333', '789 Oak Ave');

INSERT INTO employees (first_name, last_name, email, password, phone_number, address, hire_date, job_title, salary)
VALUES
    ('David', 'Johnson', 'david.johnson@example.com', 'employee1pass', '+5555555555', '101 Employee St', '2022-01-15', 'Manager', 60000.00),
    ('Sarah', 'Wilson', 'sarah.wilson@example.com', 'employee2pass', '+4444444444', '202 Employee St', '2022-02-20', 'Sales Associate', 45000.00),
    ('Michael', 'Lee', 'michael.lee@example.com', 'employee3pass', '+3333333333', '303 Employee St', '2022-03-25', 'Warehouse Clerk', 35000.00);


INSERT INTO product_categories (category_name)
VALUES
    ('Electronics'),
    ('Clothing'),
    ('Books'),
    ('Home & Garden');

INSERT INTO products (product_name, description, price, category_id, stock_quantity)
VALUES
    ('Smartphone', 'High-end smartphone', 599.99, 1, 100),
    ('Laptop', 'Powerful laptop', 999.99, 1, 50),
    ('T-Shirt', 'Cotton T-shirt', 19.99, 2, 200),
    ('Jeans', 'Slim-fit jeans', 49.99, 2, 150),
    ('Book 1', 'Bestseller book', 29.99, 3, 300),
    ('Book 2', 'Sci-fi novel', 19.99, 3, 200),
    ('Garden Tools', 'Set of gardening tools', 79.99, 4, 50);




INSERT INTO orders (customer_id, total_amount)
VALUES
    (1, 719.98),
    (2, 139.98),
    (3, 49.99),
    (1, 29.99);

INSERT INTO order_items (order_id, product_id, quantity, item_price)
VALUES
    (1, 1, 1, 599.99),
    (2, 3, 2, 39.98),
    (2, 4, 1, 49.99),
    (3, 5, 1, 29.99),
    (4, 7, 1, 79.99);


INSERT INTO payments (order_id, payment_amount, payment_method)
VALUES
    (1, 719.98, 'Credit Card'),
    (2, 139.98, 'PayPal'),
    (3, 49.99, 'Credit Card'),
    (4, 29.99, 'Stripe');

INSERT INTO product_reviews (product_id, customer_id, review_text)
VALUES
    (1, 1, 'Great smartphone!'),
    (2, 2, 'Excellent laptop for work.'),
    (3, 3, 'Comfy T-shirt.'),
    (4, 1, 'Perfect fit!'),
    (5, 2, 'Awesome book!');



INSERT INTO shipping_info (order_id, ship_date, ship_address, ship_status)
VALUES
    (1, '2023-08-05', '123 Main St', 'Shipped'),
    (2, '2023-08-06', '456 Elm St', 'Shipped'),
    (3, '2023-08-07', '789 Oak Ave', 'Shipped'),
    (4, '2023-08-08', '123 Main St', 'Shipped');



-- queries

SELECT * FROM customers;



-- retrieve top-selling products
SELECT p.product_name, SUM(o.quantity) AS total_quantity
FROM products p
JOIN order_items o ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 5;

-- running total of order amounts
SELECT order_id, order_date, total_amount,
       SUM(total_amount) OVER (ORDER BY order_date) AS running_total
FROM orders
ORDER BY order_date;


-- retrieve orders by a specific customer 
SELECT o.order_id, o.order_date, SUM(oi.quantity * oi.item_price) AS order_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = 1
GROUP BY o.order_id, o.order_date
ORDER BY o.order_date;


-- calculate total revenue

SELECT SUM(oi.quantity * oi.item_price) AS total_revenue
FROM order_items oi;


-- find products with low stock
SELECT product_name, stock_quantity
FROM products
WHERE stock_quantity < 10;

-- get product reviews

SELECT p.product_name, pr.review_text
FROM product_reviews pr
JOIN products p ON pr.product_id = p.product_id;


 -- calculate average salary for employees
SELECT AVG(salary) AS average_salary
FROM employees;

-- find orders shipping status
SELECT o.order_id, o.order_date, s.ship_status
FROM orders o
JOIN shipping_info s ON o.order_id = s.order_id
WHERE s.ship_status = 'Shipped';

-- find products with lowest stock by category
SELECT pc.category_name, product_name, stock_quantity
FROM products p
JOIN product_categories pc ON p.category_id = pc.category_id
WHERE stock_quantity = (
    SELECT MIN(stock_quantity)
    FROM products
    WHERE category_id = p.category_id
);

-- calculate total revenue by category
SELECT pc.category_name, SUM(oi.quantity * oi.item_price) AS category_revenue
FROM products p
JOIN product_categories pc ON p.category_id = pc.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY pc.category_name;


-- find categories with high revenue
SELECT pc.category_name, SUM(oi.quantity * oi.item_price) AS category_revenue
FROM products p
JOIN product_categories pc ON p.category_id = pc.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY pc.category_name
HAVING SUM(oi.quantity * oi.item_price) > 10000;


-- rank customers by total spending
SELECT customer_id, total_spending,
       RANK() OVER (ORDER BY total_spending DESC) AS customer_rank
FROM (
    SELECT customer_id, SUM(total_amount) AS total_spending
    FROM orders
    GROUP BY customer_id
) AS customer_spending;


-- find the total sales amount for each product category and the top-selling product in each category

WITH CategorySales AS (
-- to calculate total sales per category
    SELECT
        pc.category_name,
        p.product_name,
        SUM(oi.quantity * oi.item_price) AS total_sales
    FROM
        product_categories pc
    JOIN
        products p ON pc.category_id = p.category_id
    JOIN
        order_items oi ON p.product_id = oi.product_id
    GROUP BY
        pc.category_name, p.product_name
),
RankCategorySales AS (
-- to rank products by sales within each category
    SELECT
        cs.*,
        RANK() OVER (PARTITION BY cs.category_name ORDER BY cs.total_sales DESC) AS sales_rank
    FROM
        CategorySales cs
)
-- main query
SELECT
    rcs.category_name,
    rcs.product_name AS top_selling_product,
    rcs.total_sales
FROM
    RankCategorySales rcs
WHERE
    rcs.sales_rank = 1;


