-- PostgreSQL/Redshift compatible solution
INSERT INTO mart.date (short_date, weekday_name, day_month, month_name, quarter, year, weekday_number, month_number)
SELECT 
    date_series::DATE AS short_date,
    TO_CHAR(date_series, 'Day') AS weekday_name,
    EXTRACT(DAY FROM date_series)::INTEGER AS day_month,
    TO_CHAR(date_series, 'Month') AS month_name,
    EXTRACT(QUARTER FROM date_series)::INTEGER AS quarter,
    EXTRACT(YEAR FROM date_series)::INTEGER AS year,
    -- weekday_number: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    EXTRACT(DOW FROM date_series)::INTEGER + 1 AS weekday_number,
    EXTRACT(MONTH FROM date_series)::INTEGER AS month_number
FROM 
    generate_series(
        '2025-01-01'::DATE,
        '2030-12-31'::DATE,
        '1 day'::INTERVAL
    ) AS date_series;
