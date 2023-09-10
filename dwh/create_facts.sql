
-- ===========
-- Order Fact
-- ===========
create table dwh.fact_bike_order as
select
	to_char(o.order_date, 'yyyymmdd')::int     as order_date_id
	,to_char(o.required_date, 'yyyymmdd')::int as requirement_date_id
	,o.customer_id
	,o.staff_id 
	,o.store_id
	,oi.product_id
	,o.order_id
	,oi.quantity
	,oi.list_price
	,oi.discount
	,oi.list_price * oi.quantity                 as order_amount 
	,(oi.list_price - oi.discount) * oi.quantity as discounted_order_amount
from bike_stores.orders o 
join bike_stores.order_items oi
	on o.order_id = oi.order_id
;

alter table dwh.fact_bike_order 
add constraint f_bike_order_date_fk      
		foreign key (order_date_id) references dwh.dim_date(date_id)
;
alter table dwh.fact_bike_order 
add constraint f_bike_order_requirement_d_date_fk      
		foreign key (requirement_date_id) references dwh.dim_date(date_id)
;
alter table dwh.fact_bike_order 
add constraint f_bike_order_d_customer_fk      
		foreign key (customer_id) references dwh.dim_customer(customer_id)
;
alter table dwh.fact_bike_order 
add constraint f_bike_order_d_product_fk      
		foreign key (product_id) references dwh.dim_product(product_id)
;
alter table dwh.fact_bike_order 
add constraint f_bike_order_d_staff_fk      
		foreign key (staff_id) references dwh.dim_staff(staff_id)
;
alter table dwh.fact_bike_order 
add constraint f_bike_order_d_store_fk      
		foreign key (store_id) references dwh.dim_store(store_id)
;

-- ===============
-- Shipment Fact
-- ===============
create table dwh.fact_bike_shipment as
select
	to_char(o.shipped_date, 'yyyymmdd')::int as shipment_date_id
	,o.customer_id
	,o.staff_id
	,o.store_id
	,oi.product_id
	,o.order_id
	,oi.quantity
	,oi.list_price
	,oi.discount
	,oi.list_price * oi.quantity                 as shipment_amount 
	,(oi.list_price - oi.discount) * oi.quantity as discounted_shipment_amount
from bike_stores.orders o 
join bike_stores.order_items oi
	on o.order_id = oi.order_id
where o.shipped_date is not null
;

alter table dwh.fact_bike_shipment 
add constraint f_bike_shipment_d_date_fk      
		foreign key (shipment_date_id) references dwh.dim_date(date_id)
;
alter table dwh.fact_bike_shipment 
add constraint f_bike_shipment_d_customer_fk      
		foreign key (customer_id) references dwh.dim_customer(customer_id)
;

alter table dwh.fact_bike_shipment 
add constraint f_bike_shipment_d_product_fk      
		foreign key (product_id) references dwh.dim_product(product_id)
;
alter table dwh.fact_bike_shipment 
add constraint f_bike_shipment_d_staff_fk      
		foreign key (staff_id) references dwh.dim_staff(staff_id)
;
alter table dwh.fact_bike_shipment 
add constraint f_bike_shipment_d_store_fk      
		foreign key (store_id) references dwh.dim_store(store_id)
;

-- ============================
-- Store Stock Fact
-- ============================
create table dwh.fact_store_stock as 
select 
	to_char('2021-06-23'::date , 'yyyymmdd')::int as date_id
	,store_id 
	,product_id
	,quantity
from 
	bike_stores.stocks 
;

alter table dwh.fact_store_stock
add constraint f_store_stock_d_store_fk
	foreign key (store_id) references dwh.dim_store(store_id)
;
alter table dwh.fact_store_stock
add constraint f_store_stock_d_product_fk
	foreign key (product_id) references dwh.dim_product(product_id)
;
alter table dwh.fact_store_stock
add constraint f_store_stock_d_date_fk
	foreign key (date_id) references dwh.dim_date(date_id)
;
