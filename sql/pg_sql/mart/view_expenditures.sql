CREATE VIEW mart.expenditures AS
with cte as (
SELECT 
        extract(YEAR from short_date) as year,
       date.month_number, 
       date.short_date, 
       tfacts.transaction_amount,
       ttype.account_type
FROM mart.transaction_facts as tfacts
INNER JOIN mart.date
ON date.date_id = tfacts.date_id
INNER JOIN mart.transaction_type as ttype 
ON ttype.transaction_type_id = tfacts.transaction_id
)
  select 
        month_number, 
        year,
        sum(transaction_amount) as amount_per_month
  from cte 
  WHERE account_type in('credit')
  GROUP by month_number, year
  ORDER BY month_number

