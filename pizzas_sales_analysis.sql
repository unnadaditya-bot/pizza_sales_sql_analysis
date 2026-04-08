CREATE DATABASE Pizza_Hut;
USE Pizza_Hut;

-- Basic Level
-- Q.1 Retrieve the total number of orders placed.
-- Q.2 Calculate the total revenue generated from pizza sales.
-- Q.3 Identify the highest-priced pizza.
-- Q.4 Identify the most common pizza size ordered.
-- Q.5 List the top 5 most ordered pizza types along with their quantities.

-- Start 
-- Q.1 Retrieve the total number of orders placed.

SELECT 
    COUNT(*) Total_Orders
FROM
    ORDERS;

-- Q.2 Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE),2) AS REVENUE
FROM
    ORDER_DETAILS
        JOIN
    PIZZAS ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID;
    
-- Q.3 Identify the highest-priced pizza.
SELECT 
    pt.NAME, p.PRICE
FROM
    PIZZA_TYPES AS PT
        JOIN
    PIZZAS AS P ON PT.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
ORDER BY P.PRICE DESC
LIMIT 1;

-- Q.4 Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) total_od
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_od DESC;

-- Q.5 List the top 5 most ordered pizza types along with their quantities.
SELECT 
    name, ROUND(SUM(quantity), 2) total_qty
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY name
ORDER BY total_qty DESC
limit 5;

--
-- Intermediate:
-- Q.6 Join the necessary tables to find the total quantity of each pizza category ordered.
-- Q.7 Determine the distribution of orders by hour of the day.
-- Q.8 Join relevant tables to find the category-wise distribution of pizzas.
-- Q.9 Group the orders by date and calculate the average number of pizzas ordered per day.
-- Q.10 Determine the top 3 most ordered pizza types based on revenue.

-- Intermediate:
-- Q.6 Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    CATEGORY, SUM(QUANTITY) AS TOTAL_OD
FROM
    ORDER_DETAILS AS OD
        JOIN
    PIZZAS AS P ON OD.PIZZA_ID = P.PIZZA_ID
        JOIN
    PIZZA_TYPES AS PT ON PT.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
GROUP BY CATEGORY
ORDER BY TOTAL_OD DESC;

-- Q.7 Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(ORDER_TIME) AS TIME_OF_OD, COUNT(*) TOTAL_OD
FROM
    ORDERS
GROUP BY TIME_OF_OD
ORDER BY TOTAL_OD DESC; 

-- Q.8 Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    CATEGORY, COUNT(NAME) AS TOTAL_PIZZA
FROM
    PIZZA_TYPES
GROUP BY CATEGORY;

-- Q.9 Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(OD_PER_DAY) AVG_PD
FROM
    (SELECT 
        ORDER_DATE, SUM(QUANTITY) OD_PER_DAY
    FROM
        ORDERS AS O
    JOIN ORDER_DETAILS AS OD ON O.ORDER_ID = OD.ORDER_ID
    GROUP BY ORDER_DATE) AS ORDER_QTY;

-- Q.10 Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    NAME, SUM(QUANTITY * PRICE) AS REVENUE
FROM
    PIZZA_TYPES AS PT
        JOIN
    PIZZAS AS P ON PT.PIZZA_TYPE_ID = P.PIZZA_TYPE_ID
        JOIN
    ORDER_DETAILS AS OD ON OD.PIZZA_ID = P.PIZZA_ID
GROUP BY NAME
ORDER BY REVENUE DESC
LIMIT 3;

-- Advanced:
-- Q.11 Calculate the percentage contribution of each pizza type to total revenue.
-- Q.12 Analyze the cumulative revenue generated over time.
-- Q.13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

-- LETS_SOLVE
-- Q.11 Calculate the percentage contribution of each pizza type to total revenue.
SELECT CATEGORY,ROUND(SUM(QUANTITY* PRICE)/(SELECT ROUND(SUM(QUANTITY* PRICE),2)
FROM ORDER_DETAILS AS OD JOIN PIZZAS AS P 
ON OD.PIZZA_ID=P.PIZZA_ID)*100,2) AS REVENUE 
FROM PIZZA_TYPES AS PT
JOIN PIZZAS AS P
ON PT.PIZZA_TYPE_ID=P.PIZZA_TYPE_ID
JOIN ORDER_DETAILS AS OD
ON OD.PIZZA_ID=P.PIZZA_ID
GROUP BY CATEGORY ORDER BY REVENUE DESC
LIMIT 3;

-- Q.12 Analyze the cumulative revenue generated over time.
SELECT ORDER_DATE,ROUND(SUM(REVENUE) OVER (ORDER BY ORDER_DATE),2) AS CUM_REVENUE FROM
(SELECT ORDER_DATE,SUM(QUANTITY* PRICE) AS REVENUE
FROM ORDERS AS O
JOIN ORDER_DETAILS AS OD
ON O.ORDER_ID=OD.ORDER_ID
JOIN PIZZAS AS P
ON P.PIZZA_ID=OD.PIZZA_ID
GROUP BY ORDER_DATE )TOTAL;

-- Q.13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT CATEGORY,NAME,REVENUE,RNK FROM
(SELECT NAME,CATEGORY,REVENUE,
RANK()OVER(PARTITION BY CATEGORY ORDER BY REVENUE DESC)AS RNK
FROM
(SELECT CATEGORY,NAME,SUM(QUANTITY*PRICE)AS REVENUE
FROM PIZZA_TYPES AS PT
JOIN PIZZAS AS P
ON PT.PIZZA_TYPE_ID=P.PIZZA_TYPE_ID
JOIN ORDER_DETAILS AS OD
 ON P.PIZZA_ID=OD.PIZZA_ID
 GROUP BY NAME,CATEGORY)AS A)AS B
 WHERE RNK<=3 ;

-- End project --

