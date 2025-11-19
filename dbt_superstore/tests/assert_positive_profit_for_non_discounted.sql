-- Test: Orders without discounts should generally have positive profit
-- This is a business rule validation - we expect non-discounted orders to be profitable
-- Returns rows that FAIL the test (i.e., orders with no discount but negative profit)

SELECT
    order_key,
    product_key,
    customer_key,
    sales,
    discount,
    profit,
    ROUND(profit / NULLIF(sales, 0) * 100, 2) AS profit_margin_pct
FROM {{ ref('fct__orders') }}
WHERE discount = 0  -- No discount applied
  AND profit < 0    -- But profit is negative (unexpected!)
  AND sales > 0     -- Valid sales amount

-- If this test returns rows, investigate:
-- 1. Are these specific products always unprofitable?
-- 2. Is there a data quality issue in the source?
-- 3. Do we need to adjust our business rules?
