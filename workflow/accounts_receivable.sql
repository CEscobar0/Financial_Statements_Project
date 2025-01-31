CREATE MATERIALIZED VIEW account_accounts_receivable AS

SELECT
    date_part('year', payment_at) AS period_year,
    'Accounts Receivable' AS account,
    SUM(price * quantity) AS total_amount
FROM sales
WHERE
    payment_method <> 'cash'
    AND date_part('month', payment_at) =  12
GROUP BY
    date_part('year', payment_at)