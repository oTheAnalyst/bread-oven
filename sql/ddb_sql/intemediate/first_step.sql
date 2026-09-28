/*
individual_contributions
data cleaning and organizing:
- only varchars and bigint.
- need to add a properly formatted datafield.
- need to id high cardnality attributes
- use a data dictionary to fill the columns
- data is date not timestamp
- https://www.fec.gov/campaign-finance-data/contributions-individuals-file-description/
- monitary transaction are decimal(38,2)s
*/
create schema IF NOT EXISTS inter;
SET memory_limit = '4GB';
create or replace table inter.individual_contributions_s1 as
select 
        column00 as committee_identification,
        column01 as amendment_indicator,
        column02 as report_type,
        column03 as primary_general_indicator,
        column04 as image_number,
        column05 as transaction_type,
        column06 as entity_type,
        lower(column07) as contributor_lender_name,
        column08 as city,
        column09 as state,
        column10 as zip_code,
        column11 as employer,
        column12 as occupation,
        strptime(column13, '%m%d%Y')::date as transaction_date,
        column14::decimal(38,2) as transaction_amount,
        column15 as other_id_number,
        column16 as transaction_id,
        column17::bigint as report_id,
        column18 as memo_code,
        column19 as memo_text,
        column20::bigint as fec_record_number
from stg.individual_contributions;

create or replace table inter.commitees_to_canidates_s1 as
SELECT 
        column00 as committee_identification,
        column01 as amendment_indicator,
        column02 as report_type,
        column03 as primary_general_indicator,
        column04 as image_number,
        column05 as transaction_type,
        column06 as entity_type,
        lower(column07) as name,
        column08 as city,
        column09 as state,
        column10 as zip_code,
        column11 as employer,
        column12 as occupation,
        strptime(column13, '%m%d%Y')::date as transaction_date,
        column14::decimal(38,2) as transaction_amount,
        column15 as other_id_number,
        column16 as candidate_id,
        column17 as transaction_id,
        column18::int as file_number,
        column19 as memo_code,
        column20 as memo_text,
        column21::bigint as fec_record_number
FROM stg.committees_to_canidates_independent_expenditures;


create or replace table inter.one_commitee_to_another as
SELECT  
        column00 as committee_identification,
        column01 as amendment_indicator,
        column02 as report_type,
        column03 as primary_general_indicator,
        column04 as image_number,
        column05 as transaction_type,
        column06 as entity_type,
        lower(column07) as name,
        column08 as city,
        column09 as state,
        column10 as zip_code,
        column11 as employer,
        column12 as occupation,
        strptime(column13, '%m%d%Y')::date as transaction_date,
        column14::decimal(38,2) as transaction_amount,
        column15 as other_id_number,
        column16 as transaction_id,
        column17::int as file_number,
        column18 as memo_cd,
        column19 as memo_text,
        column20::bigint as fec_record_number
FROM stg.one_commitee_to_another;

create or replace table inter.candidate_summary_s1 as
select
        column00 as candidate_id,
        lower(column01) as candidate_name,
        column02 as incumbent_challenger_status,
        column03 as party_code,
        column04 as party_affiliation,
        column05::decimal(38,2) as total_receipts,
        column06::decimal(38,2) as transfers_from_authorized_committees,
        column07::decimal(38,2) as total_disbursements,
        column08::decimal(38,2) as transfers_to_authorized_committees,
        column09::decimal(38,2) as beginning_cash,
        column10::decimal(38,2) as ending_cash,
        column11::decimal(38,2) as contributions_from_candidate,
        column12::decimal(38,2) as loans_from_candidate,
        column13::decimal(38,2) as other_loans,
        column14::decimal(38,2) as candidate_loan_repayment,
        column15::decimal(38,2) as other_loan_repayments,
        column16::decimal(38,2) as debts_owed_by,
        column17::decimal(38,2) as total_individual_contributions,
        column18 as candidate_state,
        column19 as candidate_district,
        column20 as special_election_status,
        column21 as primary_election_status,
        column22 as runoff_election_status,
        column23 as general_election_status,
        column24 as general_election_percentage,
        column25 as contribution_from_other_politcal_committees,
        column26 as contribution_from_party_committees,
        column27 as coverage_end_date,
        column28::decimal(38,2) as refunds_to_individuals,
        column29::decimal(38,2) as refunds_to_committees
FROM stg.candidate_summary;

create or replace table inter.committee_master_s1 as
select 
        column00 as committee_identification,
        column01 as committee_name,
        column02 as treasurer_name,
        column03 as street_one,
        column04 as street_two,
        column05 as city_or_town,
        column06 as state,
        column07 as zip_code,
        column08 as committee_designation,
        column09 as committee_type,
        column10 as committee_party,
        column11 as filing_frequency,
        column12 as interest_group_category,
        column13 as connected_organization_name,
        column14 as candidate_id
FROM stg.committee_master;




