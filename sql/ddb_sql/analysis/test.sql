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
        mart.candidate
WHERE
        candidate_name ilike '%behn%'
GROUP BY
        ALL;
/*
114 rows returned
*/-- 
WITH test AS (
        SELECT
                mcan.candidate_name,
                mcom.committee_name
        FROM
                mart.donations AS mdon
        INNER JOIN mart.committee AS mcom
                ON mdon.committee_key = mcom.internal_id
        INNER JOIN mart.candidate_commitee_linkage AS ccl
                ON mcom.committee_identification = ccl.committee_id
        INNER JOIN mart.candidate AS mcan
                ON mcan.candidate_id = ccl.candidate_id
        GROUP BY
                ALL
) SELECT
        candidate_name,
        COUNT(*) AS c
FROM
        test
GROUP BY
        ALL
ORDER BY
        c DESC
LIMIT 10/*
1 row returned
*/
