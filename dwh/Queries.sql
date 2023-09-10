-- ===================================================================================
-- What is the total order dollar amount by bike category and store for the year 2017? 
-- ===================================================================================
select 
	dp.category_name       as "category"
	,ds.store_name         as "store"
	,sum(fbo.order_amount) as "total order amount"
from dwh.fact_bike_order fbo
	,dwh.dim_product dp
	,dwh.dim_store ds 
	,dwh.dim_date dd 
where fbo.order_date_id = dd.date_id 
	and fbo.product_id  = dp.product_id
	and fbo.store_id    = ds.store_id 
	and dd.year         = 2017
group by
	dp.category_name 
	,ds.store_name
	
;

-- ===========================================================================
-- What is the of delayed shipments compared to the total number of shipmentts? 
-- ===========================================================================
select 
	dc.zip_code  as "customerZipCode"
	,sum(
		case 
			when sdate."date" is not null 
				and rdate."date" < sdate."date" 
			then 1 
			when sdate."date"  is null
				and rdate."date" < current_date          
			then 1
			else 0 
		end 
	)            as "delayedShipmentsCount"
	,count(*)    as "shipmentsCount"
from
(
	select order_id
		,customer_id
		,store_id
		,requirement_date_id 
	from dwh.fact_bike_order
	group by order_id
		,customer_id
		,store_id
		,requirement_date_id
) orders
left join 
(
	select order_id
		,shipment_date_id
	from dwh.fact_bike_shipment
	group by order_id
		,shipment_date_id
) shipments 
	on orders.order_id = shipments.order_id
left join dwh.dim_customer dc 
	on orders.customer_id = dc.customer_id 
left join dwh.dim_store ds 
	on orders.store_id = ds.store_id
left join dwh.dim_date rdate 
	on orders.requirement_date_id = rdate.date_id
left join dwh.dim_date sdate
	on shipments.shipment_date_id = sdate.date_id
group by 
	dc.zip_code
;

-- ===============================================================================================================
-- What is the total order dollar amount of each staff managed by Jannette for the first quarter of the year 2017?
-- ===============================================================================================================
select 
	(select first_name || ' ' || last_name as "Name" 
	from dwh.dim_staff ds 
	where ds.staff_id = fbo.staff_id
	) 
	,sum(fbo.order_amount)                 as "Sales Amount"
from 
	dwh.fact_bike_order fbo
	,dwh.staff_hierarchy bridge
	,dwh.dim_staff ds
	,dwh.dim_date dd
where
	fbo.staff_id    = bridge.subordinate_id   
	and ds.staff_id = bridge.staff_id 
	and ds.first_name = 'Jannette'
	and fbo.order_date_id   = dd.date_id 
	and dd."year" = 2017
	and dd.quarter = 1
group by
	fbo.staff_id
;

-- ==============================================================================================================================
-- What is the total order dollar amount of each staff above Layla in the staff hierarchy for the first quarter of the year 2017?
-- ==============================================================================================================================
select 
	(select first_name || ' ' || last_name as "Name" 
	from dwh.dim_staff ds 
	where ds.staff_id = fbo.staff_id
	) 
	,sum(fbo.order_amount) 				   as "Sales Amount"
from 
	dwh.fact_bike_order fbo
	,dwh.staff_hierarchy bridge
	,dwh.dim_staff ds
	,dwh.dim_date dd
where
	fbo.staff_id    = bridge.staff_id   
	and ds.staff_id = bridge.subordinate_id 
	and ds.first_name = 'Layla'
	and fbo.order_date_id   = dd.date_id 
	and dd."year" = 2017
	and dd.quarter = 1
group by
	fbo.staff_id
;

