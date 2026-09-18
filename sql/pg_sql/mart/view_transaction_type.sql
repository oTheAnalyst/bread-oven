CREATE VIEW mart.transaction_monthly AS 
with cte as(
   SELECT 
          extract(YEAR from short_date) as year,
          date.month_number, 
          date.short_date, 
          tfacts.transaction_amount,
          ttype.account_type,
          cat.category_description
   FROM mart.transaction_facts as tfacts
   INNER JOIN mart.date
   ON date.date_id = tfacts.date_id
   INNER JOIN mart.transaction_type as ttype 
   ON ttype.transaction_type_id = tfacts.transaction_id
   INNER JOIN mart.category as cat 
   ON cat.category_id = tfacts.category_id
), cte2 as( 
  SELECT 
        category_description,
        month_number,
        sum(transaction_amount) as amount
   FROM cte
   WHERE account_type = 'credit'
   GROUP BY category_description, month_number
   ORDER BY month_number desc
)
SELECT  
        month_number,
        rank() over(PARTITION BY month_number order by amount asc),
        amount,
        category_description
FROM cte2


