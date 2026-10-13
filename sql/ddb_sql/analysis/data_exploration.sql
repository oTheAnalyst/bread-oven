/*
this is the second step:
get the requirements for the table joins
from this analysis.

Aftyn Behn and Matt Vanepps’ transaction
a week before December 2nd 2025
transactions:
10
15c
15
24u
24g
tables
│ commitees_to_canidates_independent_expenditures_s1 │
│ individual_contributions_s1                        │
│ one_commitee_to_another
*/--- SELECT sum(transaction_amount) as individual_spend, 
--        state
--FROM inter.individual_contributions_s1
--WHERE date_status between 
--('2025-12-02'::date - interval '1 week') 
--and '2025-12-02'::date 
--AND primary_general_indicator 
--ilike 'S%' 
--AND  transaction_type 
--IN('10','15c','15','24u','24g')
--GROUP BY state
--ORDER BY individual_spend desc
--;
--
--SELECT sum(transaction_amount) as individual_spend, 
--        state
--FROM inter.one_commitees_to_another
--WHERE date_status between 
--('2025-12-02'::date - interval '1 week') 
--and '2025-12-02'::date 
--AND primary_general_indicator 
--ilike 'S%' 
--AND  transaction_type 
--IN('10','15c','15','24u','24g')
--GROUP BY state
--ORDER BY individual_spend desc
--;
--
--
--SELECT candidate_name,
--       candidate_id
--       ending_cash 
--FROM inter.candidate_summary_s1
-- create temp table candidate_committee_research as
/*
gathering what candidates are available within the database and how much money there "candidate" pac received
*/--------------------
SELECT
        candidate.candidate_name,
        committee.committee_name,
        donations.transaction_type
FROM
        mart.donations AS donations
LEFT JOIN mart.committee AS committee
        ON donations.committee_key = committee.internal_id
LEFT JOIN mart.candidate_commitee_linkage AS cc_linkage
        ON committee.committee_identification = cc_linkage.committee_id
LEFT JOIN mart.candidate AS candidate
        ON cc_linkage.candidate_id = candidate.candidate_id
WHERE
        (candidate.candidate_name ILIKE '%behn%'
        OR candidate.candidate_name ILIKE '%van%epps%'
        OR committee.committee_name ILIKE '%unrigged%')-- only van epps was found in this result
--        AND donations.transaction_type IN ('10','15','15c','24g','24u')

GROUP BY
        ALL
ORDER BY
        committee.committee_name DESC,
        donations.transaction_type;
----------------------
/*
Next is committee to committee transaction
trying to gather a list of committee that support the candidate
*/----------------------
SELECT
        contributors.contributor_lender_name,
        contributors.primary_general_indicator,
        donations.transaction_date,
        donations.transaction_type,
        committee.committee_name
FROM
        mart.donations AS donations
INNER JOIN mart.committee AS committee
        ON donations.committee_key = committee.internal_id
INNER JOIN mart.candidate_commitee_linkage AS cc_linkage
        ON committee.committee_identification = cc_linkage.committee_id
INNER JOIN mart.candidate AS candidate
        ON cc_linkage.candidate_id = candidate.candidate_id
INNER JOIN mart.contributors AS contributors
        ON donations.contributor_key = contributors.internal_id
WHERE
        (candidate.candidate_name ILIKE '%behn%'
        OR candidate.candidate_name ILIKE '%van%epps%')
        AND (contributors.contribution_type = 'one committee to another'
        OR contributors.contribution_type = 'commitee to candidate')--AND donations.transaction_type 
--in( '10', '15c', '15', '24u', '24g')

GROUP BY
        ALL
ORDER BY
        donations.transaction_date;
SELECT
        SUM(donations.transaction_amount) AS amount,
        donations.transaction_type,
        committee.committee_name
FROM
        mart.donations AS donations
LEFT JOIN mart.committee AS committee
        ON donations.committee_key = committee.internal_id
LEFT JOIN mart.candidate_commitee_linkage AS cc_linkage
        ON committee.committee_identification = cc_linkage.committee_id
LEFT JOIN mart.candidate AS candidate
        ON cc_linkage.candidate_id = candidate.candidate_id
LEFT JOIN mart.contributors AS contributors
        ON donations.contributor_key = contributors.internal_id
WHERE
        (candidate.candidate_name ILIKE '%behn%'
        OR candidate.candidate_name ILIKE '%van%epps%'
        OR committee.committee_name ILIKE '%unrigged%')
        AND (donations.transaction_date BETWEEN ('2025-12-02'::DATE -INTERVAL 7DAY)
        AND '2025-12-02'::DATE)--        (candidate.candidate_name ILIKE '%behn%'
--        OR candidate.candidate_name ILIKE '%van%epps%')
--        AND (contributors.contribution_type = 'one committee to another'
--        OR contributors.contribution_type = 'commitee to candidate')--AND donations.transaction_type 
--in( '10', '15c', '15', '24u', '24g')

GROUP BY
        ALL;
/*
data is limited on vanepps to 2026 only.
Need to setup additional datapipelines to the this working
structure is sound simply need to do an insert to get the additional data.
*/SELECT
        contributors.contributor_lender_name,
        contributors.primary_general_indicator,
        donations.transaction_date,
        donations.transaction_type,
        committee.committee_name
FROM
        mart.donations AS donations
LEFT JOIN mart.committee AS committee
        ON donations.committee_key = committee.internal_id
LEFT JOIN mart.candidate_commitee_linkage AS cc_linkage
        ON committee.committee_identification = cc_linkage.committee_id
LEFT JOIN mart.candidate AS candidate
        ON cc_linkage.candidate_id = candidate.candidate_id
LEFT JOIN mart.contributors AS contributors
        ON donations.contributor_key = contributors.internal_id
WHERE
        --  (candidate.candidate_name ilike '%epps%' OR 
--    committee.committee_name ilike '%team%epps%')
committee.committee_name ILIKE '%american optometric%'
AND (contributors.contribution_type = 'one committee to another'
OR contributors.contribution_type = 'commitee to candidate')--AND donations.transaction_type 
--in( '10', '15c', '15', '24u', '24g')

GROUP BY
        ALL
ORDER BY
        donations.transaction_date;
-------------------
SELECT
        DATE_PART(
                'year',
                donations.transaction_date
        ) AS YEAR,
        COUNT(*) AS c
FROM
        mart.donations AS donations
GROUP BY
        ALL
ORDER BY
        ALL;
/*
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
        mdon.transaction_type IN ('10','15','15c','24g','24u')
        AND mcan.candidate_name ilike '%aftyn%behn%'

*//*
trying to do exploritory analysis on this dataset
SELECT
        COUNT()) AS t,
        fec_record_number
FROM
        inter.one_commitee_to_another
GROUP BY
        fec_record_number
HAVING
        t > 2
ORDER BY
        t DESC;
*/
