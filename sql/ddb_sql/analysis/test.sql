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
------- analysis test can we do it? ------
SELECT
        candidate_name
FROM
        inter.candidate_summary_s1
WHERE
        candidate_name ilike '%ep%'
GROUP BY
        ALL;
/*
114 rows returned
*/   -- 
SELECT
        mcan.candidate_name,
        mcom.committee_name
FROM
        mart.donations AS mdon
LEFT JOIN mart.committee AS mcom
        ON mdon.committee_key = mcom.internal_id
INNER JOIN mart.candidate_commitee_linkage AS ccl
        ON mcom.internal_id = ccl.committee_key
INNER JOIN mart.candidate AS mcan
        ON mcan.internal_id = ccl.committee_key
WHERE
        mdon.transaction_typeIN('10',
        '15',
        '15c',
        '24g',
        '24u')
        AND mcan.candidate_name ilike '%ep%'
GROUP BY
        ALL;
/*
1 row returned
*/
