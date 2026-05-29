-- Before performing any calculations, I need to ensure the index_value column is complete. 
-- If there are missing values, they could skew my average calculations.
--  I used COUNT(*) to identify if any records lack pricing data.
-- The Result: 0 (This confirms the data is complete and reliable for further analysis).

SELECT COUNT(*) 
FROM bc_housing_market 
WHERE index_value IS NULL;

-- I need to identify the temporal scope of the dataset to provide context for my analysis. 
-- I am using MIN to find the earliest entry and MAX to find the latest, 
-- using a comma to request both values simultaneously.

SELECT MIN(reporting_month) AS start_date, 
       MAX(reporting_month) AS end_date
FROM bc_housing_market;


-- To provide a current market assessment, I am isolating 
--  data from the last two years. This allows me to calculate the average 
-- index value by housing category, revealing which market segment is 
-- currently the strongest.

SELECT 
    index_type, 
    AVG(index_value) AS avg_recent_value
FROM bc_housing_market
WHERE reporting_month LIKE '2025%' 
   OR reporting_month LIKE '2026%'
GROUP BY index_type;

-- To calculate market momentum, I am comparing the average 
--  index values from 2025 to 2026 to determine the percentage growth rate.

SELECT 
    index_type,
    AVG(CASE WHEN reporting_month LIKE '2025%' THEN index_value END) AS avg_2025,
    AVG(CASE WHEN reporting_month LIKE '2026%' THEN index_value END) AS avg_2026,
    ((AVG(CASE WHEN reporting_month LIKE '2026%' THEN index_value END) - 
      AVG(CASE WHEN reporting_month LIKE '2025%' THEN index_value END)) / 
      AVG(CASE WHEN reporting_month LIKE '2025%' THEN index_value END)) * 100 AS growth_percentage
FROM bc_housing_market
GROUP BY index_type;


-- Thought Process: I am using conditional logic to classify market performance 
-- tiers, which helps stakeholders quickly identify high-value segments.

SELECT 
index_type,
AVG(index_value) AS avg_val,
CASE 
WHEN AVG(index_value) > 124 THEN 'High-Value Segment'
ELSE 'Standard Segment'
END AS performance_tier
FROM bc_housing_market
GROUP BY index_type;

-- I am isolating the single highest index value in the 
-- dataset to identify the record-breaking month and market category.

SELECT reporting_month, index_type, index_value
FROM bc_housing_market
WHERE index_value = (SELECT MAX(index_value) FROM bc_housing_market);
