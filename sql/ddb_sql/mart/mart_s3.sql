CREATE TABLE mart.candidate_commitee_linkage (
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
  FOREIGN KEY (candidate_key) REFERENCES mart.candidate (internal_id)
);

INSERT INTO mart.candidate_commitee_linkage
(
  candidate_id,
  candidate_election_year,
  fec_election_year,
  committee_id,
  committee_type,
  committee_design,
  linkg_age,
  committee_key,
  candidate_key
)
SELECT
  link.candidate_id,
  link.candidate_election_year,
  link.fec_election_year,
  link.committee_id,
  link.committee_type,
  link.committee_design,
  link.linkg_age,
  committee.internal_id AS committee_fk,
  candidate.internal_id AS candidate_fk
FROM inter.candidate_commitee_linkage AS link
  INNER JOIN mart.committee AS committee
    ON link.committee_id = committee.committee_identification
  INNER JOIN mart.candidate AS candidate
    ON link.candidate_id = candidate.candidate_id;


CREATE INDEX  s_id4 ON mart.candidate_commitee_linkage (
  candidate_key
);
CREATE INDEX  s_id5 ON mart.candidate_commitee_linkage (
  committee_key
);
