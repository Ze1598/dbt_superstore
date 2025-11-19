SELECT
d.date_bkey AS order_date
,d.month AS order_month
,d.year AS order_year
,g.state AS geography_state
,p.category AS product_category
,c.customer_name
,sales
,quantity
,discount
,profit
,is_returned
FROM {{ ref('fct__orders') }} f 

LEFT JOIN {{ ref('dim__date') }} d
ON f.date_order_key = d.date_key

LEFT JOIN {{ ref('dim__geography') }} g
ON f.geography_key = g.geography_key

LEFT JOIN {{ ref('dim__product') }} p
ON f.product_key = p.product_key

LEFT JOIN {{ ref('dim__customer') }} c
ON f.customer_key = c.customer_key