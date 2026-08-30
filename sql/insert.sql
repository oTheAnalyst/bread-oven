INSTALL postgres;
LOAD postgres;
ATTACH 'dbname=bread user=pretender host=localhost' AS postgres_db(TYPE postgres);
INSERT INTO postgres_db.staging.true_saving SELECT
        *
FROM
        read_csv('./ingest/true_savings.csv');
INSERT INTO postgres_db.staging.checking SELECT
        *
FROM
        read_csv('./ingest/checking.csv');
INSERT INTO postgres_db.staging.tax_account SELECT
        *
FROM
        read_csv('./ingest/tax_account.csv');
