-- Test: Overall return rate should be below 30%
-- This is a business metric monitoring test
-- Returns a row if the return rate exceeds the threshold (test fails)

WITH return_metrics AS (
    SELECT
        COUNT(*) AS total_orders,
        COUNT(*) FILTER (WHERE is_returned = 1) AS returned_orders,
        COUNT(*) FILTER (WHERE is_returned = 1) * 1.0 / NULLIF(COUNT(*), 0) AS return_rate
    FROM {{ ref('fct__orders') }}
)

SELECT
    total_orders,
    returned_orders,
    ROUND(return_rate * 100, 2) AS return_rate_pct,
    10.0 AS threshold_pct,
    'Return rate exceeds acceptable threshold of 30%' AS failure_reason
FROM return_metrics
WHERE return_rate > 0.3  -- Fail if return rate > 30%

-- If this test fails, investigate:
-- 1. Has there been a recent spike in returns?
-- 2. Are specific products/categories driving returns?
-- 3. Is there a data quality issue with return flags?
