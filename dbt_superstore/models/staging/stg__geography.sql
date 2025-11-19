SELECT
DISTINCT
"Country/Region"::text AS country_region
,"City"::text AS city
,"State"::text AS state
,COALESCE("Postal Code"::text, '0000') AS postal_code
,"Region"::text AS region
FROM {{ source('raw', 'orders') }}