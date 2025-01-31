CREATE MATERIALIZED VIEW account_inventory AS

WITH purchase_dates AS (
    SELECT CASE
            WHEN payment_method = 'cash' THEN payment_at
            ELSE payment_at + interval '1 month'
        END AS actual_payment_at,
        SUM(quantity * amount) AS total_amount
    FROM purchases
    GROUP BY CASE
            WHEN payment_method = 'cash' THEN payment_at
            ELSE payment_at + interval '1 month'
        END
),
purchase AS (
    SELECT
        date_part('year', actual_payment_at) AS period_year,
        SUM(total_amount) AS total_amount
    FROM purchase_dates
    GROUP BY date_part('year', actual_payment_at)
),
product_price AS (
    SELECT DISTINCT
        product_name,
        amount
    FROM purchases
),
sale AS (
    SELECT
        date_part('year', payment_at) AS period_year,
        - SUM(s.quantity * p.amount) AS total_amount
    FROM sales s
    LEFT JOIN product_price p
        ON s.product_name = p.product_name
    GROUP BY date_part('year', payment_at)
),
inventory_union AS (
    SELECT *
    FROM purchase
    UNION ALL
    SELECT *
    FROM sale
),
inventory_sum AS (
    SELECT
        period_year,
        SUM(total_amount) AS total_amount
    FROM inventory_union
    GROUP BY period_year
),
inventory AS (
    SELECT period_year,
    'Inventory' AS account,
    SUM(total_amount) OVER(ORDER BY period_year) AS total_amount
    FROM inventory_sum
)
SELECT * FROM inventory