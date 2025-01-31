CREATE MATERIALIZED VIEW account_cash AS

WITH purchase_dates AS (
  SELECT CASE
      WHEN payment_method = 'cash' THEN payment_at
      ELSE payment_at + interval '1 month'
    END AS actual_payment_at,
    - SUM(quantity * amount) AS total_amount
  FROM purchases
  GROUP BY CASE
      WHEN payment_method = 'cash' THEN payment_at
      ELSE payment_at + interval '1 month'
    END
),
purchase AS (
  SELECT date_part('year', actual_payment_at) AS period_year,
    SUM(total_amount) AS total_amount
  FROM purchase_dates
  GROUP BY date_part('year', actual_payment_at)
),
revenue_dates AS (
  SELECT CASE
      WHEN payment_method = 'cash' THEN payment_at
      ELSE payment_at + interval '1 month'
    END AS actual_payment_at,
    SUM(quantity * price) AS total_amount
  FROM sales
  GROUP BY CASE
      WHEN payment_method = 'cash' THEN payment_at
      ELSE payment_at + interval '1 month'
    END
),
revenue AS (
  SELECT date_part('year', actual_payment_at) AS period_year,
    SUM(total_amount) AS total_amount
  FROM revenue_dates
  GROUP BY date_part('year', actual_payment_at)
),
loan_in AS (
  SELECT date_part('year', loan_at) AS period_year,
    SUM(value) AS total_amount
  FROM loans
  GROUP BY date_part('year', loan_at)
),
expenses AS (
  SELECT date_part('year', payment_date) AS period_year,
    - SUM(amount) AS total_amount
  FROM payments
  where payment_type in (
      'equipment',
      'wage',
      'rent',
      'utility',
      'tax',
      'loan',
      'interest'
    )
  GROUP BY date_part('year', payment_date)
),
cash_union AS (
  SELECT * FROM loan_in
  union all
  SELECT * FROM expenses
  union all
  SELECT * FROM purchase
  union all
  SELECT * FROM revenue
),
cash_amount AS (
  SELECT
    period_year,
    SUM(total_amount) AS total_amount
  FROM cash_union
  GROUP BY period_year
)
SELECT
  period_year,
  'Cash' account,
  SUM(total_amount) OVER(ORDER BY period_year) AS total_amount
FROM cash_amount;