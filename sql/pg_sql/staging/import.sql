CREATE TABLE stg_imports(
        import_id BIGSERIAL PRIMARY KEY,
        import_dt TIMESTAMP NOT NULL,
        source_name VARCHAR,
        original_file_path VARCHAR,
        bucket_uri VARCHAR,
        md5_checksum VARCHAR
);
