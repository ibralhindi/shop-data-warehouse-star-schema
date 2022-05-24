/*----------------------------- Dimensions*/

/* Suburb Dimension*/
CREATE TABLE suburbdim
    AS
        SELECT DISTINCT
            suburb
        FROM
            monstore.customer;

SELECT
    *
FROM
    suburbdim;

/* Age Dimension*/
CREATE TABLE agedim (
    age_group VARCHAR2(20),
    agerange  VARCHAR2(20)
);

INSERT INTO agedim VALUES (
    'early_age adults',
    '18-40 years old'
);

INSERT INTO agedim VALUES (
    'middle_aged adults',
    '41-59 years old'
);

INSERT INTO agedim VALUES (
    'old_aged adults',
    'over 60 years old'
);

SELECT
    *
FROM
    agedim;

/* Time Dimension*/
CREATE TABLE timedim (
    quarter     NUMBER(1),
    description VARCHAR2(20)
);

INSERT INTO timedim VALUES (
    1,
    'Jan-Mar'
);

INSERT INTO timedim VALUES (
    2,
    'Apr-Jun'
);

INSERT INTO timedim VALUES (
    3,
    'Jul-Sep'
);

INSERT INTO timedim VALUES (
    4,
    'Oct-Dec'
);

SELECT
    *
FROM
    timedim;

/* Store Dimension*/
CREATE TABLE storedim
    AS
        SELECT
            *
        FROM
            monstore.store;

SELECT
    *
FROM
    storedim;

/* Staff Duration Dimension*/
CREATE TABLE staffdurationdim (
    staff_duration      VARCHAR2(20),
    durationdescription VARCHAR2(30)
);

INSERT INTO staffdurationdim VALUES (
    'new beginner',
    'less than 3 years, inclusive'
);

INSERT INTO staffdurationdim VALUES (
    'mid-level',
    'more than 3 years'
);

SELECT
    *
FROM
    staffdurationdim;

/* Staff Type Dimension*/
CREATE TABLE stafftypedim (
    staff_type      VARCHAR2(10),
    typedescription VARCHAR2(40)
);

INSERT INTO stafftypedim VALUES (
    'Part_time',
    'less than 20 working hours per week'
);

INSERT INTO stafftypedim VALUES (
    'Full_time',
    'more than 20 working hours per week'
);

SELECT
    *
FROM
    stafftypedim;

/* Product Category Dimension*/
CREATE TABLE productcategorydim
    AS
        SELECT
            *
        FROM
            monstore.product_category;

SELECT
    *
FROM
    productcategorydim;

/* Product Dimension*/
CREATE TABLE productdim
    AS
        SELECT
            p.product_id,
            product_name,
            list_price,
            model_year,
            type_id,
            round((1 / COUNT(*)), 4) AS weightfactor,
            LISTAGG(company_id, '_') WITHIN GROUP(
            ORDER BY
                company_id
            )                        AS companygrouplist
        FROM
                 monstore.product p
            JOIN monstore.product_company c
            ON p.product_id = c.product_id
        GROUP BY
            p.product_id,
            product_name,
            list_price,
            model_year,
            type_id;

SELECT
    *
FROM
    productdim;

/* Product Company Bridge*/
CREATE TABLE productcompanybridge
    AS
        SELECT
            *
        FROM
            monstore.product_company;

SELECT
    *
FROM
    productcompanybridge;

/* Company Dimension*/
CREATE TABLE companydim
    AS
        SELECT
            *
        FROM
            monstore.company;

SELECT
    *
FROM
    companydim;

/*----------------------------- Facts*/

/* Orders Number Temporary FAct*/
CREATE TABLE ordersnumbertempfact
    AS
        SELECT
            o.store_id,
            order_date,
            suburb,
            customer_age,
            product_id,
            staff_type,
            staff_since
        FROM
                 monstore.ordertable o
            JOIN monstore.customer    c
            ON o.customer_id = c.customer_id
            JOIN monstore.order_items oi
            ON o.order_id = oi.order_id
            JOIN monstore.staff       st
            ON o.staff_id = st.staff_id;

ALTER TABLE ordersnumbertempfact ADD (
    quarter        NUMBER(1),
    age_group      VARCHAR2(20),
    staff_duration VARCHAR2(20)
);

UPDATE ordersnumbertempfact
SET
    quarter =
        CASE
            WHEN to_char(order_date, 'Q') = '1' THEN
                1
            WHEN to_char(order_date, 'Q') = '2' THEN
                2
            WHEN to_char(order_date, 'Q') = '3' THEN
                3
            ELSE
                4
        END,
    age_group =
        CASE
            WHEN customer_age BETWEEN 18 AND 40 THEN
                'early_age adults'
            WHEN customer_age BETWEEN 41 AND 59 THEN
                'middle_aged adults'
            ELSE
                'old_aged adults'
        END,
    staff_duration =
        CASE
            WHEN floor(months_between(sysdate, staff_since) / 12) <= 3 THEN
                'new beginner'
            ELSE
                'mid-level'
        END;

SELECT
    *
FROM
    ordersnumbertempfact;

/* Orders Number Fact version-1*/
CREATE TABLE ordersnumberfact_v1
    AS
        SELECT
            store_id,
            suburb,
            product_id,
            staff_type,
            quarter,
            age_group,
            staff_duration,
            COUNT(*) AS number_of_orders
        FROM
            ordersnumbertempfact
        GROUP BY
            store_id,
            suburb,
            product_id,
            staff_type,
            quarter,
            age_group,
            staff_duration;

SELECT
    *
FROM
    ordersnumberfact_v1;

/* Order Price Temporary Fact*/
CREATE TABLE orderpricetempfact
    AS
        SELECT
            type_id,
            o.store_id,
            order_date,
            suburb,
            customer_age,
            staff_type,
            staff_since,
            quantity,
            oi.list_price
        FROM
                 monstore.ordertable o
            JOIN monstore.customer    c
            ON o.customer_id = c.customer_id
            JOIN monstore.order_items oi
            ON o.order_id = oi.order_id
            JOIN monstore.product     p
            ON oi.product_id = p.product_id
            JOIN monstore.staff       st
            ON o.staff_id = st.staff_id;

ALTER TABLE orderpricetempfact ADD (
    quarter        NUMBER(1),
    age_group      VARCHAR2(20),
    staff_duration VARCHAR2(20)
);

UPDATE orderpricetempfact
SET
    quarter =
        CASE
            WHEN to_char(order_date, 'Q') = '1' THEN
                1
            WHEN to_char(order_date, 'Q') = '2' THEN
                2
            WHEN to_char(order_date, 'Q') = '3' THEN
                3
            ELSE
                4
        END,
    age_group =
        CASE
            WHEN customer_age BETWEEN 18 AND 40 THEN
                'early_age adults'
            WHEN customer_age BETWEEN 41 AND 59 THEN
                'middle_aged adults'
            ELSE
                'old_aged adults'
        END,
    staff_duration =
        CASE
            WHEN floor(months_between(sysdate, staff_since) / 12) <= 3 THEN
                'new beginner'
            ELSE
                'mid-level'
        END;

SELECT
    *
FROM
    orderpricetempfact;

/* Order Price Fact Version-1*/
CREATE TABLE orderpricefact_v1
    AS
        SELECT
            type_id,
            store_id,
            quarter,
            suburb,
            age_group,
            staff_duration,
            staff_type,
            SUM(quantity * list_price) AS total_order_price
        FROM
            orderpricetempfact
        GROUP BY
            type_id,
            store_id,
            quarter,
            suburb,
            age_group,
            staff_duration,
            staff_type;

SELECT
    *
FROM
    orderpricefact_v1;

/* Staff Temporary Fact*/
CREATE TABLE stafftempfact
    AS
        SELECT
            store_id,
            staff_type,
            staff_since
        FROM
            monstore.staff;

ALTER TABLE stafftempfact ADD (
    staff_duration VARCHAR2(20)
);

UPDATE stafftempfact
SET
    staff_duration =
        CASE
            WHEN floor(months_between(sysdate, staff_since) / 12) <= 3 THEN
                'new beginner'
            ELSE
                'mid-level'
        END;

SELECT
    *
FROM
    stafftempfact;

/* Staff Fact Version-1*/
CREATE TABLE stafffact_v1
    AS
        SELECT
            store_id,
            staff_type,
            staff_duration,
            COUNT(*) AS number_of_staff
        FROM
            stafftempfact
        GROUP BY
            store_id,
            staff_type,
            staff_duration;

SELECT
    *
FROM
    stafffact_v1;

/* Products Fact Version-1*/
CREATE TABLE productsfact_v1
    AS
        SELECT
            store_id,
            type_id,
            COUNT(*) AS number_of_products
        FROM
                 monstore.stock s
            JOIN monstore.product p
            ON s.product_id = p.product_id
        GROUP BY
            store_id,
            type_id;

SELECT
    *
FROM
    productsfact_v1;