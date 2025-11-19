SELECT
--dim order
"Order ID" AS order_id
--dim product
,"Product ID" AS product_id
,"Product Name" AS product_name
--dim geography
,"Country/Region" AS country_region
,"City" AS city
,COALESCE("Postal Code"::text, '0000') AS postal_code
--dim customer
,"Customer ID" AS customer_id
--fact
,TO_CHAR("Order Date", 'YYYYMMDD')::integer AS order_date_numeric
,TO_CHAR("Ship Date", 'YYYYMMDD')::integer AS ship_date_numeric
,"Sales"::integer AS sales
,"Quantity"::integer AS quantity
,"Discount"::decimal AS discount
,"Profit"::decimal AS profit
FROM {{ source('raw', 'orders') }}