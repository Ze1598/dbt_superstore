WITH date_seed AS (
    SELECT 
        generate_series(
            '2010-01-01'::DATE,
            '2030-12-31'::DATE,
            '1 day'::INTERVAL
        )::DATE AS date_day
)
SELECT
TO_CHAR(date_day, 'YYYYMMDD')::INTEGER AS date_key,
date_day AS date_bkey,
EXTRACT(YEAR FROM date_day)::INTEGER AS year,
EXTRACT(QUARTER FROM date_day)::INTEGER AS quarter,
EXTRACT(MONTH FROM date_day)::INTEGER AS month,
EXTRACT(DAY FROM date_day)::INTEGER AS day,
EXTRACT(DOW FROM date_day)::INTEGER AS day_of_week,
EXTRACT(DOY FROM date_day)::INTEGER AS day_of_year,
EXTRACT(WEEK FROM date_day)::INTEGER AS week_of_year,
TO_CHAR(date_day, 'Month') AS month_name,
TO_CHAR(date_day, 'Day') AS day_name,
CASE 
    WHEN EXTRACT(DOW FROM date_day) IN (0, 6) 
    THEN TRUE 
    ELSE FALSE 
END AS is_weekend,
CASE 
    WHEN EXTRACT(DOW FROM date_day) NOT IN (0, 6) 
    THEN TRUE 
    ELSE FALSE 
END AS is_weekday
FROM date_seed