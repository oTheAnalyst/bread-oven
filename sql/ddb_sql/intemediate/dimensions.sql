CREATE schema if NOT EXISTS mart;
/*
create the candidate dimension
*/
drop sequence if exists candidate;
create sequence candidate start with 1 increment by 3;

CREATE OR REPLACE TABLE mart.candidate as 
select
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
        nextval('candidate')::bigint as internal_id
FROM inter.candidate_summary_s1;

ALTER TABLE if exists mart.candidate
add primary key(internal_id);

CREATE UNIQUE INDEX 
candidate_inx ON mart.candidate (internal_id);

/*
This is the committee dimension
*/

drop sequence if exists committee;
create sequence committee start with 30 increment by 2;

CREATE OR REPLACE TABLE mart.committee as 
select 
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
        nextval('committee')::bigint as internal_id
FROM inter.committee_master_s1;

ALTER TABLE if exists mart.committee
add primary key(internal_id);

CREATE UNIQUE INDEX 
committee_inx ON mart.committee (internal_id);

/*
Individual Contributions Dimension
*/

drop sequence if exists individual;
create sequence individual start with 30 increment by 2;

CREATE OR REPLACE TABLE mart.individual_contributors
as 
SELECT
        committee_identification,
        amendment_indicator,
        report_type,
        primary_general_indicator,
        image_number,
        entity_type,
        contributor_lender_name,
        city,
        state,
        zip_code,
        employer,
        occupation,
        memo_code,
        memo_text,
        other_id_number,
        report_id,
        fec_record_number,
        nextval('individual')::bigint as internal_id
FROM
        inter.individual_contributions_s1;

ALTER TABLE if exists mart.individual
add primary key(internal_id);

CREATE UNIQUE INDEX 
individual_inx ON mart.individual_contributors (internal_id);

/*
removed these from , they are suppose to go into 
the fact table

        transaction_type,
        transaction_id,
        transaction_date,
        transaction_amount,
*/
