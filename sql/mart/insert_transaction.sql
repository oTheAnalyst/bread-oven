INSERT INTO mart.transaction_type(
        transaction_type_id,
        account_type
)
SELECT 
       category_id,
        category
FROM inter.clean_transaction

