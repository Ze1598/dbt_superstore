SELECT
DISTINCT
"Customer ID"::text AS customer_id
,"Customer Name"::text AS customer_name
FROM {{ source('raw', 'orders') }}