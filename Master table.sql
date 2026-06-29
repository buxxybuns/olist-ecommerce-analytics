create view analytics.payment_agg as
select order_id,
sum(payment_value) as total_payment,
max(payment_installments) as installments,
count(*) as payment_transactions
from ecommerce.payments
group by order_id;
select count(*) from analytics.paymemt_agg;

--DELIVERY METRICS
create view analytics.delivery_metrics as
select order_id, extract(day from(
order_delivered_customer_date-order_purchase_time)
) as delivery_days,
extract(day from(order_estimated_delivery_date-order_purchase_time))
as promised_days,
extract(day from(order_delivered_customer_date-
order_estimated_delivery_date)) as delay_days
case 
when order_delivered_customer_date>order_estimated_delivery_date
then 1 else 0
end as late_delivery
from ecommerce.orders
where order_delivered_customer_date is not null;

--ORDER_MASTER tABLE	
create view analytics.order_master as 
select
c.customer_unique_id, c.customer_city,
c.customer_state,
o.order_id, o.customer_id,o.order_status,
o.order_purchase_time,
p.total_payment,
p.installments,
p.payment_transactions,
r.review_score,
d.delivery_days,
d.late_delivery

from ecommerce.orders o 
left join ecommerce.customers c 
on o.customer_id=c.customer_id 

left join analytics.payment_agg p
on o.order_id=p.order_id

left join analytics.review_agg r on 
o.order_id=r.order_id

left join analytics.delivery_metrics d
on o.order_id=d.order_id;

select count(*) from ecommerce.orders;
select count(*) from analytics.order_master;

select count(*) as total_rows, 
count(distinct customer_id) as distinct_customers
from ecommerce.customers

select count(*) as total_rows,
count(distinct order_id) as distinct_orders
from analytics.payment_agg

select order_id, count(*) as review_count
from ecommerce.reviews group by 
order_id having count(*)>1
order by review_count

--the count for each order id is 2 meaning duplicates

create view analytics.review_agg as 
select order_id, avg(review_score) as
review_score from ecommerce.reviews
group by order_id
--replacing the review_agg with ecommerce.reviews above for the join

drop view analytics.order_master
--creating new order master 
create view analytics.order_master as 
select c.customer_unique_id,c.customer_city,
c.customer_state,
o.order_id, o.customer_id,o.order_status,
o.order_purchase_time,
p.total_payment,
p.installments, 
p.payment_transactions,
r.review_score,
d.delivery_days,
d.promised_days,
d.delay_days,
d.late_delivery


from ecommerce.customers c 
left join ecommerce.orders o on 
c.customer_id=o.customer_id
left join analytics.payment_agg p on
p.order_id=o.order_id
left join analytics.review_agg r on 
o.order_id=r.order_id 
left join analytics.delivery_metrics d
on o.order_id=d.order_id

--CREATING PRODUCT MASTER
create view analytics.product_master as
select oo.order_id, oo.order_item_id,
oo.product_id, oo.seller_id,oo.price,
oo.freight_value,
p.product_category_name,
p.product_weight_g,
p.product_length_cm,
p.product_width_cm,
p.product_height_cm,
ct.product_category_name_english,
s.seller_city, s.seller_state

from ecommerce.order_items oo
left join ecommerce.products p on
oo.product_id=p.product_id
left join ecommerce.category_translation ct
on p.product_category_name=
ct.product_category_name
left join ecommerce.sellers s
on oo.seller_id=s.seller_id

--BUSINESS OPERATIONS
--REVENUE CATEGORY
select product_category_name_english,
sum(price) as revenue
from analytics.product_master
group by 1 order by revenue desc

--CONTRIBUTION OF EACH CATEGORY
select product_category_name_english,
sum(price) as revenue,
round(100.0*sum(price)/sum(
sum(price)) over(),2) as 
percent_revenue_share from
analytics.product_master 
group by 1
order by revenue desc

--cummalitve revenue
select product_category_name_english,
sum(price) as revenue,
--cumulative running revenue
sum(sum(price)) over(
order by sum(price) desc
) as cumulative_revenue,
--cumulative percentage share
round(100.0*sum(price)/sum(sum(price))
over (),2) || '%' as 
revenue_share_pct,
round(100.0*sum(sum(price)) over
(
order by sum(price) desc
)/sum(sum(price))over(),2)as
cum_revenue_share_pct
from analytics.product_master
group by 1
order by revenue desc

--business query for most revenue generating prod
select product_category_name_english,
sum(price) as revenue,
--standard share percentage
round(100.0*sum(price)/sum(sum(price))
over(
),2) as revenue_share_pct,
--cumulative running revenue
sum(sum(price)) over(
order by sum(price) desc
)as cumulative_revenue,
--cumulative running revenue percentage
round(100.0*sum(sum(price)) over(
order by sum(price) desc
)/sum(sum(price)) over(),2)as
cumu_revenue_share_pct
from analytics.product_master
where price>=15.00
group by 1
order by revenue desc
--AVG REVIEW BY CATEGORY
select pm.product_category_name_english,
round(avg(om.review_score),2) as avg_review
from analytics.product_master pm join
analytics.order_master om on 
pm.order_id=om.order_id
group by 1
order by avg_review

--Revenue by month
select Date_trunc('month', order_purchase_time) as month,
sum(total_payment) as revenue
from analytics.order_master
group by 1 order by 1

--Customer summary 
create view 
analytics.customer_summary as
select customer_unique_id, 
customer_city, customer_state,
count(distinct order_id) as total_orders,
round(
sum(total_payment)::numeric,2) as tot_spent,
round(avg(total_payment)::numeric,2) as avg_order_value,
round(avg(review_score)::numeric,2) as avg_review,
min(order_purchase_time) as first_order,
max(order_purchase_time) as last_order,
(max(order_purchase_time)::date-
min(order_purchase_time)::date) as custome_lifetime_days,
nullif(max(order_purchase_time)::date-
min(order_purchase_time)::date,0) as 
repeat_customer_lifetime_days
from analytics.order_master 
where order_status='delivered'
group by 1,2,3

--SELLER SUMMARY
create view analytics.seller_summary as
select pm.seller_id, pm.seller_city, 
pm.seller_state,
count(distinct pm.order_id) as total_orders,
count(distinct pm.product_id) as unique_products,
round(sum(pm.price)::numeric,2) as total_revenue,
round(avg(pm.price)::numeric,2) as avg_price,
round(avg(om.review_score)::numeric,2) as avg_rating,
round(avg(dm.delivery_days)::numeric,1) as avg_delivery_days,
round(100.0*sum(dm.late_delivery)/count(*),2) as late_delivery
from analytics.product_master pm
left join analytics.order_master om on 
pm.order_id=om.order_id left join 
analytics.delivery_metrics dm on
pm.order_id=dm.order_id
group by 1,2,3

--ORDER STATUS DISTRIBUTION
select order_status, count(*) as count,
round(100.0*count(*)/sum(count(*)) over(),2) as pct
from ecommerce.orders
group by 1 order by count desc

--REVIEW SC0RE DISTRIBUTION
select review_score, count(*) as count,
round(100.0*count(*)/sum(count(*))over(),2) as pct
from ecommerce.reviews
group by 1 order by 1

--order value buckets
select case 
when total_payment<50 then '1: Under $50'
when total_payment<100 then '2: $50-100'
when total_payment<200 then '3: $100-200'
when total_payment<500 then '4: %200-500'
else '5: $500+'
end as value_bucket, count(*) as orders,
round(avg(total_payment)::numeric,2) as avg_value,
round(100.0*count(*)/sum(count(*)) over(),2) as pct
from analytics.order_master
where order_status='delivered' 
group by 1 order by 1

--DELIVERY DAYS DISTRIBUTION
select case
when delivery_days<=5 then '1: 0-5 days'
when delivery_days<=10 then '2: 6-10 days'
when delivery_days<=20 then '3: 11-20 days'
when delivery_days<=30 then '4: 21-30 days'
else '5: 30+ days'
end as delivery_bucket, count(*) as orders,
round(100.0*count(*)/sum(count(*)) over(),2) as pct
from analytics.delivery_metrics 
group by 1 order by 1

--ITEM PER ORDER DISTRIBUTION
select item_count, count(*) as orders,
round(100.0*count(*)/sum(count(*))over(),2) as pct
from (
select order_id, count(*) as item_count
from ecommerce.order_items group by 1
) as sub
group by 1 order by 1

--HOURLY ORDER PATTERN
select extract(hour from order_purchase_time) 
as hour,
count(*) as orders
from analytics.order_master group by 1 order by 1

--DAY OF THE WEEK PATTERN
select extract(day from order_purchase_time) 
as day_num,
to_char(order_purchase_time,'day') as day_name,
count(*) as orders,
round(sum(total_payment)::numeric,2) as revenue
from analytics.order_master 
group by 1,2 order by 1

--MONTLY SEASONALITY
select extract(month from order_purchase_time) as
month_num,
to_char(order_purchase_time,'month') as month_name,
count(distinct order_id) as orders,
round(sum(total_payment)::numeric,2) as revenue
from analytics.order_master
group by 1,2 order by 1

--PAYMENT BEHAVIOUR
select payment_type,
count(*) as transactions,
round(sum(payment_value)::numeric,2) as total_value,
round(avg(payment_value)::numeric,2) as avg_value,
round(avg(payment_installments)::numeric,1) as avg_installments
from ecommerce.payments
group by 1 order by total_value desc

--INSTALLMENT SPLIT FOR CREDIT CARD
select payment_installments,
count(*) as count,
round(avg(payment_value)::numeric,2) as avg_value
from ecommerce.payments
where payment_type='credit_card'
group by 1 order by 1

--CATEGORY PRICE DISTRIBUTION
select product_category_name_english,
count(distinct product_id) as products,
round(min(price)::numeric,2) as min_price,
round(max(price)::numeric,2) as max_price,
round(avg(price)::numeric,2) as avg_price,
round(percentile_cont(0.5) within group
(order by price)::numeric,2) as median_price
from analytics.product_master
group by 1 order by avg_price desc 

--GEOGRAPHIC DISTRIBUTION
select customer_state,
count(distinct customer_unique_id) as customers,
count(distinct order_id) as orders,
round(
100.0*count(distinct order_id)/sum(
count(distinct order_id))over(),2) as order_share_pct
from analytics.order_master
group by 1 order by orders desc

--REVENUE ANALYTICS 
--MONTHLY GROWRH RATE	
with monthly as (
select extract(month from order_purchase_time) as month,
count(distinct order_id)as orders,
sum(total_payment) as revenue
from analytics.order_master
where order_status='delivered'
group by 1
)
select month, orders,
round(revenue::numeric,2) as revenue,
round(lag(revenue)over(order by month)::numeric,2)as
prev_month,
round(100.0*(revenue-lag(revenue)over(order by month))
/nullif(lag(revenue)over(order by month),0),2) as mom_growth
from monthly order by 1

--AVG FOR 3 MONTHS
with monthly as (
select extract(month from order_purchase_time) as month,
sum(total_payment) as revenue
from analytics.order_master group by 1
)
select month, round(revenue::numeric,2) as revenue,
round(avg(revenue) over(
order by month rows between 2 preceding and current row
)::numeric,2) as moving_avg_3m
from monthly order by month

--YEARLY COMPARISION
select extract(month from order_purchase_time) as month_num,
to_char(order_purchase_time,'month') as month_name,
round(sum(case 
when extract(year from order_purchase_time)=2017
then total_payment end)::numeric,2) as revenue_2017,
round(sum(case 
when extract(year from order_purchase_time)=2018
then total_payment end)::numeric,2) as revenue_2018,
round(100.0*(sum(case 
when extract(year from order_purchase_time)=2018
then total_payment end)-sum(case 
when extract(year from order_purchase_time)=2017
then total_payment end))/nullif(sum(case 
when extract(year from order_purchase_time)=2017
then total_payment end),0),2
) as yoy_growth_rate
from analytics.order_master
group by 1,2 order by 1

--REVENUE BY STATE RANK
select customer_state, 
round(sum(total_payment)::numeric,2) as revenue,
count(distinct order_id) as orders,
round(avg(total_payment)::numeric,2) as avg,
round(100.0*sum(total_payment)/
sum(sum(total_payment)) over(),2) as revenue_share_pct,
rank() over(order by sum(total_payment) desc)as
rank
from analytics.order_master 
where order_status='delivered'
group by 1 order by revenue desc

--STATE REVENUE CONCENTRATION (RISK CHECK)
with state_rev as(
select customer_state, 
sum(total_payment) as revenue 
from analytics.order_master 
where order_status='delivered'
group by 1
)
select customer_state,
round(revenue::numeric,2) as revenue,
round(100.0*revenue/sum(revenue)
over(),2) as pct,
round(100.0*sum(revenue) over(
order by revenue desc)/sum(revenue) over(),2
) as cum_pct
from state_rev order by revenue desc

--REVENUE BY CITY FOR TOP 20
select customer_city,customer_state,
round(sum(total_payment)::numeric,2) as revenue,
count(distinct order_id)as orders
from analytics.order_master
where order_status='delivered'
group by 1,2 order by revenue desc

--TOP 20 PRODUCTS BY REVENUE
select product_id, 
product_category_name_english,
count(distinct order_id) as orders,
round(sum(price)::numeric,2)as revenue,
round(avg(price)::numeric,2) as avg_price,
rank() over (order by sum(price) desc) as rank
from analytics.product_master
group by 1,2 order by revenue desc

--CROSS SELL:CATEGORIES BOUGHT TOGETHER
select a.product_category_name_english as cat_g1,
b.product_category_name_english as cat_g2,
count(distinct a.order_id) as co_occur
from analytics.product_master a
join analytics.product_master b on
a.order_id=b.order_id and
a.product_category_name_english!=
b.product_category_name_english
group by 1,2 order by co_occur desc

--FREIGHT TO PRICE RATIO
select product_category_name_english,
round(avg(price)::numeric,2) as avg_price,
round(avg(freight_value)::numeric,2) as avg_freight,
round(100.0*avg(freight_value)/
nullif(avg(price),0),1) as freight_price_pct
from analytics.product_master
group by 1 order by freight_price_pct desc

--CUSTOMER ANALYTICS
--SPEND SEGMENTATION
select case 
when total_spent<100 then '1 Low (<$100)'
when total_spent<500 then '2 Medium ($100-500)'
when total_spent<1000 then '3 High ($500-1000)'
else '4 VIP ($1000+)'
end as segment,
count(*) as customers,
round(avg(total_spent)::numeric,2) as avg_spent,
round(sum(total_spent)::numeric,2) as segment_revenue,
round(100.0*sum(total_spent)/
sum(sum(total_spent)) over(),2) as revenue_pct
from analytics.customer_summary
group by 1 order by 1

--REPEAT PURCHASE RATE
select count(*) as total_customers,
count(case when total_orders=1 then 1 end) 
as one_order,
count(case when total_orders=2 then 1 end) 
as two_order,
count(case when total_orders>2 then 1 end)
as three_plus,
round(100.0*count(case when total_orders >1
then 1 end)/count(*),2) as repeat_rate
from analytics.customer_summary

--ORDER FREQUENCY DISTRIBUTION
select total_orders, count(*) as customers,
round(100.0*count(*)/sum(count(*))over(),2)
as pct
from analytics.customer_summary
group by 1 order by 1

--TOP DECILE REVENUE CONTRIBUTION
with decile as (
select customer_unique_id, total_spent,
Ntile(10) over(order by total_spent desc) 
as decile 
from analytics.customer_summary
)
select decile, count(*) as customers,
round(sum(total_spent)::numeric,2) as revenue,
round(100.0*sum(total_spent)/
sum(sum(total_spent))over(),2)as pct,
round(sum(sum(total_spent))over(order by 
decile)::numeric,2) as cum_revenue
from decile group by 1 order by 1

--CUSTOMER LIFETIME VALUE
select round(avg(tot_spent)::numeric,2) 
as avg_ltv,
round(avg(total_orders)::numeric,2) as avg_orders,
round(avg(custome_lifetime_days),0) 
as avg_lifetime_days,
round(avg(repeat_customer_lifetime_days),0) as avg_repeat_ctv,
round(avg(avg_order_value)::numeric,2) as avg_aov
from analytics.customer_summary

--BEST STATES BY AVG CUSTOMER VALUE
select customer_state,
count(distinct customer_unique_id)as customers,
round(avg(tot_spent)::numeric,2) as avg_ltv,
round(sum(tot_spent)::numeric,2) as total_revenue
from analytics.customer_summary
group by 1 order by avg_ltv desc 

--NET PROMOTER SCORE
select round(100.0*count(case 
when review_score=5 then 1 end)/
count(*),1) as promoters_act,
round(100.0*count(case 
when review_score in (3,4) then 1 end)/count(*),1) as
passive_pct,
round(100.0*count(case when review_score in (1,2) 
then 1 end)/count(*),1) as detractors_pct,
round(100.0*count(case 
when review_score=5 then 1 end)/count(*)-100.0*count(case
when review_score in (1,2) then 1 end)/count(*),1) as
nps
from analytics.order_master
where review_score is not null 

--SELLER ANALYTICS 
--TOP 20 SELLERS
select seller_id, seller_state,total_revenue,
total_orders, unique_products,avg_rating,
late_delivery_pct,avg_delivery_days,
rank() over(order by total_revenue desc) as revenue_rank

-- Run each of these separately in pgAdmin

COPY (SELECT * FROM analytics.order_master)
TO 'D:/analytics/Refined Datasets/order_master.csv' CSV HEADER;

COPY (SELECT * FROM analytics.product_master)
TO 'D:/analytics/Refined Datasets/product_master.csv' CSV HEADER;

COPY (SELECT * FROM analytics.customer_summary)
TO 'D:/analytics/Refined Datasets/customer_summary.csv' CSV HEADER;

COPY (SELECT * FROM analytics.seller_summary)
TO 'D:/analytics/Refined Datasets/seller_summary.csv' CSV HEADER;

COPY (SELECT * FROM analytics.delivery_metrics)
TO 'D:/analytics/Refined Datasets/delivery_metrics.csv' CSV HEADER;

COPY (SELECT * FROM analytics.rfm_segments)
TO 'D:/analytics/Refined Datasets/rfm_segments.csv' CSV HEADER;

-- Cohort query result
COPY (
  WITH cohort AS (
    SELECT customer_unique_id,
      DATE_TRUNC('month', MIN(order_purchase_time)) AS cohort_month
    FROM analytics.order_master GROUP BY 1
  ),
  orders_with_cohort AS (
    SELECT o.customer_unique_id, c.cohort_month,
      DATE_TRUNC('month', o.order_purchase_time) AS order_month,
      EXTRACT(MONTH FROM AGE(
        DATE_TRUNC('month', o.order_purchase_time),
        c.cohort_month)) AS month_number
    FROM analytics.order_master o
    JOIN cohort c ON o.customer_unique_id = c.customer_unique_id
  )
  SELECT TO_CHAR(cohort_month,'YYYY-MM') AS cohort,
    month_number, COUNT(DISTINCT customer_unique_id) AS customers
  FROM orders_with_cohort
  GROUP BY 1, 2 ORDER BY 1, 2
)
TO 'D:/analytics/Refined Datasets/cohort.csv' CSV HEADER;

-- Monthly revenue (pre-aggregated for charts)
COPY (
  SELECT
    DATE_TRUNC('month', order_purchase_time) AS month,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(total_payment)::numeric, 2) AS revenue
  FROM analytics.order_master
  WHERE order_status = 'delivered'
  GROUP BY 1 ORDER BY 1
)
TO 'D:/analytics/Refined Datasets/monthly_revenue.csv' CSV HEADER;



