SELECT
  contributors.fec_record_number,
  donations.transaction_type,
  committee.committee_name,
  donations.transaction_id,
  donations.transaction_date,
  contributors.contributor_lender_name,
  committee.committee_identification,
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
--  (
--    candidate.candidate_name ILIKE '%aft%behn%'
--    OR committee.committee_name ILIKE '%unrigged%'
--  )
--  AND (
--    donations.transaction_date BETWEEN (
--      '2025-12-02'::DATE - INTERVAL 7 DAY
--    ) AND '2025-12-02'::DATE
--  )

   committee.committee_identification = 'C00887174'
  --AND contributors.contribution_type ILIKE 'one committee to another'
   AND contributors.contributor_lender_name = 'aftyn behn for congress'
GROUP BY
  ALL
ORDER BY
  amount DESC;
