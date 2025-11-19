SELECT
ROW_NUMBER() OVER (ORDER BY order_id) AS order_key
,order_id AS order_bkey
,ship_mode
,segment
,{{ dbt_utils.generate_surrogate_key(['order_id']) }} AS rowhash_keys
,{{ dbt_utils.generate_surrogate_key([
    'ship_mode', 
    'segment'
]) }} AS rowhash_nonkeys
FROM {{ ref('stg__orders') }}