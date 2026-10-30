DROP TABLE IF EXISTS 

-- ==========================================
-- FLIPKART SALES DATA ANALYSIS
-- ==========================================

-- 1. Drop table if it already exists
DROP TABLE IF EXISTS flipkart_sales_data;

-- 2. Create table
CREATE TABLE flipkart_sales_data (
    "Order_ID" VARCHAR(50),
    "Product_Name" VARCHAR(100),
    "Category" VARCHAR(50),
    "Price" Decimal(12,2),
    "Quantity_ Sold" INTEGER,
    "Total_Sales " NUMERIC(14,2),
    "Order_Date" Date,
    "Payment_Method" VARCHAR(50),
    "Customer_Rating" NUMERIC(3,1),
    "Month" VARCHAR(20),
    "Year" INTEGER,
    "Profit " DECIMA(14,2),
    "Discount " INTEGER,
    "Customer_Segment" VARCHAR(50),
    "Region" VARCHAR(50)
);

select count (*)
From flipkart_sa


-- 1. Total sales and profit
SELECT SUM(Total_Sales) as Total_sales, SUM(Profit) as Total_profit
FROM flipkart_sales_data;


-- 2. Sales by category
SELECT Category, SUM(Total_Sales)
FROM flipkart_sales_data
GROUP BY Category;


-- 3. Monthly sales
SELECT Month, SUM(Total_Sales)
FROM flipkart_sales_data
GROUP BY Month;


-- 4. Top 10 products by sales
SELECT Product_Name, SUM(Total_Sales)
FROM flipkart_sales_data
GROUP BY Product_Name
ORDER BY SUM(Total_Sales) DESC
LIMIT 10;


-- 5. Average sales by discount
SELECT Discount, AVG(Total_Sales)
FROM flipkart_sales_data
GROUP BY Discount;


-- 6. 10 products with the lowest profit
SELECT Product_Name, SUM(Profit)
FROM flipkart_sales_data
GROUP BY Product_Name
ORDER BY SUM(Profit) ASC
LIMIT 10;


-- 7. Sales by region
SELECT Region, SUM(Total_Sales)
FROM flipkart_sales_data
GROUP BY Region
ORDER BY SUM(Total_Sales) DESC;


-- 8. Sales by customer segment
SELECT Customer_Segment, SUM(Total_Sales )
FROM flipkart_sales_data
GROUP BY Customer_Segment;


-- 9. Most-used payment methods
SELECT Payment_Method, COUNT(*)
FROM flipkart_sales_data
GROUP BY Payment_Method
ORDER BY COUNT(*) DESC;


-- 10. Average customer rating by category
SELECT Category, AVG(Customer_Rating)
FROM flipkart_sales_data
GROUP BY Category;


-- 12. Top 3 categories by profit
SELECT Category, SUM(Profit)
FROM flipkart_sales_data
GROUP BY Category
ORDER BY SUM(Profit) DESC
LIMIT 3;

--13. Rank products within each category
WITH product_sales AS (
    SELECT
        category,
        product_name,
        SUM(total_sales) AS total_product_sales
    FROM flipkart_sales_data
    GROUP BY category, product_name
),

ranked_products AS (
    SELECT
        category,
        product_name,
        ROUND(total_product_sales, 2) AS total_sales,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY total_product_sales DESC
        ) AS product_rank
    FROM product_sales
)

SELECT *
FROM ranked_products
ORDER BY category, product_rank;

--14. Rank products within each category on the basis of profit
WITH product_profit AS (
    SELECT
        category,
        product_name,
        SUM(profit) AS total_product_profit
    FROM flipkart_sales_data
    GROUP BY category, product_name
)

SELECT
    category,
    product_name,
    ROUND(total_product_profit, 2) AS total_profit,
    DENSE_RANK() OVER (
        PARTITION BY category
        ORDER BY total_product_profit DESC
    ) AS profit_rank
FROM product_profit
ORDER BY category, profit_rank;

--15. Products ranked by average discount
WITH product_discount AS (
    SELECT
        category,
        product_name,
        AVG(discount) AS avg_discount
    FROM flipkart_sales_data
    GROUP BY category, product_name
)

SELECT
    category,
    product_name,
    ROUND(avg_discount, 2) AS average_discount,
    DENSE_RANK() OVER (
        PARTITION BY category
        ORDER BY avg_discount DESC
    ) AS discount_rank
FROM product_discount
ORDER BY category, discount_rank;

--16 highest-rated and lowest-rated products within each category
WITH product_ratings AS (
    SELECT
        category,
        product_name,
        AVG(customer_rating) AS avg_rating
    FROM flipkart_sales_data
    GROUP BY category, product_name
)

SELECT
    category,
    product_name,
    ROUND(avg_rating, 2) AS average_rating,
    DENSE_RANK() OVER (
        PARTITION BY category
        ORDER BY avg_rating DESC
    ) AS rating_rank
FROM product_ratings
ORDER BY category, rating_rank;

--17.How do different discount levels affect average sales and average profit?
WITH discount_analysis AS (
    SELECT
        CASE
            WHEN discount <= 10 THEN 'Low Discount'
            WHEN discount <= 20 THEN 'Medium Discount'
            ELSE 'High Discount'
        END AS discount_level,

        COUNT(*) AS total_orders,
        ROUND(AVG(total_sales), 2) AS average_sales,
        ROUND(AVG(profit), 2) AS average_profit,
        ROUND(SUM(total_sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit

    FROM flipkart_sales_data

    GROUP BY
        CASE
            WHEN discount <= 10 THEN 'Low Discount'
            WHEN discount <= 20 THEN 'Medium Discount'
            ELSE 'High Discount'
        END
)

SELECT *
FROM discount_analysis
ORDER BY
    CASE discount_level
        WHEN 'Low Discount' THEN 1
        WHEN 'Medium Discount' THEN 2
        WHEN 'High Discount' THEN 3
    END; 
	
--18. Profit margin 
SELECT
    ROUND(
        (SUM(profit) / NULLIF(SUM(total_sales), 0)) * 100,
        2
    ) AS profit_margin_percentage
FROM flipkart_sales_data;
