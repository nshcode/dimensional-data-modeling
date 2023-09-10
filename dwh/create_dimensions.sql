
drop schema if exists dwh cascade;
create schema dwh;

-- ==================
-- Product Dimension
-- ==================
create table dwh.dim_product as
select 
	p.product_id
	,p.product_name 
	,p.list_price
	,p.model_year
	,b.brand_name
	,c.category_name 
from bike_stores.products p
join bike_stores.brands b
	on p.brand_id = b.brand_id 
join bike_stores.categories c
	on p.category_id = c.category_id 
;

alter table dwh.dim_product 
add constraint dim_product_pk primary key (product_id)
;

-- ===================
-- Customer Dimension
-- ===================
create table dwh.dim_customer as
select
	c.customer_id
	,c.first_name
	,c.last_name
	,coalesce (c.phone, 'Unknown')    as phone
	,coalesce (c.email, 'Unknown')    as email
	,coalesce (c.street, 'Unknown')   as street
	,coalesce (c.zip_code, 'Unknown') as zip_code
	,coalesce (c.state, 'Unknown')    as state
from bike_stores.customers c
;

alter table dwh.dim_customer 
add constraint dim_customer_pk primary key (customer_id)
;

-- ================
-- Store Dimension
-- ================
create table dwh.dim_store as
select 
	s.store_id 
	,s.store_name
	,coalesce (s.phone, 'Unknown') as phone
	,coalesce (s.email, 'Unknown') as email
	,s.street
	,s.zip_code
	,s.city 
from bike_stores.stores s
;

alter table dwh.dim_store 
add constraint dim_store_pk primary key (store_id)
;

-- ================
-- Staff Dimension
-- ================
create table dwh.dim_staff as
select 
	s.staff_id
	,s.first_name
	,s.last_name
	,coalesce (s.phone, 'Unknown') as phone
	,coalesce (s.email, 'Unknown') as email
	,s.active
	,s.manager_id
	,s2.first_name as manager_first_name
	,s2.last_name  as manager_last_name
from bike_stores.staffs s
left join bike_stores.staffs s2
	on s.manager_id = s2.staff_id
;

alter table dwh.dim_staff 
add constraint dim_staff_pk primary key (staff_id)
;

-- ==========================
-- Staff Hierarchy Bridge
-- ==========================
create table dwh.staff_hierarchy as
with recursive sh(staff_id, subordinate_id, hierarchy_depth) as
(
	select
		staff_id
		,staff_id as subordinate_id
		,0        as hierarchy_depth
	from bike_stores.staffs
	union all
	select 
		sh.staff_id              as staff_id
		,s.staff_id              as subordinate_id
		,sh.hierarchy_depth + 1  as hierarchy_depth
	from sh
	join bike_stores.staffs s
		on sh.subordinate_id = s.manager_id
)
select 
	staff_id
	,subordinate_id
	,hierarchy_depth
from sh
;

alter table dwh.staff_hierarchy
add constraint statt_hierarchy_d_staff_fk 
	foreign key (staff_id) references dwh.dim_staff(staff_id)
;
alter table dwh.staff_hierarchy 
add constraint statt_hierarchy_d_subordinate_fk 
	foreign key (subordinate_id) references dwh.dim_staff(staff_id)
;

-- ===============
-- Date Dimension
-- ===============
create table dwh.dim_date (
	date_id        int     not null
	,date          date    not null
	,day_name      text    not null
	,day_of_month  int     not null
	,week_of_month int     not null
	,week_of_year  int     not null
	,month         int     not null
	,month_name    text    not null
	,quarter       int     not null
	,year          int     not null
	,is_weekend    boolean not null
);

insert into dwh.dim_date
select 
	to_char(d, 'yyyymmdd')::int as date_id
	,d                         as date
	,to_char(d, 'FMDay')       as day_name
	,extract(day from d)       as day_of_month
	,to_char(d, 'W')::int      as week_of_month
	,extract(week from d)      as week_of_year
	,extract(month from d)     as month
	,to_char(d, 'FMMonth')     as month_name
	,extract(quarter from d)   as quarter 
	,extract(year from d)      as year
	,case 
		when extract(isodow from d) in (6, 7) then true
		else false
	end as is_weekend
from (select '2016-01-01'::date + sequence.day as d
	  from generate_series(0, 2000) as sequence(day)
	 ) date_seq
order by 1;

alter table dwh.dim_date
add constraint dim_date_pk primary key (date_id)
;
alter table dwh.dim_date
add constraint dim_date_date_u unique(date)
;