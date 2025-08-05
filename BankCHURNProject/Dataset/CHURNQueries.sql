-- CREATING  TABLE
CREATE TABLE customer_info_data_table (
	customer_id VARCHAR(255),
    surname VARCHAR(255),
    credit_score INT,
	geography VARCHAR(255),
    gender VARCHAR(16),
    age INT,
    tenure INT,
    estimated_salary DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CustomerCHURNAnalysis/customer_info.csv'
INTO TABLE customer_info_data_table
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


CREATE TABLE account_info_data_table (
	customer_id VARCHAR(255),
    balance DOUBLE,
    num_of_products INT,
	has_cr_card VARCHAR(3),
	tenure INT,
    is_active_member VARCHAR(3),
    exited INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CustomerCHURNAnalysis/account_info.csv'
INTO TABLE account_info_data_table
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- CLEANING OF CUSTOMER_info DATA
SELECT customer_id, COUNT(*) as count 
FROM customer_info_data_table
GROUP BY customer_id
HAVING count(*) > 1;

SELECT *
FROM customer_info_data_table
WHERE customer_id = 15628319;

DELETE FROM customer_info_data_table
WHERE customer_id = 15628319
LIMIT 1;

UPDATE customer_info_data_table
SET geography = 'France'
WHERE geography = 'FRA';

SELECT geography FROM customer_info_data_table
GROUP BY geography;

SELECT * FROM customer_info_data_table;

DELETE FROM customer_info_data_table
WHERE surname = '';

UPDATE customer_info_data_table
SET surname = TRIM(surname)
WHERE surname IS NOT NULL;

SELECT surname FROM customer_info_data_table
WHERE surname REGEXP '[^a-zA-Z0-9 ]';

SELECT COUNT(surname) FROM customer_info_data_table
WHERE surname LIKE '%?%';

SELECT COUNT(*) FROM customer_info_data_table;

DELETE FROM customer_info_data_table
WHERE surname LIKE '%?%';

SELECT * FROM customer_info_data_table;

-- CLEANING OF ACCOUNT_info DATA
SELECT * FROM account_info_data_table;

SELECT customer_id, COUNT(*) as count 
FROM account_info_data_table
GROUP BY customer_id
HAVING count(*) > 1;

SELECT *
FROM account_info_data_table
WHERE customer_id = 15634602;

DELETE FROM account_info_data_table
WHERE customer_id = 15634602
LIMIT 1;

SELECT *
FROM account_info_data_table
WHERE customer_id = 15628319;

DELETE FROM account_info_data_table
WHERE customer_id = 15628319
LIMIT 1;

SELECT * FROM account_info_data_table;

UPDATE account_info_data_table
SET has_cr_card = CASE
	WHEN has_cr_card = 'Yes' THEN  1
    WHEN has_cr_card = 'No' THEN 0 
    ELSE NULL
END;

UPDATE account_info_data_table
SET is_active_member = CASE
	WHEN is_active_member = 'Yes' THEN  1
    WHEN is_active_member = 'No' THEN 0 
    ELSE NULL
END;

-- EXPLORATORY DATA ANALYSIS
SELECT * FROM customer_info_data_table AS c
 JOIN account_info_data_table AS a
	on c.customer_id = a.customer_id;
    
SELECT COUNT(*) FROM customer_info_data_table AS c
JOIN account_info_data_table AS a
	on c.customer_id = a.customer_id;
    
DESCRIBE customer_info_data_table;
DESCRIBE account_info_data_table;

SELECT COUNT(*), exited FROM account_info_data_table
GROUP BY exited;

-- Q1. What attributes are more common among churners than non-churners?
SELECT a.exited,
    AVG(c.age) AS avg_age,
    AVG(c.estimated_salary) AS avg_estimated_salary,
    AVG(a.balance) AS avg_balance,
    AVG(c.credit_score) AS avg_credit_score,
    AVG(a.tenure) AS avg_tenure
FROM customer_info_data_table AS c
 JOIN account_info_data_table AS a
	ON c.customer_id = a.customer_id
GROUP BY a.exited;

SELECT a.exited, c.gender, COUNT(*)
FROM customer_info_data_table AS c
	JOIN account_info_data_table AS a
		ON c.customer_id = a.customer_id
GROUP BY a.exited, c.gender;

SELECT a.exited, a.has_cr_card, a.is_active_member, COUNT(*)
FROM customer_info_data_table AS c
	JOIN account_info_data_table AS a
		ON c.customer_id = a.customer_id
GROUP BY a.exited, a.has_cr_card, a.is_active_member;

SELECT a.exited, c.geography, COUNT(*)
FROM customer_info_data_table AS c
	JOIN account_info_data_table AS a
		ON c.customer_id = a.customer_id
GROUP BY a.exited, c.geography;

SELECT a.exited, AVG(a.num_of_products) AS avg_num_of_products
FROM customer_info_data_table AS c
	JOIN account_info_data_table AS a
		ON c.customer_id = a.customer_id
GROUP BY a.exited;

-- CHURN RATE
SELECT c.geography,
	SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) AS churned,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM customer_info_data_table AS c
	JOIN account_info_data_table AS a
		ON c.customer_id = a.customer_id
GROUP BY c.geography
ORDER BY churn_rate_pct DESC;

SELECT c.gender,
	SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) AS churned,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM customer_info_data_table AS c
	JOIN account_info_data_table AS a
		ON c.customer_id = a.customer_id
GROUP BY c.gender
ORDER BY churn_rate_pct DESC;

SELECT a.has_cr_card, 
	   a.is_active_member,
			SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) AS churned,
			COUNT(*) AS total,
			ROUND(SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM customer_info_data_table AS c
	JOIN account_info_data_table AS a
		ON c.customer_id = a.customer_id
GROUP BY a.has_cr_card, a.is_active_member
ORDER BY churn_rate_pct DESC;

SELECT a.tenure, 
			SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) AS churned,
			COUNT(*) AS total,
			ROUND(SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM customer_info_data_table AS c
	JOIN account_info_data_table AS a
		ON c.customer_id = a.customer_id
GROUP BY a.tenure
ORDER BY churn_rate_pct DESC;

SELECT a.num_of_products,
	SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) AS churned,
	COUNT(*) AS total,
	ROUND(SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM customer_info_data_table AS c
	JOIN account_info_data_table AS a
		ON c.customer_id = a.customer_id
GROUP BY a.num_of_products
ORDER BY churn_rate_pct DESC;

-- Q4: Is there a difference between German, French, and Spanish customers in terms of account behavior?
SELECT
    AVG(c.age) AS avg_age,
    AVG(c.estimated_salary) AS avg_estimated_salary,
    AVG(a.balance) AS avg_balance,
    AVG(c.credit_score) AS avg_credit_score,
    AVG(a.tenure) AS avg_tenure,
    c.geography,
	ROUND(SUM(CASE WHEN a.exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM customer_info_data_table AS c
 JOIN account_info_data_table AS a
	ON c.customer_id = a.customer_id
GROUP BY c.geography;

-- Q5: What types of segments exist within the bank's customers?
SELECT num_of_products, COUNT(*) AS customer_count,
	ROUND(SUM(CASE WHEN exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM account_info_data_table
GROUP BY num_of_products
ORDER BY num_of_products;

SELECT 
		CASE WHEN balance = 0 THEN 'No Balance'
			 WHEN balance <= 50000 THEN 'Low Balance'
			 WHEN balance <= 150000 THEN 'Mid Balance'
		ELSE 'High Balance'
	END AS balance_segment,
	COUNT(*) AS customer_count,
	ROUND(SUM(CASE WHEN exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM account_info_data_table
GROUP BY balance_segment
ORDER BY customer_count DESC;

SELECT
		CASE WHEN tenure = 0 THEN 'New Customer'
			 WHEN tenure BETWEEN 3 AND 6 THEN 'Mid Term'
		ELSE 'Loyal'
		END AS tenure_segment,
	COUNT(*) AS customer_count,
	ROUND(SUM(CASE WHEN exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM account_info_data_table
GROUP BY tenure_segment
ORDER BY customer_count DESC;

SELECT
	CASE WHEN is_active_member = 0 AND num_of_products = 1 THEN 'High Risk'
		 WHEN is_active_member = 1 AND num_of_products >= 2 THEN 'Low Risk'
	ELSE 'Moderate Risk'
    END AS churn_risk_segment,
	COUNT(*) AS customer_count,
	ROUND(SUM(CASE WHEN exited = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM account_info_data_table
GROUP BY churn_risk_segment;



