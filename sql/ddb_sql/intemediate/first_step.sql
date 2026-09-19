/*
individual_contributions
data cleaning and organizing:
- only varchars and bigint.
- need to add a properly formatted datafield.
- need to id high cardnality attributes
- use a data dictionary to fill the columns
- data is date not timestamp
- https://www.fec.gov/campaign-finance-data/contributions-individuals-file-description/
*/
create schema IF NOT EXISTS inter;
SET memory_limit = '4GB';
create or replace table inter.individual_contributions_s1 as
select 
        column00 as cmt_id,
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
        strptime(column13, '%m%d%Y')::date as date_status,
        column14::bigint as transaction_amount,
        column15 as other_id_number,
        column16 as transaction_id,
        column17::bigint as report_id,
        column18 as memo_code,
        column19 as memo_text,
        column20::bigint as fec_record_number
from stg.individual_contributions_mega_with_invalid_date;

create or replace table inter.commitees_to_canidates_independent_expenditures_s1 as
SELECT 
        column00 as cmt_id,
        column01 as amendment_indicator,
        column02 as report_type,
        column03 as transaction_pgi,
        column04 as image_num,
        column05 as transcation_tp,
        column06 as entity_tp,
        lower(column07) as name,
        column08 as city,
        column09 as state,
        column10 as zip_code,
        column11 as employer,
        column12 as occupation,
        strptime(column13, '%m%d%Y')::date as transaction_date,
        column14::int as transaction_amount,
        column15 as other_id,
        column16 as cand_id,
        column17 as tran_id,
        column18::int as file_num,
        column19 as memo_cd,
        column20 as memo_text,
        column21::bigint as sub_id
FROM stg.committees_to_canidates_independent_expenditures;


create or replace table inter.one_commitee_to_another as
SELECT  
        column00 as cmt_id,
        column01 as amendment_indicator,
        column02 as report_type,
        column03 as transaction_pgi,
        column04 as image_num,
        column05 as transcation_tp,
        column06 as entity_tp,
        lower(column07) as name,
        column08 as city,
        column09 as state,
        column10 as zip_code,
        column11 as employer,
        column12 as occupation,
        strptime(column13, '%m%d%Y')::date as transaction_date,
        column14::int as transaction_amount,
        column15 as other_id,
        column16 as tran_id,
        column17::int as file_num,
        column18 as memo_cd,
        column19 as memo_text,
        column20::bigint as sub_id
FROM stg.one_commitee_to_another;

