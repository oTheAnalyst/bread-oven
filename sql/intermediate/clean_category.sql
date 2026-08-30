DROP SEQUENCE IF EXISTS category_id;
DROP TABLE IF EXISTS inter.clean_category;
CREATE SEQUENCE IF NOT EXISTS category_id;
CREATE TABLE inter.clean_category AS WITH cte AS (
        SELECT
                category
        FROM
                inter.full_table
        GROUP BY
                category
) SELECT
        nextval('category_id')::INT AS category_id,
        CASE WHEN category in('restaurants',
                               'food & dining',
                               'coffee shops',
                                'alcolhol & bars',
                               'fast food')
                THEN 'restaurants'::VARCHAR ELSE
                cte.category::VARCHAR END AS category_description,
        CASE
                WHEN cte.category IN(
                        'paycheck',
                        'income',
                        'taxes',
                        'federal tax',
                        'student loan',
                        'groceries',
                        'doctor',
                        'mortgage & rent'
                ) THEN 1
                ELSE 0
        END AS category_essential
FROM
        cte;
SELECT
        *
FROM
        inter.clean_category;
