
SET memory_limit = '7GB';
CREATE TABLE individual_contributions AS
SELECT
        *
FROM
        read_csv('./import/indiv26/by_date/*.txt');
