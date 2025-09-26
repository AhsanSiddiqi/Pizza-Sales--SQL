create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) );

create table order_details (
order_details_id int not null,
order_id int not null, 
pizza_id varchar(50) not null,
quantity int not null,
PRIMARY KEY(order_details_id)
);

create table pizzas (
pizza_id varchar(50) not null,
pizza_type_id varchar(50) not null,
size text not null,
price numeric(5,2)
)
drop table pizza_types;
create table pizza_types (
pizza_type_id varchar(50) not null,
name varchar(100) ,
category varchar(50) ,
ingredients text not null
)
alter table pizza_details rename to pizza_types;

alter table pizza_types
alter column ingredients type varchar(100);

alter table pizza_types
alter column name type varchar(100);

ALTER TABLE pizza_types
ALTER COLUMN pizza_type_id SET primary key;

select* from pizza_types;

-- Retrieve the total number of orders placed.

select * from pizzas;
select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.
select  sum(p.price * o.quantity) as total_revenue
from pizzas p
join
order_details o
on p.pizza_id = o.pizza_id

-- Identify the highest-priced pizza.
select pz.pizza_type_id,pz.name,p.price
from pizza_types pz
join 
pizzas p
on
pz.pizza_type_id = p.pizza_type_id
order by p.price DESC limit 1;

-- Identify the most common pizza size ordered.



select p.size,count(p.size) as count_size
from pizzas p
join
order_details o
on 
p.pizza_id = o.pizza_id
group by p.size
order by count_size DESC

-- List the top 5 most ordered pizza types along with their quantities.

select pz.name, p.pizza_type_id, sum(o.quantity) as total_quantity
from pizzas p
join
pizza_types pz
on
p.pizza_type_id = pz.pizza_type_id
join 
order_details o
on o.pizza_id = p.pizza_id
group by pz.name,p.pizza_type_id
order by total_quantity DESC limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pz.category, sum(o.quantity) as total_quantity
from pizzas p
join
pizza_types pz
on
p.pizza_type_id = pz.pizza_type_id
join 
order_details o
on o.pizza_id = p.pizza_id
group by pz.category
order by total_quantity DESC;

-- Determine the distribution of orders by hour of the day.

select extract(hour from order_time) as hour , count(order_id) as count_order
from orders
group by hour
order by hour;

-- Join relevant tables to find the category-wise distribution of pizzas.

select  category , count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),2) from
(select o.order_date, sum(od.quantity) as quantity
from orders o
join 
order_details od
on o.order_id = od.order_id
group by o.order_date)

-- Determine the top 3 most ordered pizza types based on revenue.
select pz.name , sum(o.quantity * p.price) as revenue
from pizza_types pz
join
pizzas p
on pz.pizza_type_id = p.pizza_type_id
join 
order_details o
on 
p.pizza_id = o.pizza_id
group by pz.name
order by revenue DESC limit 3

-- Calculate the percentage contribution of each pizza type to total revenue.

select pz.category, round(sum(o.quantity * p.price) / (select  sum(p.price * o.quantity)
as total_revenue
from pizzas p
join
order_details o
on p.pizza_id = o.pizza_id)*100,2) as revenue
from pizza_types pz
join
pizzas p
on pz.pizza_type_id = p.pizza_type_id
join 
order_details o
on 
p.pizza_id = o.pizza_id
group by pz.category
order by revenue DESC;

-- Analyze the cumulative revenue generated over time

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select o.order_date,sum(od.quantity * p.price)
as revenue
from order_details od
join
pizzas p
on
od.pizza_id = p.pizza_id
join orders o
on
o.order_id = od.order_id
group by o.order_date) as sales


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category,name,revenue
FROM
(SELECT category,name,revenue,
RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
FROM 
(SELECT pt.category,pt.name,
SUM(od.quantity * p.price) AS revenue
FROM order_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
ON 
p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, pt.name) as a) as b
WHERE rnk <= 3
ORDER BY category, revenue DESC;

select * from pizzas;
select * from pizza_types;
select * from order_details;
select * from orders;