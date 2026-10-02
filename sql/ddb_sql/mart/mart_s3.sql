-- "database".inter.candidate_commitee_linkage definition
CREATE TABLE mart.candidate_commitee_linkage(
        candidate_id VARCHAR,
        candidate_election_year INTEGER,
        fec_election_year INTEGER,
        committee_id VARCHAR,
        committee_type VARCHAR,
        committee_design VARCHAR,
        linkg_age INTEGER,
        committee_key BIGINT,
        candidate_key BIGINT,
  FOREIGN KEY (committee_key) REFERENCES mart.committee (internal_id),
  FOREIGN KEY (candidate_key) REFERENCES mart.candidate (internal_id),
);

INSERT INTO mart.candidate_commitee_linkage
(         candidate_id
        , candidate_election_year
        , fec_election_year
        , committee_id
        , committee_type
        , committee_design
        , linkg_age
        , committee_key
        , candidate_key
        )
SELECT
          link.candidate_id
        , link.candidate_election_year
        , link.fec_election_year
        , link.committee_id
        , link.committee_type
        , link.committee_design
        , link.linkg_age
        , mcom.internal_id
        , mcan.internal_id
FROM inter.candidate_commitee_linkage as link
inner join mart.committee as mcom
ON link.committee_id = mcom.committee_identification
inner join mart.candidate as mcan
ON link.candidate_id = mcan.candidate_id
;


CREATE  INDEX IF NOT EXISTS s_id4 ON mart.candidate_commitee_linkage (candidate_key);
CREATE  INDEX IF NOT EXISTS s_id5 ON mart.candidate_commitee_linkage (committee_key);
