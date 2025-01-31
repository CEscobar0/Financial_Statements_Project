CREATE MATERIALIZED VIEW account_loan AS

WITH loan_in AS (
  SELECT date_part('year', loan_at) AS period_year,
    SUM(value) AS total_amount
  FROM loans
  GROUP BY date_part('year', loan_at)
),
loan_payment AS (
  SELECT date_part('year', payment_date) AS period_year,
    - SUM(amount) AS total_amount
  FROM payments
  where payment_type in (
      'loan'
    )
  GROUP BY date_part('year', payment_date)
),
loan_union AS (
  SELECT * FROM loan_in
  UNION ALL
  SELECT * FROM loan_payment
),
loan_amount AS (
  SELECT
    period_year,
    SUM(total_amount) AS total_amount
  FROM loan_union
  GROUP BY period_year
),
loan AS (
  SELECT
  period_year,
  'Loan' AS account,
  SUM(total_amount) OVER (ORDER BY period_year) AS total_amount
FROM loan_amount
)
SELECT * FROM loan