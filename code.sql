
-- Understanding MONSTORE database and it's tables
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
/*

-- This is wrong 

create table TempOrderFact1 as  -- Initially creating a temporary fact table
select distinct S.store_id, C.suburb, O.order_id, 
P.product_ID, ot.order_date, c.customer_age
from MONSTORE.store S, MONSTORE.product P, MONSTORE.order_items O, 
MONSTORE.customer C, MONSTORE.ordertable OT
where s.store_id = ot.store_id and
p.product_id = o.product_id and 
o.order_id = ot.order_id and
ot.customer_id = c.customer_id;
*/

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

/*
-- This is wrong table

create table OrderFact1 as  -- Creating  OrderFact table
select store_id, order_id, suburb, product_id, quarter, age_group_id,
count(order_id) as number_of_orders
from TempOrderFact1
group by store_id, suburb, order_id,product_id, quarter, age_group_id
order by store_id, quarter, suburb, order_id, product_id,  age_group_id;
*/

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

--------------------------------------------------------------------------
-------------------------Queries------------------------------------------
/* Q.1: How many orders were placed in store one during quarter 1 and 
ordered by the customer(s) from Marion?*/

SELECT
    store_id,
    quarter,
    suburb,
    SUM(number_of_orders)
FROM
    orderfact1
WHERE
        lower(store_id) = 'store1'
    AND quarter = 1
    AND lower(suburb) = 'marion'
GROUP BY
    store_id,
    quarter,
    suburb;

/* Q.2: How many orders were placed by each customer age group? */

SELECT
    o.age_group_id,
    c.age_group_description,
    SUM(number_of_orders)
FROM
    orderfact1           o,
    customeragegroupdim1 c
WHERE
    o.age_group_id = c.age_group_id
GROUP BY
    o.age_group_id,
    c.age_group_description
ORDER BY
    age_group_id;

/* Q.3: How many orders were placed that include at least one product 
supplied by Company07? */

SELECT
    b.company_id,
    SUM(o.number_of_orders) AS total_orders
FROM
    orderfact1                 o,
    productgrouplistdim1       p,
    productgroupcompanybridge1 b
WHERE
        o.productgrouplistid = p.productgrouplistid
    AND p.productgrouplistid = b.productgrouplistid
    AND b.company_id = 'Company07'
GROUP BY
    b.company_id;

/* Q.4: What is the total order price for Kid Bicycles? */

SELECT
    c.type_name,
    SUM(p.total_order_price)
FROM
    productorderpricefact1 p,
    categoryofproductdim1  c
WHERE
        p.type_id = c.type_id
    AND lower(c.type_name) = 'kid bicycles'
GROUP BY
    c.type_name;

/* Q.5: What is the total order price placed 
    in store one belonging to Road Bikes?*/

SELECT
    p.store_id,
    c.type_name,
    SUM(p.total_order_price) AS total_order_price
FROM
    productorderpricefact1 p,
    categoryofproductdim1  c
WHERE
        p.type_id = c.type_id
    AND lower(c.type_name) = 'road bikes'
    AND p.store_id = 'Store1'
GROUP BY
    p.store_id,
    c.type_name;

/* Q.6: How many products in store one belong to Comfort Bicycles?*/

SELECT
    p.store_id,
    c.type_name,
    SUM(p.number_of_products) AS number_of_products
FROM
    productorderpricefact1 p,
    categoryofproductdim1  c
WHERE
        p.type_id = c.type_id
    AND lower(c.type_name) = 'comfort bicycles'
    AND p.store_id = 'Store1'
GROUP BY
    p.store_id,
    c.type_name;

/* Q.7: How many part-time staff work in store one?*/

SELECT
    store_id,
    staff_type,
    SUM(number_of_staffs) AS number_of_staffs
FROM
    stafffact1
WHERE
        store_id = 'Store1'
    AND lower(staff_type) = 'part_time'
GROUP BY
    store_id,
    staff_type;

/* Q.8: How many staff have worked for more than three years in the Monstore?*/

SELECT
    s.work_duration_type,
    SUM(s.number_of_staffs) AS number_of_staffs
FROM
    stafffact1            s,
    staffworkdurationdim1 d
WHERE
        s.work_duration_type = d.work_duration_type
    AND lower(d.work_duration_description) = 'more than 3 years'
GROUP BY
    s.work_duration_type;

----------------------------------------------------------------------------
--------------------------Version-2--------------------------------------------

DROP TABLE storedim2;

DROP TABLE staffdim2;

DROP TABLE companydim2;

DROP TABLE categoryofproductdim2;

DROP TABLE typeofstaffdim2;

DROP TABLE staffworkdurationdim2;

DROP TABLE productgrouplistdim2;

DROP TABLE productgroupcompanybridge2;

DROP TABLE orderdim2;

DROP TABLE orderdimtemp2;

DROP TABLE customerdim2;

DROP TABLE tempstafffact2;

DROP TABLE stafffact2;

DROP TABLE productorderpricefact2;

DROP TABLE orderfact2_temp;

DROP TABLE orderfact2;

-- Creating the dimesion related to store dimension
-- named as StoreDim2

CREATE TABLE storedim2
    AS
        SELECT DISTINCT
            store_id
        FROM
            monstore.store;

-- Creating the dimesion related to type of staff dimension
-- named as TypeOfStaffDim2

CREATE TABLE typeofstaffdim2 (
    staff_type             VARCHAR2(10),
    staff_type_description VARCHAR2(100)
);

INSERT INTO typeofstaffdim2 VALUES (
    'Part_time',
    'less than 20 working hours per week'
);

INSERT INTO typeofstaffdim2 VALUES (
    'Full_time',
    'more than 20 working hours per week'
);

SELECT
    *
FROM
    typeofstaffdim2;

-- Creating the dimesion related to staff working duration
-- named as StaffWorkDurationDim2

CREATE TABLE staffworkdurationdim2 (
    work_duration_type        VARCHAR2(20),
    work_duration_description VARCHAR2(50)
);

INSERT INTO staffworkdurationdim2 VALUES (
    'new beginner',
    'less than 3 years, inclusive'
);

INSERT INTO staffworkdurationdim2 VALUES (
    'mid-level',
    'more than 3 years'
);

SELECT
    *
FROM
    staffworkdurationdim2;

-- Creating the dimesion related to staff
-- named as StaffDim2

CREATE TABLE staffdim2
    AS
        SELECT DISTINCT
            staff_id
        FROM
            monstore.staff;

SELECT
    *
FROM
    staffdim2;

-- Creating the dimesion related to category of product
-- named as CategoryOfProductDim2
DROP TABLE categoryofproductdim2;

/*create table CategoryOfProductDim2
as select * from MONSTORE.product_category;*/

CREATE TABLE categoryofproductdim2
    AS
        SELECT DISTINCT
            p.product_id,
            c.type_name
        FROM   --p.type_id,
            monstore.product          p,
            monstore.product_category c
        WHERE
            p.type_id = c.type_id;

SELECT
    *
FROM
    categoryofproductdim2;

-- Creating the dimesion related to company name
-- named as CompanyDim2

CREATE TABLE companydim2
    AS
        SELECT DISTINCT
            company_id,
            company_name
        FROM
            monstore.company;

SELECT
    *
FROM
    companydim2;

-- Creating the dimesion related to product
-- named as ProductGroupListDim2

CREATE TABLE productgroupdimtemp2
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

CREATE TABLE productgrouplistdim2
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
    productgrouplistdim2;

-- Creating the dimesion related to a bridge table
-- named as ProductCompanyBridge1

CREATE TABLE productgroupcompanybridge2
    AS
        SELECT DISTINCT
            p.productgrouplistid,
            c.company_id
        FROM
            productgrouplistdim2     p,
            monstore.product_company c
        WHERE
            p.productgrouplistid LIKE ( '%'
                                        || c.product_id
                                        || '%' );

SELECT
    *
FROM
    productgroupcompanybridge2;

-- Creating the dimesion related to a order tables
-- named as OrderDim2

CREATE TABLE orderdimtemp2
    AS
        SELECT DISTINCT
            o.order_id,
            ot.order_date
        FROM
            monstore.order_items o,
            monstore.ordertable  ot
        WHERE
            o.order_id = ot.order_id;

ALTER TABLE orderdimtemp2 ADD (
    quarter CHAR(1)
);

UPDATE orderdimtemp2
SET
    quarter = '1'
WHERE
    to_char(order_date, 'Mon') IN ( 'Jan', 'Feb', 'Mar' );

UPDATE orderdimtemp2
SET
    quarter = '2'
WHERE
    to_char(order_date, 'Mon') IN ( 'Apr', 'May', 'Jun' );

UPDATE orderdimtemp2
SET
    quarter = '3'
WHERE
    to_char(order_date, 'Mon') IN ( 'Jul', 'Aug', 'Sep' );

UPDATE orderdimtemp2
SET
    quarter = '4'
WHERE
    to_char(order_date, 'Mon') IN ( 'Oct', 'Nov', 'Dec' );

SELECT
    *
FROM
    orderdimtemp2;

CREATE TABLE orderdim2
    AS
        SELECT
            order_id,
            quarter
        FROM
            orderdimtemp2;

SELECT
    *
FROM
    orderdim2;

-- Creating the dimesion related to a customer dimension
-- named as customerdim2

CREATE TABLE customerdim2
    AS
        SELECT DISTINCT
            customer_id,
            suburb,
            customer_age
        FROM
            monstore.customer;

ALTER TABLE customerdim2 ADD (
    age_group VARCHAR2(30)
);

UPDATE customerdim2
SET
    age_group = 'early-age'
WHERE
        customer_age >= 18
    AND customer_age <= 40;

UPDATE customerdim2
SET
    age_group = 'middle-age'
WHERE
        customer_age >= 41
    AND customer_age <= 59;

UPDATE customerdim2
SET
    age_group = 'old-age'
WHERE
    customer_age >= 60;

SELECT
    *
FROM
    customerdim2;


----------------------------------------------------------------------------
--------------------------fact table-----------------------------------------

-- Creating staffFact1 Table

CREATE TABLE tempstafffact2 -- At first, creating TempStaffFact1 table
    AS
        SELECT DISTINCT
            s.staff_id,
            st.store_id,
            s.staff_type,
            s.staff_since
        FROM
            monstore.staff s,
            monstore.store st
        WHERE
            s.store_id = st.store_id;

ALTER TABLE tempstafffact2 ADD (
    work_duration_type VARCHAR2(20)
);

UPDATE tempstafffact2
SET
    work_duration_type = 'new beginner'
WHERE
    ( current_date - staff_since ) / 365 <= 3;

UPDATE tempstafffact2
SET
    work_duration_type = 'mid-level'
WHERE
    ( current_date - staff_since ) / 365 > 3;

CREATE TABLE stafffact2
    AS
        SELECT
            staff_id,
            store_id,
            staff_type,
            work_duration_type,
            COUNT(*) AS number_of_staffs
        FROM
            tempstafffact2
        GROUP BY
            staff_id,
            staff_type,
            work_duration_type,
            store_id;

SELECT
    *
FROM
    stafffact2;

-- Creating ProductOrderPriceFact2 table;
DROP TABLE productorderpricefact2;

CREATE TABLE productorderpricefact2
    AS
        SELECT DISTINCT
            s.store_id,
            p.product_id,
            o.order_id,
            o.quantity          AS order_quantity,
            o.list_price        AS order_list_price,
            COUNT(p.product_id) AS number_of_products
        FROM
            monstore.stock       s,
            monstore.product     p,
            monstore.order_items o
        WHERE
                s.product_id = p.product_id
            AND p.product_id = o.product_id
        GROUP BY
            s.store_id,
            p.type_id,
            p.product_id,
            o.order_id,
            o.quantity,
            o.list_price;

SELECT
    *
FROM
    productorderpricefact2;

-- Creating  OrderFact table
/*
-- Wrong table

create table OrderFact2 as  
select s.store_id, c.customer_id, ot.product_id, ot.order_id,
count(ot.order_id) as number_of_orders   --(1.0/count(st.order_id))
from MONSTORE.store s, Monstore.ordertable o, 
Monstore.customer c, Monstore.order_items ot
where ot.order_id = o.order_id and 
s.store_id = o.store_id and
o.customer_id = c.customer_id
group by s.store_id, c.customer_id, ot.product_id, ot.order_id
order by s.store_id, c.customer_id, ot.product_id, ot.order_id;

select * from orderfact2;
*/

DROP TABLE orderfact2_temp;

CREATE TABLE orderfact2_temp
    AS
        SELECT
            s.store_id,
            c.customer_id,
            ot.order_id,
            LISTAGG(ot.product_id, '_') WITHIN GROUP(
            ORDER BY
                ot.order_id
            ) AS productgrouplistid
        FROM
            monstore.store       s,
            monstore.ordertable  o,
            monstore.customer    c,
            monstore.order_items ot
        WHERE
                ot.order_id = o.order_id
            AND s.store_id = o.store_id
            AND o.customer_id = c.customer_id
        GROUP BY
            s.store_id,
            c.customer_id,
            ot.order_id;

CREATE TABLE orderfact2
    AS
        SELECT
            s.store_id,
            c.customer_id,
            f.order_id,
            f.productgrouplistid,
            COUNT(f.order_id) AS number_of_orders
        FROM
            monstore.store      s,
            monstore.ordertable o,
            monstore.customer   c,
            orderfact2_temp     f
        WHERE
                f.order_id = o.order_id
            AND s.store_id = o.store_id
            AND o.customer_id = c.customer_id
        GROUP BY
            s.store_id,
            c.customer_id,
            f.order_id,
            f.productgrouplistid
        ORDER BY
            s.store_id,
            c.customer_id,
            f.order_id,
            f.productgrouplistid;

SELECT
    *
FROM
    orderfact2;

