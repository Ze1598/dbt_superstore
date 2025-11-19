SELECT
DISTINCT
CASE
    WHEN "Returned" = 'Yes'
    THEN 1
    ELSE 0
END AS is_returned
,"Order ID" AS order_id
FROM {{ source('raw', 'returns') }}