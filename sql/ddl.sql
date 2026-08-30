DROP SCHEMA IF EXISTS staging CASCADE;
DROP SCHEMA IF EXISTS inter CASCADE;
DROP SCHEMA IF EXISTS mart CASCADE;



CREATE SCHEMA staging;
CREATE SCHEMA inter;
CREATE SCHEMA mart;

CREATE TABLE staging.stg_imports (
    import_id serial PRIMARY KEY,
    import_dt timestamp NOT NULL,
    source_name varchar,
    original_file_path varchar,
    bucket_uri varchar,
    md5_checksum varchar
);

CREATE TABLE mart.account (
    account_id serial PRIMARY KEY,
    account_type varchar(45),
    account_description varchar(200)
);

CREATE TABLE mart.transaction_type (
    transaction_type_id serial PRIMARY KEY,
    account_type varchar(70)
);

CREATE TABLE mart.category (
    category_id serial PRIMARY KEY,
    category_description varchar(100),
    category_essential smallint
);

-- Create the calendar table
CREATE TABLE mart.date (
    date_id serial PRIMARY KEY,
    short_date date,
    weekday_name varchar(9) NOT NULL,
    day_month integer NOT NULL,
    month_name varchar(9) NOT NULL,
    quarter integer NOT NULL,
    year integer NOT NULL,
    weekday_number integer NOT NULL,
    month_number integer NOT NULL
);

CREATE TABLE mart.transaction_facts (
    transaction_id int NOT NULL REFERENCES mart.transaction_type (
        transaction_type_id
    ),
    account_id int NOT NULL REFERENCES mart.account (account_id),
    category_id int NULL REFERENCES mart.category (category_id),
    date_id int NOT NULL REFERENCES mart.date (date_id),
    transaction_amount decimal NOT NULL
);

CREATE INDEX fk_transactions_accounts_idx ON mart.transaction_facts (
    account_id
);
CREATE INDEX fk_transactions_categories1_idx ON mart.transaction_facts (
    category_id
);
CREATE INDEX fk_transactions_date1_idx ON mart.transaction_facts (date_id);
