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
(transaction_type, transaction_id, 
  transaction_date, transaction_amount, 
  committee_key, candidate_key, contributor_key
)
with fact as (
SELECT 
        js2.candidate_id,
        js2.transaction_type,
        js2.transaction_id,
        js2.transaction_date,
        js2.transaction_amount,
        cmart.internal_id as committee_key,
        can_mart.internal_id as candidate_key,
        con_mart.internal_id as contributor_key
FROM inter.joiner_contributors_s2 as js2
inner join mart.committee as cmart
on js2.committee_identification = cmart.committee_identification
inner join mart.candidate as can_mart
on js2.candidate_id  = can_mart.candidate_id
inner join mart.contributors as con_mart
on js2.internal_id  = con_mart.internal_id
) select  
        transaction_type,
        transaction_id,
        transaction_date,
        transaction_amount,
        committee_key,
        candidate_key,
        contributor_key
        from fact
;

CREATE  INDEX IF NOT EXISTS s_id1 ON mart.donations (candidate_key);
CREATE  INDEX IF NOT EXISTS s_id2 ON mart.donations (committee_key);
CREATE  UNIQUE INDEX IF NOT EXISTS s_id3 ON mart.donations (contributor_key);

