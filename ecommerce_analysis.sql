-- Ecommerce Order & Supply Chain Analysis
-- Author: Sanmay Bandekar
-- Tool: MySQL Workbench


USE ecommerce_db;

SELECT * FROM ecommerce_master LIMIT 10;

# 1. What is the total revenue, total orders, and average order value?

select ROUND(SUM(price), 2) as total_revenue,
	   COUNT(DISTINCT order_id) as total_orders, 
       ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) as avg_order_value
FROM ecommerce_master;

# 2. Which top 10 product categories generate the most revenue? 

select product_category_name, ROUND(SUM(price), 2) as revenue
from ecommerce_master
group by product_category_name
order by revenue DESC
limit 10;

# 3. What is the month-over-month revenue trend?

select month, ROUND(SUM(price), 2) as reveune
from ecommerce_master
group by month
order by month;

# 4. Which states have the highest and lowest average order value?

select customer_state, ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) as avg_order_value
from ecommerce_master
group by customer_state
order by avg_order_value ASC
limit 5;

# 5. What is the most preferred payment method and its total transaction value?

select payment_type, COUNT(order_id) as total_orders, ROUND(SUM(payment_value), 2) as total_value
from ecommerce_master
group by payment_type
order by total_orders DESC;

# 6. What percentage of orders were delivered, cancelled, or still pending?

select order_status,
	   COUNT(order_id) as total_orders,
       ROUND(COUNT(order_id) * 100 / SUM(COUNT(order_id)) OVER(), 2) as percentage
from ecommerce_master
group by order_status
order by total_orders ASC;


# 7. What is the average delivery time in days and which state delivers fastest?

select ROUND(AVG(DATEDIFF(order_delivered_timestamp, order_purchase_timestamp)), 2) as avg_delivery_time, customer_state
from ecommerce_master
where order_delivered_timestamp is not NULL
group by customer_state
order by avg_delivery_time ASC;

# 8. Find top 5 sellers by revenue and their average shipping charge

with seller_summary as (
select seller_id,
	   ROUND(SUM(price), 2) as total_revenue,
	   ROUND(AVG(shipping_charges), 2) as avg_shipping_charge
from ecommerce_master
group by seller_id
)

select * from seller_summary
order by total_revenue DESC
limit 5;

# 9. Rank product categories by revenue within each state

select customer_state,
	   product_category_name as product_categories,
       ROUND(SUM(price), 2) as revenue,
       RANK() OVER(PARTITION BY customer_state order by SUM(price) DESC) as rank_in_state
from ecommerce_master
group by customer_state, product_categories
order by customer_state, rank_in_state;

# 10. Which product categories have the highest cart abandonment — orders placed but not delivered?

select product_category_name, COUNT(order_id) as abandoned_orders
from ecommerce_master
where order_status != 'delivered'
group by product_category_name
order by abandoned_orders desc
LIMIT 10;

