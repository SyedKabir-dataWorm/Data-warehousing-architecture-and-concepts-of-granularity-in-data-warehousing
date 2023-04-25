# Data warehousing architecture and concepts of granularity in data-warehousing.

**Problem Description**

MonStore is an outdoor sports company based in Melbourne, Australia. MonStore provides a wide
range of bicycles and scooters for the general public to use to support their health and wellbeing.
The company has several stores in Melbourne, and each store has a selection of bikes and scooters
for sale.

The Monstore has an existing operational database that maintains and stores all of the business
transaction information,such as the order, product, and customers, required for the management's
daily operation. However, with the company's acquisition, the management of MonStore company
has decided to hire your team of data warehouse engineers to design, develop, and quickly
generate reports from a data warehouse to improve the work efficiency. Management at MonStore
wants to generate reports to keep track of the order information and related information, e.g.,
calculating statistics of order placed and product offered, which can later be used for forecasting
various trends and making predictions about customers' purchasing tendencies.

MonStore's operational database tables can be found in the MonStore account. You can, for
example, execute the following query:
select * from MonStore.<table_name>;

![alt text](https://github.com/SyedKabir-dataWorm/Data-warehousing-architecture-and-concepts-of-granularity-in-data-warehousing/blob/main/MonStoreDb-1.png)

![alt text](https://github.com/SyedKabir-dataWorm/Data-warehousing-architecture-and-concepts-of-granularity-in-data-warehousing/blob/main/MonStoreDb-2.png)

**Tasks**

The assignment is divided into FOUR main tasks:

--------------------------------------------------------------------------------------
1. Design a data warehouse for the above MonStore database.
--------------------------------------------------------------------------------------

You are required to create a data warehouse for the MonStore database. Management
is especially interested in the following fact measures:

● Number of orders placed
● Total order price
● Number of staff
● Number of products

The following are some possible dimension attributes that you may need in your data
warehouse:

● Order time period: by quarter
● Customer’s location
● Customer age group: early-age adults (18-40 years old); middle-aged
adults (41-59 years old); old-aged adults (over 60 years old)
● Company
● Store
● Category of product
● Type of staff (Part_time: less than 20 working hours per week,
Full_time: more than 20 working hours per week)
● Staff working duration: new beginner (less than 3 years, inclusive);
mid-level (more than 3 years)

Note: please include the above type or group description in your dimension table.

For each attribute, you may apply your own design decisions on specifying a range or
group where this is not already detailed above, but make sure to specify them in report.

- Preparation stage.

Before you start designing the data warehouse, you have to ensure that you have
explored the operational database and drawn an E/R diagram for the operational
database.

The outputs of this task are:

a) The E/R diagram of the operational database.

- Designing the data warehouse by drawing star/snowflake schema.
The star schema for this data warehouse may contains multi-fact(s). You need to
identify the fact measures, dimensions, and attributes of the star/snowflake schema.
The following queries might help you to identify the fact measures and dimensions:

● How many orders were placed in store one during quarter 1 and ordered by the
customer(s) from Marion?
● How many orders were placed by each customer age group?
● How many orders were placed that include at least one product supplied by
Company07?
● What is the total order price for Kid Bicycles?
● What is the total order price placed in store one belonging to Road Bikes?
● How many products in store one belong to Comfort Bicycles?
● How many part-time staff work in store one?
● How many staff have worked for more than three years in the Monstore?

You should pay attention to the granularity of your fact tables. You are required to
create two versions of star/snowflake schemas based on different levels of
aggregation. Version-1 should be in the highest level of aggregation. Version-2 should
be in level 0, which means it contains no aggregation. 

The star/snowflake schema of both versions you created might contain bridge table
and temporal dimensions. If you are using bridge table, make sure to include weight
factor and list aggregate attributes. You can use different temporal data warehousing
techniques for the temporal dimensions, if there are any, you must provide the reasons
for your choice(s).

The outputs of this task are:

b) Two versions of star/snowflake schema diagrams.

c) 1.An explanation of the difference among SCD types 1, 2, 3, 4, and 6,
2.The reasons for the choice of SCD type(s) for any temporal dimensions in your
star schema

d) An explanation of the difference among the two versions of star/snowflake
schemas.

--------------------------------------------------------------------------------------
2. Implement the two versions of the star/snowflake schemas using SQL.
--------------------------------------------------------------------------------------

You are required to implement the star/snowflake schemas for the two versions that
you have drawn in Task 1. That is, you need to create the different fact and dimension
tables for the two versions in SQL, and populate these tables accordingly.

When naming the fact tables and dimension tables, you are required to give the
identical name for the two versions and suffix the version number to differentiate
them. For example, “MonStore_fact_v1” for version-1 and “MonStore_fact_v2” for
version-2.If the dimension is the same between the two versions, you do not need to
create them twice.

The output is a series of SQL statements to perform this task. You will also need to
show that this task has been carried out successfully.

If your account is full, you will need to drop all of the tables that you have previously
created during the tutorials.

The outputs of this task are:

a) SQL statements (e.g., create table, insert into, etc.) to create the star/snowflake
schema Version-1

b) SQL statements (e.g., create table, insert into, etc.) to create the star/snowflake
schema Version-2.

c) Screenshots of the implementation and the tables that you have created. This
includes the content of each table that you have created. If the table is very large,
you can show just the first part of the data.
