-- Top products by revenue
SELECT
    p.name,
    p.brand,
    c.name as category,
    SUM(oi.quantity) as units_sold,
    SUM(oi.total_price) as revenue
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'completed'
GROUP BY p.id, p.name, p.brand, c.name
ORDER BY revenue DESC
LIMIT 10;

-- Category Performance
SELECT
    c.name as category,
    COUNT(DISTINCT p.id) as products_count,
    COALESCE(SUM(oi.quantity), 0) as units_sold,
    COALESCE(ROUND(SUM(oi.total_price)::numeric, 2), 0) as total_revenue,
    COALESCE(ROUND(AVG(oi.unit_price)::numeric, 2), 0) as avg_price,
    ROUND(
        COALESCE(SUM(oi.total_price), 0) * 100.0 /
        SUM(SUM(oi.total_price)) OVER (), 2
    ) as revenue_percentage
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'completed'
GROUP BY c.id, c.name
ORDER BY total_revenue DESC;

