-- 1.Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- 2.Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- 3.Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4.Identify the most common pizza size ordered.

SELECT 
    pizzas.size, COUNT(pizzas.size)
FROM
    pizzas
GROUP BY pizzas.size;

-- 5.List the top 5 most ordered pizza types along with their quantities.

SELECT 
    order_details.pizza_id,
    SUM(order_details.quantity) AS quantity
FROM
    order_details
GROUP BY order_details.pizza_id
ORDER BY SUM(order_details.quantity) DESC
LIMIT 5;

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    SUM(order_details.quantity) AS quantity,
    pizza_types.category
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category;

-- 7.Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(orders.order_time), COUNT(order_details.order_id)
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY HOUR(orders.order_time);


-- 8.Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pizza_types.category,
    COUNT(pizza_types.category) AS category_count
FROM
    pizza_types
GROUP BY pizza_types.category;


-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- 10.Determine the top 3 most ordered pizza types based on revenue
SELECT 
    SUM(order_details.quantity * pizzas.price) AS revenue,
    pizzas.pizza_type_id
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.pizza_type_id
ORDER BY revenue DESC
LIMIT 3;


-- 11.Calculate the percentage contribution of each pizza type to total revenue

SELECT 
    pizzas.pizza_type_id,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue_persent
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.pizza_type_id
ORDER BY revenue_persent DESC;


-- 12.Analyze the cumulative revenue generated over time.

select order_date, 
sum(revenue) over(order by order_date) as cumsum_revenue 
from
(select sum(order_details.quantity*pizzas.price) as revenue, orders.order_date
from order_details join pizzas on order_details.pizza_id=pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by orders.order_date) as sales;


-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue, rn from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select sum(order_details.quantity*pizzas.price) as revenue, pizza_types.category, pizza_types.name
from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;   -- This subquery use here because we cant use where with rank funtion