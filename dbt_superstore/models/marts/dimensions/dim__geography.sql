SELECT
ROW_NUMBER() OVER (ORDER BY country_region, city, postal_code) AS geography_key
,country_region AS country_region_bkey
,city AS city_bkey
,postal_code AS postal_code_bkey
,state
,region
,{{ dbt_utils.generate_surrogate_key([
    'country_region',
    'city',
    'postal_code',
]) }} AS rowhash_keys
,{{ dbt_utils.generate_surrogate_key([
    'state',
    'region',
]) }} AS rowhash_nonkeys
FROM {{ ref('stg__geography') }}