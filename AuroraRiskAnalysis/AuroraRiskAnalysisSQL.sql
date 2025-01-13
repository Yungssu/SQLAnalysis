-- CREATING cards_data TABLE
CREATE TABLE cards_data_table (
	card_id VARCHAR(255),
    client_id VARCHAR(255),
    card_brand VARCHAR(255),
    card_type VARCHAR(255),
    card_number VARCHAR(16),
    card_expiration DATE,
    cvv INT,
    has_chip CHAR(3),
    num_cards_issued INT,
    credit_limit DECIMAL(10, 2),
    acct_open_date DATE,
    year_pin_last_changed YEAR
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/AuroraRiskAnalysis/cards_dataCSV.csv'
INTO TABLE cards_data_table
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- CREATING users_data TABLE
CREATE TABLE users_data_table (
	user_id VARCHAR(255),
    current_age VARCHAR(3),
    retirement_age VARCHAR(3),
    birth_date VARCHAR(10),
    gender VARCHAR(6),
    address VARCHAR(255),
    longitude FLOAT,
    latitude FLOAT,
    per_capita_income INT,
	yearly_income INT,
    total_debt INT,
	credit_score INT,
    num_credit_cards VARCHAR(2)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/AuroraRiskAnalysis/users_dataCSV.csv'
INTO TABLE users_data_table
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- CREATING users_data TABLE
CREATE TABLE transactions_data_table (
	transaction_id INT,
    transaction_date DATE,
    client_id INT,
    card_id INT,
    transaction_amount DECIMAL(10, 2),
    use_chip VARCHAR(50),
    merchant_id INT,
    merchant_city VARCHAR(50),
    merchant_state VARCHAR(50),
	merchant_zip INT,
    mcc INT,
	transaction_error VARChAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/AuroraRiskAnalysis/transactions_dataCSV.csv'
INTO TABLE transactions_data_table
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- CREATING cards_data TABLE
CREATE TABLE mcc_codes_table (
	mcc_id INT,
    mcc_description VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/AuroraRiskAnalysis/mcc_codesCSV.csv'
INTO TABLE mcc_codes_table
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- "Evaluate transaction volumes by merchant categories (MCC) or locations"
SELECT
	t.transaction_id,
    t.client_id,
    t.card_id,
    t.transaction_date,
    t.transaction_amount,
    t.transaction_error,
    c.credit_limit,
    u.credit_score,
    u.total_debt,
    u.yearly_income,
    m.mcc_description
FROM
	transactions_data_table AS t
LEFT JOIN
	cards_data_table AS c ON t.card_id = c.card_id
LEFT JOIN
	users_data_table AS u ON t.client_id = u.user_id
LEFT JOIN
	mcc_codes_table AS m ON t.mcc = m.mcc_id
WHERE 
	t.transaction_error IS NOT NULL -- Failed transaction
    OR t.transaction_amount > c.credit_limit * 0.9 -- High-risk transactions close to credit limit
    OR u.credit_score < 600 -- Low credit score
    OR u.total_debt > u.yearly_income * 0.5 -- High debt-to-income ratio
ORDER BY
	t.transaction_date DESC;

-- SPENDING PATTERNS
-- Spending Patterns by Merchant Categories
SELECT
	m.mcc_description AS merchant_category,
    COUNT(t.transaction_id) AS transaction_volume,
    SUM(t.transaction_amount) AS total_spent
FROM
	transactions_data_table AS t
LEFT JOIN
	mcc_codes_table AS m ON t.mcc = m.mcc_id
/*  
WHERE
	t.transaction_date BETWEEN '2024-01-01' AND '2024-12-31'
*/
GROUP BY
	m.mcc_description
ORDER BY
	total_spent DESC;
    
-- Spending Patterns by Locations(City)
SELECT
	t.merchant_city AS city,
    COUNT(t.transaction_id) AS transaction_volume,
    SUM(t.transaction_amount) AS total_spent
FROM
	transactions_data_table AS t
/*  
WHERE
	t.transaction_date BETWEEN '2024-01-01' AND '2024-12-31'
*/
GROUP BY
	t.merchant_city
ORDER BY
	total_spent DESC;
    
-- High Spending Regions
SELECT
	merchant_state,
    merchant_city,
    COUNT(transaction_id) AS transaction_volume,
    SUM(transaction_amount) AS total_spent
FROM 
	transactions_data_table
GROUP BY
	merchant_state, merchant_city
ORDER BY
	total_spent DESC
LIMIT 10;
    
-- Location Prone to Failed Transactions
UPDATE transactions_data_table
SET transaction_error = NULL
WHERE transaction_error = 'NULL';

SELECT 
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN transaction_error IS NULL THEN 1 ELSE 0 END) AS null_transactions,
    SUM(CASE WHEN transaction_error IS NOT NULL THEN 1 ELSE 0 END) AS not_null_transactions
FROM 
    transactions_data_table;

SELECT 
    transaction_error,
    COUNT(*) AS error_count
FROM 
    transactions_data_table
WHERE 
    transaction_error IS NOT NULL
GROUP BY 
    transaction_error
ORDER BY 
    error_count DESC;
    
SELECT 
    merchant_state,
    merchant_city,
    COUNT(transaction_id) AS total_transactions,
    SUM(CASE WHEN transaction_error IS NOT NULL THEN 1 ELSE 0 END) AS failed_transactions,
    ROUND(
        SUM(CASE WHEN transaction_error IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(transaction_id), 
        2
    ) AS failure_rate
FROM 
    transactions_data_table
GROUP BY 
    merchant_state, merchant_city
HAVING 
    failed_transactions > 0
ORDER BY 
    failure_rate DESC, failed_transactions DESC;


-- Combined Analysis
SELECT
	merchant_state,
	merchant_city,
    SUM(transaction_amount) AS total_spent,
    COUNT(transaction_id) AS total_transactions,
    SUM(CASE WHEN transaction_error IS NOT NULL THEN 1 ELSE 0 END) AS failed_transactions,
    ROUND(
		SUM(CASE WHEN transaction_error IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(transaction_id),
        2
    ) AS failure_rate
FROM
	transactions_data_table
GROUP BY
	merchant_state, merchant_city
HAVING
	failed_transactions > 0
ORDER BY
	total_spent DESC, failure_rate DESC
LIMIT 10;


SELECT 
    transaction_error, 
    COUNT(*) AS occurrences
FROM 
    transactions_data_table
GROUP BY 
    transaction_error;

SELECT *
FROM transactions_data_table
WHERE transaction_error IS NOT NULL AND transaction_error <> '';

UPDATE transactions_data_table
SET transaction_error = NULL
WHERE transaction_error IN ('NULL', 'Success', '');

-- ERROR TRENDS
-- Extracting and Counting Individual Errors
SELECT
	error_type, COUNT(*) AS occurances
FROM (
	SELECT
		TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(transaction_error, ';', numbers.n), ';', -1)) AS error_type
	FROM
		transactions_data_table
	JOIN (
		SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        ) numbers ON CHAR_LENGTH(transaction_error) - CHAR_LENGTH(REPLACE(transaction_error, ';', '')) >= numbers.n - 1
	WHERE transaction_error IS NOT NULL
	) AS error_list
GROUP BY
	error_type
ORDER BY
	occurances DESC;
    
-- Error Trends Over Time
SELECT
	transaction_date,
    COUNT(transaction_id) AS total_transactions,
    SUM(CASE WHEN transaction_error IS NOT NULL THEN 1 ELSE 0 END) AS total_errors,
    ROUND(SUM(CASE WHEN transaction_error IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(transaction_id), 2) AS error_rate
FROM
	transactions_data_table
GROUP BY
	transaction_date
ORDER BY
	transaction_date;

-- Correlate Errors with Merchants
SELECT
	merchant_id,
    COUNT(transaction_id) AS total_transactions,
    SUM(CASE WHEN transaction_error IS NOT NULL THEN 1 ELSE 0 END) AS total_errors,
    ROUND(SUM(CASE WHEN transaction_error IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(transaction_id), 2) AS error_rate
FROM
	transactions_data_table
GROUP BY
	merchant_id
ORDER BY
	total_errors DESC, error_rate DESC
LIMIT 10;

-- HIGH-VALUE TRANSACTIONS
-- Calculate the Threshold using Statistical Metrics
SELECT
	 transaction_amount
FROM
	transactions_data_table
WHERE
	transaction_amount > 10000
ORDER BY
	transaction_amount DESC;
    
SELECT 
    AVG(transaction_amount) AS mean_transaction_amount,
    STDDEV(transaction_amount) AS stddev_transaction_amount,
    MIN(transaction_amount) AS min_transaction_amount,
    MAX(transaction_amount) AS max_transaction_amount
FROM 
    transactions_data_table;

-- For median, first, and third quartiles:
SELECT 
    transaction_amount AS median_transaction_amount
FROM (
    SELECT transaction_amount, 
           ROW_NUMBER() OVER (ORDER BY transaction_amount) AS row_num,
           COUNT(*) OVER () AS total_rows
    FROM transactions_data_table
) subquery
WHERE row_num = FLOOR(total_rows / 2); -- Replace "2" for first and third quartiles

WITH ordered_transactions AS (
    SELECT 
        transaction_id,
        transaction_amount,
        ROW_NUMBER() OVER (ORDER BY transaction_amount) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM 
        transactions_data_table
),
quartiles AS (
    SELECT 
        MAX(CASE WHEN row_num <= total_rows / 4 THEN transaction_amount END) AS first_quartile,
        MAX(CASE WHEN row_num <= total_rows * 3 / 4 THEN transaction_amount END) AS third_quartile
    FROM 
        ordered_transactions
)
SELECT 
    t.transaction_id, 
    t.transaction_amount
FROM 
    transactions_data_table t
CROSS JOIN 
    quartiles q
WHERE 
    t.transaction_amount > (q.third_quartile + 1.5 * (q.third_quartile - q.first_quartile))
ORDER BY 
    t.transaction_amount DESC;


    
-- CREDIT RISK
-- Identifying Customers at Risk of Default
SELECT
	user_id,
    current_age,
    retirement_age,
    yearly_income,
    total_debt,
    ROUND(total_debt * 100.0 / yearly_income, 2) AS debt_to_income_ratio,
    credit_score,
		CASE
			WHEN ROUND(total_debt * 100.0 / yearly_income, 2) > 40 AND credit_score < 600 THEN 'High Risk'
            WHEN ROUND(total_debt * 100.0 / yearly_income, 2) > 40 THEN 'Moderate Risk'
            ELSE 'Low Risk'
		END AS risk_level
FROM
	users_data_table
WHERE
	yearly_income > 0
ORDER BY
	debt_to_income_ratio DESC, credit_score ASC
LIMIT 20;

-- DEBT DISTRIBUTION
SELECT
	CASE
		WHEN total_debt = 0 THEN 'No Debt'
        WHEN total_debt BETWEEN 1 AND 5000 THEN 'Low Debt (1-5K)'
        WHEN total_debt BETWEEN 5001 AND 20000 THEN 'Moderate Debt (5K-20K)'
        WHEN total_debt BETWEEN 20001 AND 50000 THEN 'High Debt (20K-50K)'
        ELSE 'Very High Debt (>50K)'
    END AS debt_bracket,
    COUNT(user_id) as customer_count,
    ROUND(AVG(total_debt), 2) AS avg_debt,
    ROUND(SUM(total_debt), 2) AS total_debt_in_bracket
FROM
	users_data_table
GROUP BY
	debt_bracket
ORDER BY
	total_debt_in_bracket DESC;

