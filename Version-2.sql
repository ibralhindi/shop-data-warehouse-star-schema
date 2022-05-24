/*----------------------------- Dimensions*/            
            
/* Order Dimension*/
CREATE TABLE orderdim
    AS
        SELECT
            order_id,
            order_statuts AS order_status,
            order_date,
            ship_duration,
            shipped_date
        FROM
            monstore.ordertable;

SELECT
    *
FROM
    orderdim;

/* Customer Dimension*/
CREATE TABLE customerdim
    AS
        SELECT
            *
        FROM
            monstore.customer;

SELECT
    *
FROM
    customerdim;

/* Staff Dimension*/
CREATE TABLE staffdim
    AS
        SELECT
            staff_id,
            staff_name,
            staff_since,
            staff_type
        FROM
            monstore.staff;

SELECT
    *
FROM
    staffdim;

/*----------------------------- Facts*/ 
/* Orders Number Fact Version-2*/
CREATE TABLE ordersnumberfact_v2
    AS
        SELECT
            o.order_id,
            product_id,
            store_id,
            staff_id,
            customer_id,
            COUNT(*) AS number_of_orders
        FROM
                 monstore.ordertable o
            JOIN monstore.order_items oi
            ON o.order_id = oi.order_id
        GROUP BY
            o.order_id,
            product_id,
            store_id,
            staff_id,
            customer_id;

SELECT
    *
FROM
    ordersnumberfact_v2;

/* Order Price Fact Version-2*/
CREATE TABLE orderpricefact_v2
    AS
        SELECT
            o.order_id,
            p.product_id,
            type_id,
            store_id,
            staff_id,
            customer_id,
            SUM(quantity * oi.list_price) AS total_order_price
        FROM
                 monstore.ordertable o
            JOIN monstore.order_items oi
            ON o.order_id = oi.order_id
            JOIN monstore.product     p
            ON oi.product_id = p.product_id
        GROUP BY
            o.order_id,
            p.product_id,
            type_id,
            store_id,
            staff_id,
            customer_id;

SELECT
    *
FROM
    orderpricefact_v2;
    
/* Staff Fact Version-2*/
CREATE TABLE stafffact_v2
    AS
        SELECT
            staff_id,
            store_id,
            COUNT(*) AS number_of_staff
        FROM
            monstore.staff
        GROUP BY
            staff_id,
            store_id;

SELECT
    *
FROM
    stafffact_v2;

/* Products Fact Version-2*/
CREATE TABLE productsfact_v2
    AS
        SELECT
            store_id,
            p.product_id,
            type_id,
            COUNT(*) AS number_of_products
        FROM
                 monstore.stock s
            JOIN monstore.product p
            ON s.product_id = p.product_id
        GROUP BY
            store_id,
            p.product_id,
            type_id;

SELECT
    *
FROM
    productsfact_v2;