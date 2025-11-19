SELECT
DISTINCT
"Order ID"::text AS order_id
,"Ship Mode"::text AS ship_mode
,"Segment"::text AS segment
FROM {{ source('raw', 'orders') }}