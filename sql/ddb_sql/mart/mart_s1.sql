CREATE schema if NOT EXISTS mart;
/*
create the candidate dimension
*/DROP sequence if EXISTS candidate;
CREATE sequence candidate START WITH 1increment BY 3;
CREATE
OR REPLACE TABLE mart.candidate AS SELECT
        candidate_id,
        candidate_name,
        incumbent_challenger_status,
        party_code,
        party_affiliation,
        total_receipts,
        transfers_from_authorized_committees,
        total_disbursements,
        transfers_to_authorized_committees,
        beginning_cash,
        ending_cash,
        contributions_from_candidate,
        loans_from_candidate,
        other_loans,
        candidate_loan_repayment,
        other_loan_repayments,
        debts_owed_by,
        total_individual_contributions,
        candidate_state,
        candidate_district,
        special_election_status,
        primary_election_status,
        runoff_election_status,
        general_election_status,
        general_election_percentage,
        contribution_from_other_politcal_committees,
        contribution_from_party_committees,
        coverage_end_date,
        refunds_to_individuals,
        refunds_to_committees,
        nextval('candidate')::BIGINT AS internal_id
FROM
        inter.candidate_summary_s1;
ALTER TABLE if EXISTS mart.candidate ADD PRIMARY KEY(internal_id);
CREATE UNIQUE INDEX candidate_inx
ON mart.candidate(internal_id);
/*
This is the committee dimension
*/DROP sequence if EXISTS committee;
CREATE sequence committee START WITH 30increment BY 2;
CREATE
OR REPLACE TABLE mart.committee AS SELECT
        committee_identification,
        committee_name,
        treasurer_name,
        street_one,
        street_two,
        city_or_town,
        state,
        zip_code,
        committee_designation,
        committee_type,
        committee_party,
        filing_frequency,
        interest_group_category,
        connected_organization_name,
        candidate_id,
        nextval('committee') ::BIGINT AS internal_id
FROM
        inter.committee_master_s1;
ALTER TABLE if EXISTS mart.committee ADD PRIMARY KEY(internal_id);
CREATE UNIQUE INDEX committee_inx
ON mart.committee(internal_id);
/*
Individual Contributions Dimension
*/DROP sequence if EXISTS individual;
CREATE sequence individual;
CREATE
OR REPLACE TABLE mart.contributors AS 
with mega_contributors as (
SELECT 
       committee_identification
        , contribution_type
        , amendment_indicator
        , report_type
        , primary_general_indicator
        , image_number
        , entity_type
        , contributor_lender_name
        , city
        , state
        , zip_code
        , employer
        , occupation
        , memo_code
        , memo_text
        , candidate_id
        , fec_record_number
        , internal_id
FROM inter.joiner_contributors_s2
)
   select *
        from mega_contributors
;

ALTER TABLE if EXISTS mart.contributors 
ADD PRIMARY KEY(internal_id);

CREATE UNIQUE INDEX indiv_inx
ON mart.contributors(internal_id);
/*
removed these from , they are suppose to go into 
the fact table

        transaction_type,
        transaction_id,
        transaction_date,
        transaction_amount,
        transaction_date,
        transaction_amount,
        other_id_number, maybe this is like report id
        transaction_id,
        file_number,
       * report_id, * -individual contributors
        c to can
        transaction_type,
        transaction_date,
        transaction_amount,
        transaction_id,
        other_id_number 

        file_number,
*/
