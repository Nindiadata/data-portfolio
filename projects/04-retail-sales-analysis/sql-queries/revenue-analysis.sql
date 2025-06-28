-- Monthly revenue trends
SELECT
    DATE_TRUNC('month', order_date) as month,
    COUNT(*) as orders,
    ROUND(SUM(total_amount)::numeric, 2) as revenue,
    ROUND(AVG(total_amount)::numeric, 2) as aov
FROM orders
WHERE status = 'completed'
GROUP BY 1
ORDER BY 1;

-- Year-over-Year Growth
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) as month,
        SUM(total_amount) as revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY 1
)
SELECT
    month,
    revenue,
    LAG(revenue, 12) OVER (ORDER BY month) as revenue_last_year,
    ROUND(
        ((revenue - LAG(revenue, 12) OVER (ORDER BY month)) /
         LAG(revenue, 12) OVER (ORDER BY month) * 100)::numeric, 2
    ) as yoy_growth_percentage
FROM monthly_revenue
ORDER BY month; 
		 

