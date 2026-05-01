USE ecommerce;

-- Query 1: Preview customers
SELECT * FROM customers LIMIT 10;

-- Query 2: Total Customers
SELECT COUNT(*) AS Total_Customers FROM customers;

-- Query 3: Top 10 Cities
SELECT customer_city, COUNT(*) AS customer_count 
FROM customers 
GROUP BY customer_city 
ORDER BY customer_count DESC 
LIMIT 10;

-- Query 4: Total Revenue
SELECT ROUND(SUM(payment_value), 2) AS Total_Revenue
FROM payments;

-- Query 5: Average Review Score
SELECT ROUND(AVG(review_score), 2) AS Average_Review_Score
FROM reviews;

-- Query 6: Most Popular Payment Method
SELECT payment_type, COUNT(*) AS payment_count
FROM payments
GROUP BY payment_type
ORDER BY payment_count DESC;

-- Query 7: Order Status
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Query 8: Monthly Orders Trend
SELECT 
MONTH(order_purchase_timestamp) AS Month,
YEAR(order_purchase_timestamp) AS Year,
COUNT(*) AS Total_Orders
FROM orders
GROUP BY Year, Month
ORDER BY Year, Month;

-- Query 9: JOIN customers and orders
SELECT c.customer_city,
COUNT(o.order_id) AS total_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_city
ORDER BY total_orders DESC
LIMIT 10;

-- Query 10: Average Order Value
SELECT ROUND(SUM(payment_value)/COUNT(DISTINCT order_id), 2) 
AS Avg_Order_Value
FROM payments;

-- Query 11: Revenue by Payment Type
SELECT payment_type,
ROUND(SUM(payment_value),2) AS total_revenue
FROM payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- Query 12: Proper Subquery
SELECT customer_id, total_spent
FROM (SELECT o.customer_id, 
      ROUND(SUM(p.payment_value), 2) AS total_spent
	  FROM orders o JOIN payments p ON o.order_id = p.order_id
	  GROUP BY o.customer_id
) AS customer_spending
WHERE total_spent > (SELECT AVG(payment_value) FROM payments)
ORDER BY total_spent DESC
LIMIT 10;

-- Query 13: Running Total by Payment Type
SELECT payment_type,
ROUND(SUM(payment_value),2) AS revenue,
ROUND(SUM(SUM(payment_value)) OVER (ORDER BY SUM(payment_value)DESC),2) AS running_total
FROM payments
GROUP BY payment_type
ORDER BY revenue DESC;

-- Query 14: CASE FUNCTION
SELECT customer_id,total_spent,
CASE
    WHEN total_spent > 1000 THEN 'High Spender'
    WHEN total_spent > 500 THEN 'Medium Spender'
    ELSE 'Low Spender'
END AS spending_category   
FROM(
     SELECT o.customer_id,
     ROUND(SUM(p.payment_value),2) AS total_spent
     FROM orders o JOIN payments p ON o.order_id = p.order_id
     GROUP BY o.customer_id
     ) AS customer_spending
ORDER BY total_spent DESC 
LIMIT 10;

-- Query 15: Multiple JOIN
SELECT c.customer_city,
COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(p.payment_value),2) AS total_revenue
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_city
ORDER BY total_revenue DESC
LIMIT 10; 

-- Query 16: Average Delivery Days
SELECT ROUND(AVG(DATEDIFF(order_delivered_customer_date,order_purchase_timestamp)),0) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;	

-- Query 17: Create View
CREATE VIEW city_revenue AS
SELECT c.customer_city,
COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(p.payment_value),2) AS total_revenue
FROM customers c JOIN orders o ON c.customer_id=o.customer_id
JOIN payments p ON o.order_id=p.order_id
GROUP BY customer_city
ORDER BY total_revenue DESC; 
SELECT * FROM city_revenue LIMIT 10;

-- Query 18: Stored Procedure
DELIMITER  
CREATE PROCEDURE GetTopCustomers(IN limit_count INT)
BEGIN
   SELECT o.customer_id,
   ROUND(SUM(payment_value),2) AS total_spent
   FROM orders o JOIN payments p ON o.order_id=p.order_id
   GROUP BY o.customer_id
   ORDER BY total_spent DESC 
   LIMIT limit_count;
END;  
DELIMITER ;

CALL GetTopCustomers(10);
