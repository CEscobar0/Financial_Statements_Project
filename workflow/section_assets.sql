CREATE MATERIALIZED VIEW section_assets AS

WITH assets_union AS (
    SELECT *, 1 AS order_process FROM account_cash
    UNION ALL
    SELECT *, 2 AS order_process FROM account_accounts_receivable
    UNION ALL
    SELECT *, 3 AS order_process FROM account_inventory
    UNION ALL
    SELECT *, 4 AS order_process FROM account_property_equipment
    UNION ALL
    SELECT 
        date_part('year', calendar_date) AS period_year,
        'Assets' AS account,
        0 AS total_amount,
        999 AS order_process
    FROM calendar
    GROUP BY date_part('year', calendar_date)
)
SELECT
    period_year,
    'Assets' AS section_bs,
    account,
    CASE
        WHEN order_process = 999 THEN SUM(total_amount) OVER(PARTITION BY period_year ORDER BY order_process)
        ELSE total_amount
        END AS total_amount
FROM assets_union;