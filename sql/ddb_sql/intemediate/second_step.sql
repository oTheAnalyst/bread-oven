/*      
        transaction_type,
        transaction_id,
        transaction_date,
        transaction_amount,
*/

DROP sequence if EXISTS joiner;
CREATE sequence joiner;
CREATE OR REPLACE TABLE inter.joiner_contributors_s2 AS 
with mega_contributors as (
SELECT
        committee_identification,
        'individual contribution'::varchar AS contribution_type,
        transaction_type,
        transaction_id,
        transaction_date,
        transaction_amount,
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
        'NA' as candidate_id,
        fec_record_number 

FROM
        inter.individual_contributions_s1
UNION ALL 
SELECT
        committee_identification,
        'one committee to another'::varchar AS contribution_type,
        transaction_type,
        transaction_id,
        transaction_date,
        transaction_amount,
        amendment_indicator,
        report_type,
        primary_general_indicator,
        image_number,
        entity_type,
        name as contributor_lender_name,
        city,
        state,
        zip_code,
        employer,
        occupation,
        memo_cd as memo_code,
        memo_text,
        'NA' as candidate_id,
        fec_record_number
FROM
        inter.one_commitee_to_another
UNION ALL
SELECT 
        committee_identification,
        'commitee to candidate'::varchar AS contribution_type,
        transaction_type,
        transaction_id,
        transaction_date,
        transaction_amount,
        amendment_indicator,
        report_type,
        primary_general_indicator,
        image_number,
        entity_type,
        name as contributor_lender_name,
        city,
        state,
        zip_code,
        employer,
        occupation,
        memo_code,
        memo_text,
        candidate_id,
        fec_record_number
FROM inter.commitees_to_canidates_s1
)
   select *,
        nextval('joiner')::bigint as internal_id
        from mega_contributors
;
alter table inter.joiner_contributors_s2
           add primary key (internal_id);
