CREATE MATERIALIZED VIEW section_liabilities AS


WITH liabilities_union AS (
    SELECT *, 1 AS order_process FROM account_loan
    UNION ALL
    SELECT 
        date_part('year', calendar_date) AS period_year,
        'Liabilities' AS account,
        0 AS total_amount,
        999 AS order_process
    FROM calendar
    GROUP BY date_part('year', calendar_date)
)
SELECT
    period_year,
    'Liabilities' AS section_bs,
    account,
    CASE
        WHEN order_process = 999 THEN SUM(total_amount) OVER(PARTITION BY period_year ORDER BY order_process)
        ELSE total_amount
        END AS total_amount
FROM liabilities_union;