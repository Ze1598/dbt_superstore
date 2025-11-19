SELECT
ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key
,customer_id AS customer_bkey
,customer_name
,{{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS rowhash_keys
,{{ dbt_utils.generate_surrogate_key([
    'customer_name'
]) }} AS rowhash_nonkeys
FROM {{ ref('stg__customer') }}