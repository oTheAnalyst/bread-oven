DROP SEQUENCE transaction_id;
DROP TABLE inter.clean_transaction;
CREATE SEQUENCE transaction_id;
CREATE TABLE inter.clean_transaction AS 
WITH cte AS (
        SELECT
                transaction_type
        FROM
                inter.full_table
        GROUP BY
                transaction_type
) SELECT
        cte.transaction_type AS category,
        nextval('transaction_id') AS category_id
FROM
        cte
WHERE
        transaction_type IN(
                'transfer',
                'debit',
                'credit',
                'interest income'
        );
