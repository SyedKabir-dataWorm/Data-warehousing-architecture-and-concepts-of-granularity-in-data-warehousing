
-- Understanding MONSTORE database and tables
/*
select * from MONSTORE.ordertable order by customer_id;
select * from MONSTORE.product;
select * from MONSTORE.order_items;
select * from MONSTORE.customer; 
DESCRIBE MONSTORE.product;

select product_id, list_price from MONSTORE.product order by product_id, list_price;
*/


----------------------------------------Version-1----------------------------
DROP TABLE ordertimedim1;

DROP TABLE customerlocationdim1;

DROP TABLE customeragegroupdim1;

DROP TABLE companydim1;

DROP TABLE storedim1;

DROP TABLE categoryofproductdim1;

DROP TABLE typeofstaffdim1;

DROP TABLE staffworkdurationdim1;

DROP TABLE productgrouplistdim1;

DROP TABLE productgroupcompanybridge1;

DROP TABLE tempstafffact1;

DROP TABLE stafffact1;

DROP TABLE productorderpricefact1;

DROP TABLE temporderfact1;

DROP TABLE orderfact1;

--------------CREATING DIMENSION TABLES---------------------------

-- Creating the dimesion related to order time period (by quarter) 
-- named as OrderTimeDim1
CREATE TABLE ordertimedim1 (
    quarter     NUMBER(1),
    description VARCHAR2(20)
);

INSERT INTO ordertimedim1 VALUES (
    1,
    'Jan-Mar'
);

INSERT INTO ordertimedim1 VALUES (
    2,
    'Apr-Jun'
);

INSERT INTO ordertimedim1 VALUES (
    3,
    'Jul-Sep'
);

INSERT INTO ordertimedim1 VALUES (
    4,
    'Oct-Dec'
);

SELECT
    *
FROM
    ordertimedim1;

-- Creating the dimesion related to customer's location 
-- named as CustomerLocationDim1
CREATE TABLE customerlocationdim1
    AS
        SELECT DISTINCT
            suburb
        FROM
            monstore.customer;

SELECT
    *
FROM
    customerlocationdim1;

-- Creating the dimesion related to customer's Age Group
-- named as CustomerAgeGroupDim1

CREATE TABLE customeragegroupdim1 (
    age_group_id          NUMBER(1),
    age_group_description VARCHAR2(50)
);

INSERT INTO customeragegroupdim1 VALUES (
    1,
    'Early-aged adults (18-40 years old)'
);

INSERT INTO customeragegroupdim1 VALUES (
    2,
    'Middle-aged adults (41-59 years old)'
);

INSERT INTO customeragegroupdim1 VALUES (
    3,
    'Old-aged adults (over 60 years old)'
);

SELECT
    *
FROM
    customeragegroupdim1;

-- Creating the dimesion related to store 
-- named as StoreDim1

CREATE TABLE storedim1
    AS
        SELECT DISTINCT
            store_id,
            store_name
        FROM
            monstore.store;

SELECT
    *
FROM
    storedim1;

-- Creating the dimesion related to category of product
-- named as CategoryOfProductDim1

CREATE TABLE categoryofproductdim1
    AS
        SELECT
            *
        FROM
            monstore.product_category;

SELECT
    *
FROM
    categoryofproductdim1;

-- Creating the dimesion related to type of staff
-- named as TypeOfStaffDim1

CREATE TABLE typeofstaffdim1 (
    staff_type             VARCHAR2(10),
    staff_type_description VARCHAR2(100)
);

INSERT INTO typeofstaffdim1 VALUES (
    'Part_time',
    'less than 20 working hours per week'
);

INSERT INTO typeofstaffdim1 VALUES (
    'Full_time',
    'more than 20 working hours per week'
);

SELECT
    *
FROM
    typeofstaffdim1;

-- Creating the dimesion related to staff working duration
-- named as StaffWorkDurationDim1
CREATE TABLE staffworkdurationdim1 (
    work_duration_type        VARCHAR2(20),
    work_duration_description VARCHAR2(50)
);

INSERT INTO staffworkdurationdim1 VALUES (
    'new beginner',
    'less than 3 years, inclusive'
);

INSERT INTO staffworkdurationdim1 VALUES (
    'mid-level',
    'more than 3 years'
);

SELECT
    *
FROM
    staffworkdurationdim1;


-- Creating the dimesion related to company name
-- named as CompanyDim1

CREATE TABLE companydim1
    AS
        SELECT DISTINCT
            company_id,
            company_name
        FROM
            monstore.company;

SELECT
    *
FROM
    companydim1;

/*
-- Creating the dimesion related to product
-- named as ProductDim1
create table ProductDim1 as
select p.product_id,
round(1.0/count(C.Company_id),2) as WeightFactor,
listagg (C.Company_id, '_') within group
(order by C.Company_id) as StoreGroupList
from monstore.Product P,  MONSTORE.product_company C
where P.product_ID = C.product_ID
group by P.product_ID;

select * from ProductDim1;

-- Creating the dimesion related to a bridge table
-- named as ProductCompanyBridge1
create table ProductCompanyBridge1 as
select * from MONSTORE.product_company;

select * from ProductCompanyBridge1;
*/
CREATE TABLE productgroupdimtemp1
    AS
        SELECT DISTINCT
            ot.order_id,
            ot.product_id,
            round(1.0 / COUNT(c.company_id), 2) AS weightfactor,
            LISTAGG(c.company_id, '_') WITHIN GROUP(
            ORDER BY
                c.company_id
            )                                   AS storegrouplist
        FROM
            monstore.product         p,
            monstore.order_items     ot,
            monstore.product_company c
        WHERE
                ot.product_id = p.product_id
            AND p.product_id = c.product_id
        GROUP BY
            ot.product_id,
            ot.order_id;

DROP TABLE productgrouplistdim1;

CREATE TABLE productgrouplistdim1
    AS
        SELECT DISTINCT
            LISTAGG(product_id, '_') WITHIN GROUP(
            ORDER BY
                order_id
            ) AS productgrouplistid,
            weightfactor,
            storegrouplist
        FROM
            productgroupdimtemp1
        GROUP BY
            order_id,
            weightfactor,
            storegrouplist;

SELECT
    *
FROM
    productgrouplistdim1;

-- Creating the dimesion related to a bridge table
-- named as ProductCompanyBridge1

DROP TABLE productgroupcompanybridge1;

CREATE TABLE productgroupcompanybridge1
    AS
        SELECT DISTINCT
            p.productgrouplistid,
            c.company_id
        FROM
            productgrouplistdim1     p,
            monstore.product_company c
        WHERE
            p.productgrouplistid LIKE ( '%'
                                        || c.product_id
                                        || '%' );

SELECT
    *
FROM
    productgroupcompanybridge1;

-- Creating the dimesion related to a order tables
-- named as OrderDim2

-----------------------------------------------------------------
--------------- CREATING FACT TABLES ----------------------------

-- Creating staffFact1 Table

CREATE TABLE tempstafffact1 -- At first, creating TempStaffFact1 table
    AS
        SELECT DISTINCT
            st.store_id,
            s.staff_type,
            s.staff_since
        FROM
            monstore.staff s,
            monstore.store st
        WHERE
            s.store_id = st.store_id;

ALTER TABLE tempstafffact1 ADD (
    work_duration_type VARCHAR2(20)
);

UPDATE tempstafffact1
SET
    work_duration_type = 'new beginner'
WHERE
    ( current_date - staff_since ) / 365 <= 3;

UPDATE tempstafffact1
SET
    work_duration_type = 'mid-level'
WHERE
    ( current_date - staff_since ) / 365 > 3;

CREATE TABLE stafffact1
    AS
        SELECT
            store_id,
            staff_type,
            work_duration_type,
            COUNT(*) AS number_of_staffs
        FROM
            tempstafffact1
        GROUP BY
            staff_type,
            work_duration_type,
            store_id;

SELECT
    *
FROM
    stafffact1;

-- Creating ProductOrderPriceFact table;

CREATE TABLE productorderpricefact1
    AS
        SELECT DISTINCT
            s.store_id,
            p.type_id,
            SUM(o.quantity * o.list_price) AS total_order_price,
            COUNT(p.product_id)            AS number_of_products
        FROM
            monstore.stock       s,
            monstore.product     p,
            monstore.order_items o
        WHERE
                s.product_id = p.product_id
            AND p.product_id = o.product_id
        GROUP BY
            s.store_id,
            p.type_id
        ORDER BY
            s.store_id,
            p.type_id;

SELECT
    *
FROM
    productorderpricefact1;

-- creating OrderFact table

CREATE TABLE temporderfact1
    AS
        SELECT DISTINCT
            s.store_id,
            c.suburb,
            ot.order_id,
            LISTAGG(ot.product_id, '_') WITHIN GROUP(
            ORDER BY
                ot.order_id
            ) AS productgrouplistid,
            o.order_date,
            c.customer_age
        FROM
            monstore.store       s,
            monstore.order_items ot,
            monstore.customer    c,
            monstore.ordertable  o
        WHERE
                s.store_id = o.store_id
            AND ot.order_id = o.order_id
            AND o.customer_id = c.customer_id
        GROUP BY
            s.store_id,
            c.suburb,
            ot.order_id,
            o.order_date,
            c.customer_age;

ALTER TABLE temporderfact1  -- adding quarter attribute in temporderfact1 table

 ADD (
    quarter NUMBER(1)
);

UPDATE temporderfact1
SET
    quarter = 1
WHERE
        to_char(order_date, 'MM') >= '01'
    AND to_char(order_date, 'MM') <= '03';

UPDATE temporderfact1
SET
    quarter = 2
WHERE
        to_char(order_date, 'MM') >= '04'
    AND to_char(order_date, 'MM') <= '06';

UPDATE temporderfact1
SET
    quarter = 3
WHERE
        to_char(order_date, 'MM') >= '07'
    AND to_char(order_date, 'MM') <= '09';

UPDATE temporderfact1
SET
    quarter = 4
WHERE
    quarter IS NULL;

ALTER TABLE temporderfact1  -- adding age_group_id in temporderfact table

 ADD (
    age_group_id VARCHAR2(1)
);

UPDATE temporderfact1
SET
    age_group_id = 1
WHERE
        customer_age >= 18
    AND customer_age <= 40;

UPDATE temporderfact1
SET
    age_group_id = 2
WHERE
        customer_age >= 41
    AND customer_age <= 59;

UPDATE temporderfact1
SET
    age_group_id = 3
WHERE
    customer_age >= 60;



CREATE TABLE orderfact1
    AS  -- Creating  OrderFact table
        SELECT
            store_id,
            order_id,
            suburb,
            productgrouplistid,
            quarter,
            age_group_id,
            COUNT(order_id) AS number_of_orders
        FROM
            temporderfact1
        GROUP BY
            store_id,
            suburb,
            order_id,
            productgrouplistid,
            quarter,
            age_group_id
        ORDER BY
            store_id,
            quarter,
            suburb,
            order_id,
            productgrouplistid,
            age_group_id;

SELECT
    *
FROM
    orderfact1;

