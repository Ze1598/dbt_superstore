SELECT
DISTINCT
"Product ID"::text AS product_id
,"Category"::text AS category
,"Product Name"::text AS product_name
,"Sub-Category"::text AS sub_category
FROM {{ source('raw', 'orders') }}