# 🚀 **AuroraSQL Customer Profiling & Risk Analysis**

## 📜 **Project Overview**

The **AuroraSQL Customer Profiling & Risk Analysis Project** utilizes SQL to analyze customer data, focusing on debt levels, transaction behavior, and risk segmentation. This project provides actionable insights for business decision-making, specifically addressing questions about customer financial behavior and segmentation.

---

## 🛠️ **Tools & Technologies**

- **Amazon AuroraSQL**: Relational database system for efficient querying and analysis.  
- **SQL**: For data extraction, transformation, and analysis.  
- **Microsoft Excel**: Used for initial data exploration and summarization.

---

## 📊 **Datasets**

1. **Users Data**: Contains demographic, income, and financial data (e.g., total debt, yearly income, and credit scores).  
2. **Transactions Data**: Details merchant transactions, errors, and volumes.

---

## 💻 **Key SQL Queries**

### **1. Top Merchants by Transaction Errors**

**Objective**: Identify merchants with the highest transaction errors and their error rates.  
**Query**:  
```sql
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
```
**Result Highlights**:
- **Merchant 27092** had the highest transaction errors (226 errors out of 7,257 transactions, error rate: 3.11%).
- Other merchants (e.g., 59935 and 39021) also showed notable error rates, indicating potential issues in transaction processes.

### **2. Customer Risk Profiling**

**Objective**: Classify customers into risk categories based on debt-to-income ratio and credit score. 
**Query**:  
```sql
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
```
**Result Highlights**:
- Customers with a **debt-to-income ratio >40%** and credit scores <600 were classified as **High Risk**.
- **User 1319**: Debt-to-income ratio of 389.75%, credit score of 546 (High Risk).
- Most customers fell under **Moderate Risk**, with manageable credit scores but high debt levels.

### **3. Debt Segmentation**

**Objective**: Group customers by debt levels for targeted marketing and interventions. 
**Query**:  
```sql
SELECT
    CASE
        WHEN total_debt = 0 THEN 'No Debt'
        WHEN total_debt BETWEEN 1 AND 5000 THEN 'Low Debt (1-5K)'
        WHEN total_debt BETWEEN 5001 AND 20000 THEN 'Moderate Debt (5K-20K)'
        WHEN total_debt BETWEEN 20001 AND 50000 THEN 'High Debt (20K-50K)'
        ELSE 'Very High Debt (>50K)'
    END AS debt_bracket,
    COUNT(user_id) AS customer_count,
    ROUND(AVG(total_debt), 2) AS avg_debt,
    ROUND(SUM(total_debt), 2) AS total_debt_in_bracket
FROM
    users_data_table
GROUP BY
    debt_bracket
ORDER BY
    total_debt_in_bracket DESC;
```
**Result Highlights**:
- **Very High Debt (>50K)**: 2,304 customers, total debt of **$220.2M**, with an average debt of **$95,567.87**.
- **High Debt (20K-50K)**: 840 customers, total debt of **$29.5M**.
- The majority of customers fell into the **Very High Debt** segment, suggesting the need for financial counseling or targeted risk management strategies.

---
## 🔍 **Insights & Recommendations**
**Transaction Errors**:
- Merchants with higher transaction error rates (e.g., Merchant 27092) should be audited to minimize disruptions and improve customer experience.
**Customer Risk Segmentation**:
- High-risk customers (e.g., those with low credit scores and high debt-to-income ratios) may need tailored financial products or interventions.
**Debt Segmentation**:
- Most customers are in the Very High Debt bracket, emphasizing the need for educational initiatives around financial literacy and debt management.

