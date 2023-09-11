# Dimensional Data Modeling
## Introduction
The repository contains the SQL scripts for creating a dimensional model for the database BikeStores available at https://www.sqlservertutorial.net/sql-server-sample-database/. The SQL scripts contained here are accompanying material for the article

[Practical Introduction to Dimensional Data Model](https://medium.com/@nuhad.shaabani/practical-introduction-to-dimensional-data-design-e3fadb7b6ac4)

published on medium.


## How to Install
1. Create a PostgreSQL database with the name bike_stores (or with a different name you choose).
2. Download and unzip the file dimensional-data-modelling-main.zip.
3. CD into directory with that file.
4. Unzip the file bikeStores.zip
5. Install the schema bike_stores
   
   - psql -f bikeStores/BikeStores/create_bike_stores_tables.sql -U postgres -d bike_stores
   
   - psql -f bikeStores/BikeStores/load_bike_stores_data.sql -U postgres -d bike_stores
   
7. Install the schema dwh
   
   - psql -f dwh/create_dimensions.sql -U postgres -d bike_stores
   
   - psql -f dwh/create_facts.sql -U postgres -d bike_stores
