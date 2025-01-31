CREATE MATERIALIZED VIEW section_owners_equity AS

WITH oe_union AS (
    SELECT
        period_year,
        transaction_type AS account,
        total_amount,
        1 AS order_process
    FROM account_retained_earnings_details
    WHERE transaction_type = 'Retained Earnings'
    UNION ALL
    SELECT
        DISTINCT date_part('year', calendar_date) AS period_year,
        'Owners Equity' AS account,
        0 AS total_amount, 999 AS order_process
    FROM calendar
)
SELECT
    period_year,
    'Owners Equity' AS section_bs, account,
    CASE
        WHEN order_process = 999 THEN SUM(total_amount) OVER (PARTITION BY period_year)
        ELSE total_amount END AS total_amount
FROM oe_union;