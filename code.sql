/*
select * from MONSTORE.ordertable order by customer_id;
select * from MONSTORE.product;
select * from MONSTORE.order_items;
select * from MONSTORE.customer; 

select product_id, list_price from MONSTORE.product order by product_id, list_price;
*/

DESCRIBE MONSTORE.product;

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


-- Creating the dimesion related to product
-- named as ProductDim1

/*
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

