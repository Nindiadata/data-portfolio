-- Customer value segments
WITH customer_stats AS (
    SELECT
        customer_id,
        COUNT(*) as order_count,
        SUM(total_amount) as total_spent,
        MAX(order_date) as last_order,
        CURRENT_DATE - MAX(order_date)::date as days_since_last
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_spent > 2000000 AND order_count >= 5 THEN 'VIP'
        WHEN total_spent > 1000000 OR order_count >= 3 THEN 'Loyal'
        WHEN days_since_last <= 30 THEN 'Active'
        WHEN days_since_last <= 90 THEN 'Regular'
        ELSE 'At Risk'
    END as segment,
    COUNT(*) as customers,
    ROUND(AVG(total_spent)::numeric, 2) as avg_value
FROM customer_stats
GROUP BY 1
ORDER BY customers DESC;

-- RFM Analysis
WITH customer_metrics AS (
    SELECT
        customer_id,
        MAX(order_date) as last_order_date,
        COUNT(*) as frequency,
        SUM(total_amount) as monetary,
        CURRENT_DATE - MAX(order_date)::date as recency_days
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days DESC) as R_score,
        NTILE(5) OVER (ORDER BY frequency) as F_score,
        NTILE(5) OVER (ORDER BY monetary) as M_score
    FROM customer_metrics
),
customer_segments AS (
    SELECT *,
        CASE
            WHEN R_score >= 4 AND F_score >= 4 AND M_score >= 4 THEN 'Champions'
            WHEN R_score >= 4 AND F_score >= 3 THEN 'Loyal Customers'
            WHEN R_score >= 3 AND F_score <= 2 AND M_score >= 3 THEN 'Potential Loyalists'
            WHEN R_score >= 3 AND F_score <= 2 AND M_score <= 2 THEN 'New Customers'
            WHEN R_score <= 2 AND F_score >= 3 AND M_score >= 3 THEN 'At Risk'
            WHEN R_score <= 2 AND F_score >= 2 AND M_score <= 2 THEN 'Cannot Lose Them'
            WHEN R_score <= 2 AND F_score <= 2 AND M_score >= 3 THEN 'Hibernating'
            ELSE 'Lost'
        END as segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*) as customer_count,
    ROUND(AVG(monetary)::numeric, 2) as avg_monetary_value,
    ROUND(AVG(frequency)::numeric, 1) as avg_frequency,
    ROUND(AVG(recency_days)::numeric, 1) as avg_recency_days,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM customer_segments
GROUP BY segment
ORDER BY customer_count DESC;

