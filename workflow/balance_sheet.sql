CREATE MATERIALIZED VIEW balance_sheet AS

WITH balance_sheet AS (
    SELECT * FROM section_assets
    UNION ALL
    SELECT * FROM section_liabilities
    UNION ALL
    SELECT * FROM section_owners_equity
)
SELECT * FROM balance_sheet;