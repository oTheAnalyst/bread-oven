INSERT INTO mart.transaction_facts 
(transaction_id, account_id, category_id, date_id, transaction_amount)
SELECT 
       t_type.transaction_type_id,
       act.account_id,
       cat_type.category_id,
       d.date_id,
       full_table.amount
FROM inter.full_table as full_table
JOIN mart.date d 
ON d.short_date = full_table.date
JOIN mart.transaction_type t_type 
ON t_type.account_type = full_table.transaction_type
JOIN mart.category cat_type 
ON cat_type.category_description = full_table.category
JOIN mart.account act 
ON act.account_type = full_table.account
;
