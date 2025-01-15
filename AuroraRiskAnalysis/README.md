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
