select * from waltmart;

select count(*) from waltmart;

select  payment_method,count(*)
from waltmart
group by payment_method;

select count(distinct Branch)
from waltmart;

select max(quantity) from waltmart;

select min(quantity) from waltmart;


-- business problems

-- Q.1 What are the different payment methods, and how many transactions and items were sold with each method?

select  payment_method,count(*) no_payments,sum(quantity) as no_qty_sold
from waltmart
group by payment_method;

-- Q.2 Which category received the highest average rating in each branch?

SELECT * FROM 
(
    SELECT 
        Branch,
        category,
        AVG(rating) AS average_rating, 
        RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rank_no
    FROM waltmart
    GROUP BY Branch, category
) AS ranked_data
WHERE rank_no = 1;

-- Q.3 What is the busiest day of the week for each branch based on transaction volume

SELECT * FROM 
(
    SELECT 
        Branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transaction,
        RANK() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rank_no
    FROM waltmart
    GROUP BY Branch, day_name
) AS ranked_data
WHERE rank_no = 1;

-- Q.4 How many items were sold through each payment method?

select  payment_method,sum(quantity) as no_qty_sold
from waltmart
group by payment_method;

-- Q.5  What are the average, minimum, and maximum ratings for each category in each city?

select city,category,min(rating) as minimum_rating, max(rating) as aximum_rating,avg(rating) as average_rating
from waltmart
group by city,category;

-- Q.6 What is the total profit for each category, ranked from highest to lowest?

select category,
		sum(total) as total_revenue,
        sum(total * profit_margin) as profit
from waltmart
group by category;

-- Q.7  What is the most frequently used payment method in each branch?

with cte
as 
( select 
		branch,
		payment_method, 
		count(*) as totsl_trans,
        RANK() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rank_no
from waltmart
group by branch,payment_method
)
select  * from  cte 
where rank_no = 1 ;  

-- Q.8 How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT Branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    COUNT(*) AS transaction_count
FROM waltmart
GROUP BY Branch,time_of_day
order by Branch,transaction_count;


-- Q.9 Which branches experienced the largest decrease in revenue compared to the previous year?

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM waltmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM waltmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue  -- Select only branches with decreased revenue
ORDER BY revenue_decrease_ratio DESC  -- Sort by highest revenue decrease
LIMIT 5;  -- Get top 5 branches with the highest revenue drop



