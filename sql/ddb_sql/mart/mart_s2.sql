/*
Design the fact table
*/


-- "database".mart.fact_test definition
CREATE TABLE mart.donations (
  transaction_type VARCHAR,
  transaction_id VARCHAR,
  transaction_date DATE,
  transaction_amount DECIMAL(38, 2),
  committee_key BIGINT,
  candidate_key BIGINT,
  contributor_key BIGINT,
  FOREIGN KEY (committee_key) REFERENCES mart.committee (internal_id),
  FOREIGN KEY (candidate_key) REFERENCES mart.candidate (internal_id),
  FOREIGN KEY (contributor_key) REFERENCES mart.contributors (internal_id)
);

INSERT INTO mart.donations
(
  transaction_type, transaction_id,
  transaction_date, transaction_amount,
  committee_key, candidate_key, contributor_key
)
WITH fact AS (
  SELECT
    js2.candidate_id,
    js2.transaction_type,
    js2.transaction_id,
    js2.transaction_date,
    js2.transaction_amount,
    cmart.internal_id AS committee_key,
    can_mart.internal_id AS candidate_key,
    con_mart.internal_id AS contributor_key
  FROM inter.joiner_contributors_s2 AS js2
    INNER JOIN mart.committee AS cmart
      ON js2.committee_identification = cmart.committee_identification
    INNER JOIN mart.candidate AS can_mart
      ON js2.candidate_id = can_mart.candidate_id
    INNER JOIN mart.contributors AS con_mart
      ON js2.internal_id = con_mart.internal_id
)

SELECT
  transaction_type,
  transaction_id,
  transaction_date,
  transaction_amount,
  committee_key,
  candidate_key,
  contributor_key
FROM fact;

CREATE INDEX IF NOT EXISTS s_id1 ON mart.donations (candidate_key);
CREATE INDEX IF NOT EXISTS s_id2 ON mart.donations (committee_key);
CREATE UNIQUE INDEX IF NOT EXISTS s_id3 ON mart.donations (contributor_key);
