CREATE MATERIALIZED VIEW account_retained_earnings_details AS

WITH revenue AS (
    SELECT
        date_part('year', payment_at) AS period_year,
        'Revenue' AS transaction_type,
        1 as order_process,
        SUM(quantity * price) AS total_amount
    FROM sales
    GROUP BY date_part('year', payment_at) 
),
product_price AS (
    SELECT DISTINCT
        product_name,
        amount
    FROM purchases
),
cogs AS (
    SELECT
        date_part('year', payment_at) AS period_year,
        'Cost of Goods Sold' AS transaction_type,
        2 AS order_process,
        - SUM(s.quantity * p.amount) AS total_amount
    FROM sales s
    LEFT JOIN product_price p
        ON s.product_name = p.product_name
    GROUP BY date_part('year', payment_at)
),
depreciation_dates AS (
    SELECT
        id,
        payment_date,
        calendar_date,
        calendar_year AS period_year,
        CASE
            WHEN calendar_year = date_part('year', payment_date + INTERVAL '10 years')
            AND calendar_month = date_part('month', payment_date) THEN 1
            WHEN calendar_month = 12 THEN 1
            ELSE 0 END flag_1_year,
        amount / COUNT(*) OVER(PARTITION BY id) AS installments
    FROM
        calendar
    CROSS JOIN
        payments
    WHERE
        calendar_date >= payment_date
        AND calendar_date <= payment_date + INTERVAL '10 years'
        AND payment_type = 'equipment'
        AND id = 66
),
depreciation_sum AS (
    SELECT *,
    SUM(installments) OVER(PARTITION BY id ORDER BY calendar_date) AS depreciation_amount
FROM depreciation_dates
),
depreciation AS (
    SELECT
        period_year,
        'Depreciation' AS transaction_type,
        3 AS order_process,
        SUM(depreciation_amount) AS total_amount
    FROM depreciation_sum
    GROUP BY period_year
),
expenses AS (
  SELECT
    date_part('year', payment_date) AS period_year,
    CASE
        WHEN payment_type = 'wage' THEN 'Wage Expeses'
        WHEN payment_type IN ('rent', 'utility') THEN 'Operational Expeses'
        WHEN payment_type = 'tax' THEN 'Tax Expeses'
        WHEN payment_type = 'interest' THEN 'Interest Expeses'
        END AS transaction_type,
    CASE
        WHEN payment_type = 'wage' THEN 6
        WHEN payment_type IN ('rent', 'utility') THEN 7
        WHEN payment_type = 'tax' THEN 4
        WHEN payment_type = 'interest' THEN 5
        END AS order_process,
    - SUM(amount) AS total_amount
  FROM payments
  where payment_type in (
      'wage',
      'rent',
      'utility',
      'tax',
      'interest'
    )
  GROUP BY
    date_part('year', payment_date),
    CASE
        WHEN payment_type = 'wage' THEN 'Wage Expeses'
        WHEN payment_type IN ('rent', 'utility') THEN 'Operational Expeses'
        WHEN payment_type = 'tax' THEN 'Tax Expeses'
        WHEN payment_type = 'interest' THEN 'Interest Expeses'
        END,
    CASE
        WHEN payment_type = 'wage' THEN 6
        WHEN payment_type IN ('rent', 'utility') THEN 7
        WHEN payment_type = 'tax' THEN 4
        WHEN payment_type = 'interest' THEN 5
        END
),
re_union AS (
    SELECT * FROM revenue
    UNION ALL
    SELECT * FROM cogs
    UNION ALL
    SELECT * FROM depreciation
    UNION ALL
    SELECT * FROM expenses
    UNION ALL
    SELECT
        DISTINCT date_part('year', calendar_date) AS period_year,
        'Retained Earnings - Beginning Balance' AS transaction_type,
        0 AS order_process,
        0 AS total_amount
    FROM
        calendar
    UNION ALL
    SELECT
        DISTINCT date_part('year', calendar_date) AS period_year,
        'Retained Earnings' AS transaction_type,
        999 AS order_process,
        0 AS total_amount
    FROM calendar
),
re_details AS (
    SELECT
        period_year,
        transaction_type,
        ROUND (
            CASE
                WHEN order_process = 0 or order_process = 999 THEN SUM(total_amount) OVER (ORDER BY period_year, order_process)
                ELSE total_amount
                END
            , 2) AS total_amount
    FROM re_union
)
SELECT * FROM re_details