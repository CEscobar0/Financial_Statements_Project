CREATE MATERIALIZED VIEW income_statement AS

SELECT period_year,
       CASE WHEN transaction_type = 'Retained Earnings' THEN 'Net Income'
            ELSE transaction_type
       END AS transaction_type,
       total_amount
FROM account_retained_earnings_details;