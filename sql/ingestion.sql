INSTALL postgres;
LOAD postgres;
ATTACH 'dbname=bread user=pretender host=localhost' AS postgres_db(TYPE postgres);
CREATE
OR REPLACE TABLE postgres_db.staging.true_saving AS SELECT
        *
FROM
        read_csv('./ingest/true_savings.csv');
CREATE
OR REPLACE TABLE postgres_db.staging.checking AS SELECT
        *
FROM
        read_csv('./ingest/checking.csv');
CREATE
OR REPLACE TABLE postgres_db.staging.tax_account AS SELECT
        *
FROM
        read_csv('./ingest/tax_account.csv');
