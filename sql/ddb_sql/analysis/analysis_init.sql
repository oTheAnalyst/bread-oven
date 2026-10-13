/*
When conducting this analysis its important to first lookup candidates on the fec website and see
if there are any direct committee or pac the candidate uses,
sometimes candidate names will not appear in a the database

### introduction
This analyis look up the candidate name and grabs the associated transaction

the stake holder seeks to answer the following question:
Of donations made, how many were made each day, and how much was donated each day?

What is the most likely hour of the day for someone to donate to a candidate in Tennessee,
and the most likely hour for someone in Tennessee to donate to any candidate?

Which candidate has recieved the most donations from each state?

Of donations made by committeees to candidates,
for each interest group type, for those applicable, what percentage of money went to democrats?

What committee donated the most to afton byne, (do the same for specifically leadership pacs)

What is the mean, median, mode, and varience of contributions from individuals?
*/-- 
-- this is an intial analysis to find the relevent candidates
SELECT
  donations.transaction_type,
  candidate.candidate_name,
  committee.committee_name,
  sum(donations.transaction_amount) AS amount
FROM
  mart.donations AS donations
  LEFT JOIN mart.committee AS committee
    ON donations.committee_key = committee.internal_id
  LEFT JOIN mart.candidate_commitee_linkage AS cc_linkage
    ON committee.internal_id = cc_linkage.committee_key
  LEFT JOIN mart.candidate AS candidate
    ON cc_linkage.candidate_key = candidate.internal_id
  LEFT JOIN mart.contributors AS contributors
    ON donations.contributor_key = contributors.internal_id
WHERE
  (
    candidate.candidate_name ILIKE '%behn%'
    OR candidate.candidate_name ILIKE '%van%epps%'
    OR committee.committee_name ILIKE '%unrigged%'
  )
  AND (
    donations.transaction_date BETWEEN (
      '2025-12-02'::DATE - INTERVAL 7 DAY
    ) AND '2025-12-02'::DATE
  )
GROUP BY
  ALL
ORDER BY
  committee.committee_name;

------------------------------------------------------------------------------------------
/* Of donations made, how many were made each day, and how much was donated each day? */ 
------------------------------------------------------------------------------------------
SELECT
  donations.transaction_date,
  committee.committee_name,
  sum(donations.transaction_amount) AS amount
FROM
  mart.donations AS donations
  LEFT JOIN mart.committee AS committee
    ON donations.committee_key = committee.internal_id
  LEFT JOIN mart.candidate_commitee_linkage AS cc_linkage
    ON committee.internal_id = cc_linkage.committee_key
  LEFT JOIN mart.candidate AS candidate
    ON cc_linkage.candidate_key = candidate.internal_id
  LEFT JOIN mart.contributors AS contributors
    ON donations.contributor_key = contributors.internal_id
WHERE
  (
    candidate.candidate_name ILIKE '%behn%'
    OR candidate.candidate_name ILIKE '%van%epps%'
    OR committee.committee_name ILIKE '%unrigged%'
    OR committee.committee_name ILIKE '%van%epps%'
  )
  AND (
    donations.transaction_date BETWEEN (
      '2025-12-02'::DATE - INTERVAL 7 DAY
    ) AND '2025-12-02'::DATE
  )
GROUP BY
  ALL
ORDER BY
  donations.transaction_date;

------------------------------------
/* donations by state ranked */
------------------------------------
WITH ranking AS (
  SELECT
    contributors.state,
    committee.committee_name,
    sum(donations.transaction_amount) AS dollars,
    count(*) AS donations
  FROM
    mart.donations AS donations
    LEFT JOIN mart.committee AS committee
      ON donations.committee_key = committee.internal_id
    LEFT JOIN mart.candidate_commitee_linkage AS cc_linkage
      ON committee.internal_id = cc_linkage.committee_key
    LEFT JOIN mart.candidate AS candidate
      ON cc_linkage.candidate_key = candidate.internal_id
    LEFT JOIN mart.contributors AS contributors
      ON donations.contributor_key = contributors.internal_id
  WHERE
    (
      candidate.candidate_name ILIKE '%behn%'
      OR candidate.candidate_name ILIKE '%van%epps%'
      OR committee.committee_name ILIKE '%unrigged%'
    )
    AND (
      donations.transaction_date
      BETWEEN ('2025-12-02'::DATE - INTERVAL 7 DAY) AND '2025-12-02'::DATE
    )
  GROUP BY
    ALL
)

SELECT
  *,
  rank()
    OVER (PARTITION BY committee_name ORDER BY dollars DESC)
    AS dollars_rank,
  rank()
    OVER (PARTITION BY committee_name ORDER BY donations DESC)
    AS donations_rank
FROM
  ranking
ORDER BY
  dollars_rank;


---------------------------------------------------
/* what committeee donated the most to aft bahn? */
---------------------------------------------------
SELECT
  donations.transaction_type,
  contributors.contributor_lender_name,
  sum(donations.transaction_amount) AS amount
-- candidate.candidate_name,
-- contributors.contribution_type,
-- committee.committee_name
FROM
  mart.donations AS donations
  LEFT JOIN mart.committee AS committee
    ON donations.committee_key = committee.internal_id
  LEFT JOIN mart.candidate_commitee_linkage AS cc_linkage
    ON committee.internal_id = cc_linkage.committee_key
  LEFT JOIN mart.candidate AS candidate
    ON cc_linkage.candidate_key = candidate.internal_id
  LEFT JOIN mart.contributors AS contributors
    ON donations.contributor_key = contributors.internal_id
WHERE
  (
    candidate.candidate_name ILIKE '%aft%behn%'
    OR committee.committee_name ILIKE '%unrigged%'
  )
  AND (
    donations.transaction_date BETWEEN (
      '2025-12-02'::DATE - INTERVAL 7 DAY
    ) AND '2025-12-02'::DATE
  )
  AND contributors.contribution_type ILIKE 'one committee to another'
--      AND contributors.contributor_lender_name
GROUP BY
  ALL
ORDER BY
  amount;

-------------------------------------------------------------
/* What is the mean, median, mode, and varience of contributions from individuals? */
-------------------------------------------------------------
SELECT
  contributors.contributor_lender_name AS name,
  sum(donations.transaction_amount) AS dollars_sum,
  count(donations.transaction_amount) AS count,
  round(mean(donations.transaction_amount), 2) AS dollars_mean,
  median(donations.transaction_amount) AS dollars_median,
  mode(donations.transaction_amount) AS dollars_mode
FROM
  mart.donations AS donations
  LEFT JOIN mart.committee AS committee
    ON donations.committee_key = committee.internal_id
  LEFT JOIN mart.candidate_commitee_linkage AS cc_linkage
    ON committee.internal_id = cc_linkage.committee_key
  LEFT JOIN mart.candidate AS candidate
    ON cc_linkage.candidate_key = candidate.internal_id
  LEFT JOIN mart.contributors AS contributors
    ON donations.contributor_key = contributors.internal_id
WHERE
  (
    candidate.candidate_name ILIKE '%behn%'
    OR candidate.candidate_name ILIKE '%van%epps%'
    OR committee.committee_name ILIKE '%unrigged%'
  )
  AND (
    donations.transaction_date BETWEEN ('2025-12-02'::DATE - INTERVAL 7 DAY)
    AND '2025-12-02'::DATE
  )
GROUP BY name
HAVING count > 2
ORDER BY dollars_sum DESC;

------------------------------------
/* Of donations made by committeees to candidates,
for each interest group type, for those applicable,
what percentage of money went to democrats? */
------------------------------------
WITH committee_dollars AS (
  SELECT
    committee.committee_party,
    sum(donations.transaction_amount) AS dollars_sum,
    count(donations.transaction_amount) AS count
  FROM
    mart.donations AS donations
    LEFT JOIN mart.committee AS committee
      ON donations.committee_key = committee.internal_id
    LEFT JOIN mart.candidate_commitee_linkage AS cc_linkage
      ON committee.internal_id = cc_linkage.committee_key
    LEFT JOIN mart.candidate AS candidate
      ON cc_linkage.candidate_key = candidate.internal_id
    LEFT JOIN mart.contributors AS contributors
      ON donations.contributor_key = contributors.internal_id
  WHERE
    (
      candidate.candidate_name ILIKE '%behn%'
      OR candidate.candidate_name ILIKE '%van%epps%'
      OR committee.committee_name ILIKE '%unrigged%'
    )
    -- AND (donations.transaction_date BETWEEN ('2025-12-02'::DATE - INTERVAL 7 DAY)
    -- AND '2025-12-02'::DATE)
    AND (
      contributors.contribution_type = 'commitee to candidate'
      OR contributors.contribution_type = 'one committee to another'
    )
  GROUP BY ALL
  ORDER BY dollars_sum DESC
),

running_total AS (
  SELECT
    dollars_sum,
    committee_party,
    sum(dollars_sum) OVER (
      ORDER BY committee_party RANGE BETWEEN UNBOUNDED PRECEDING
      AND CURRENT ROW
    ) AS t2
  FROM committee_dollars
)

SELECT
  round(dollars_sum / t2, 2) AS perc_rep,
  round(1 - dollars_sum / t2, 2) AS perc_dem
FROM running_total
GROUP BY ALL
LIMIT 1;
