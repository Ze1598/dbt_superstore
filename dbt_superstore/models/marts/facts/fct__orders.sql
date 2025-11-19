SELECT
d_customer.customer_key
,d_geography.geography_key
,d_product.product_key
,d_order.order_key
,ord.order_date_numeric AS date_order_key
,ord.ship_date_numeric AS date_ship_key
,ord.sales
,ord.quantity
,ord.discount
,ord.profit
,COALESCE(ret.is_returned, 0) AS is_returned
FROM {{ ref('stg__orders_transactions') }} AS ord

LEFT JOIN {{ ref('stg__returns') }} ret
ON ord.order_id = ret.order_id

LEFT JOIN {{ ref('dim__customer') }} AS d_customer
ON ord.customer_id = d_customer.customer_bkey

LEFT JOIN {{ ref('dim__geography') }} AS d_geography
ON ord.country_region = d_geography.country_region_bkey
AND ord.city = d_geography.city_bkey
AND ord.postal_code = d_geography.postal_code_bkey

LEFT JOIN {{ ref('dim__order') }} AS d_order
ON ord.order_id = d_order.order_bkey

LEFT JOIN {{ ref('dim__product') }} AS d_product
ON ord.product_id = d_product.product_id_bkey
AND ord.product_name = d_product.proudct_name_bkey