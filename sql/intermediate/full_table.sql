DROP SEQUENCE "serial";
CREATE SEQUENCE IF NOT EXISTS "serial";
CREATE TABLE inter.full_table AS 
WITH cte AS (
        SELECT "Amount", "Date","Category", "Original Description", 'checking' as account FROM staging.checking 
        GROUP BY"Amount","Date", "Category", "Original Description"
        UNION 
        SELECT"Amount","Date", "Category", "Original Description", 'tax_account' as account FROM staging.tax_account 
        GROUP BY"Amount","Date", "Category", "Original Description" 
        UNION 
        SELECT"Amount","Date", "Category", "Original Description", 'true_saving' as account FROM staging.true_saving 
        GROUP BY"Amount","Date", "Category", "Original Description"

        ), cte2 as
        (SELECT
           nextval('serial') as account_id,
           account,
           trim(lower("Category")) as category, 
           trim(lower("Original Description")) as original_description,
           "Amount" as amount,
           "Date" as date
           --nextval('serial') AS category_id
          FROM cte 
         --GROUP BY "Category", "Original Description","Amount","Date", "account_id";
        ) 
        select 
          account_id, 
          category, 
          original_description, 
          amount, 
          account,
          date,
        CASE 
           WHEN category = 'interest income' THEN 'interest income'
           WHEN category = 'transfer' THEN 'transfer'
           WHEN amount < 0 THEN 'credit'
           WHEN amount > 0 THEN 'debit'
                END as transaction_type
         FROM cte2;
