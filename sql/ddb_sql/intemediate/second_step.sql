/*
this is the second step:
get the requirements for the table joins 
from this analysis.

Aftyn Behn and Matt Vanepps’ transaction 
a week before December 2nd 2025 
transactions:
-10
-15c
-15
24u 
24g
tables
│ commitees_to_canidates_independent_expenditures_s1 │
│ individual_contributions_s1                        │
│ one_commitee_to_another
*/
---

SELECT sum(transaction_amount) as individual_spend, 
        state
FROM inter.individual_contributions_s1
WHERE date_status between 
('2025-12-02'::date - interval '1 week') 
and '2025-12-02'::date 
AND primary_general_indicator 
ilike 'S%' 
AND  transaction_type 
IN('10','15c','15','24u','24g')
GROUP BY state
ORDER BY individual_spend desc
;

SELECT sum(transaction_amount) as individual_spend, 
        state
FROM inter.one_commitees_to_another
WHERE date_status between 
('2025-12-02'::date - interval '1 week') 
and '2025-12-02'::date 
AND primary_general_indicator 
ilike 'S%' 
AND  transaction_type 
IN('10','15c','15','24u','24g')
GROUP BY state
ORDER BY individual_spend desc
;
