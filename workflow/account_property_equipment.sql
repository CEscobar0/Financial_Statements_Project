CREATE MATERIALIZED VIEW account_property_equipment AS

WITH depreciation_dates AS (
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
        SUM(depreciation_amount) AS total_amount
    FROM depreciation_sum
    GROUP BY period_year
),
ple_purchase AS (
    SELECT date_part('year', payment_date) AS period_year,
    SUM(amount) AS total_amount
    FROM payments
    WHERE payment_type = 'equipment'
    GROUP BY date_part('year', payment_date)
),
ple_union AS (
    SELECT *
    FROM depreciation
    UNION ALL
    SELECT *
    FROM ple_purchase
),
ple_sum AS (
    SELECT
        period_year,
        SUM(total_amount) AS total_amount
    FROM ple_union
    GROUP BY period_year
),
property_equipment AS (
    SELECT
        period_year,
        'Property, Land and Equipment' AS account,
        ROUND(SUM(total_amount) OVER(ORDER BY period_year), 2) AS total_amount
    FROM ple_sum
)
SELECT * FROM property_equipment;