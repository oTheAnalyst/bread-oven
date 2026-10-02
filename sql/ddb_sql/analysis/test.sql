/*
transaction test
*/SELECT
        m.transaction_id,
        m.transaction_amount AS a,
        m.transaction_date,
        c.committee_party,
        c.committee_name
FROM
        mart.donations AS m
JOIN mart.committee AS c
        ON m.committee_key = c.internal_id
WHERE
        transaction_id = 'SA11AI.4102'
ORDER BY
        a DESC;
