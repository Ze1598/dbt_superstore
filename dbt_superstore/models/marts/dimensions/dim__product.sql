SELECT
ROW_NUMBER() OVER (ORDER BY product_id) AS product_key
,product_id AS product_id_bkey
,product_name AS proudct_name_bkey
,category
,sub_category
,{{ dbt_utils.generate_surrogate_key([
    'product_id',
    'product_name'
]) }} AS rowhash_keys
,{{ dbt_utils.generate_surrogate_key([
    'category',
    'sub_category'
]) }} AS rowhash_nonkeys
FROM {{ ref('stg__product') }}