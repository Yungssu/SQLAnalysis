# 📁 Bank Churn Analysis (SQL-Only Project)

## 🔍 Project Overview

This project explores customer churn in a retail bank using only **SQL** — from data cleaning to in-depth analysis. The goal was to identify what characteristics are more common among churned customers, understand the bank's customer base, and build actionable insights for business teams and stakeholders.

✅ No Python, Excel, or BI tools were used for this analysis — just pure SQL queries.

## 🧠 Key Questions Answered

1. **What attributes are more common among churners than non-churners?**
2. **Can churn be predicted using the variables in the data?**
3. **What do the overall demographics of the bank’s customers look like?**
4. **Is there a difference between German, French, and Spanish customers in terms of account behavior?**
5. **What types of segments exist within the bank’s customers?**

---

## 🗂️ Dataset

- Original file: [Bank_Churn_Messy.xlsx](https://github.com/Yungssu/SQLAnalysis/blob/main/BankCHURNProject/Dataset/Bank_Churn_Messy.xlsx)
- Cleaned and split into two tables:
  - [customer_info.csv](https://github.com/Yungssu/SQLAnalysis/blob/main/BankCHURNProject/Dataset/customer_info.csv)
  - [account_info.csv](https://github.com/Yungssu/SQLAnalysis/blob/main/BankCHURNProject/Dataset/account_info.csv)
- Data was manually cleaned and loaded into MySQL.
- A data dictionary is included for reference.
  - [Bank_Churn_Data_Dictionary.csv](https://github.com/Yungssu/SQLAnalysis/blob/main/BankCHURNProject/Dataset/Bank_Churn_Data_Dictionary.csv)


---

## 📊 Summary of Findings

### 1. Churn Characteristics

| Attribute        | Churned Customers | Non-Churned Customers |
| ---------------- | ----------------- | --------------------- |
| Average Age      | 44.81             | 37.40                 |
| Avg Balance      | 91,088.48         | 72,611.03             |
| Avg Credit Score | 645.42            | 651.78                |

- **Females** have higher churn rate (25.15%) than males (16.46%).
- **German customers** churn twice as much (32.47%) as French or Spanish (\~16%).
- Customers with **3–4 products** have extremely high churn: 83% to 100%.

### 2. Predictability

Churn correlates strongly with:

- Age, credit score, activity status
- Number of products
- Geography and tenure group

✅ This makes the data suitable for ML churn prediction models.

### 3. Customer Demographics

Analyzed via Excel PivotCharts:

- Age Categories: Young Adult, Early Career, Mid-Career, Senior 
![CustomerAge Graph](https://github.com/Yungssu/SQLAnalysis/blob/main/BankCHURNProject/CustomerbyAge.png)
- Income Brackets: Low, Middle, High
![Income Graph](https://github.com/Yungssu/SQLAnalysis/blob/main/BankCHURNProject/CustomerbyIncome.png)
- Tenure Groups: New, Mid-Term, Loyal
![Tenure Graph](https://github.com/Yungssu/SQLAnalysis/blob/main/BankCHURNProject/byLoyalty.png)
- Credit Score Categories: Poor to Excellent
![CreditScore Graph](https://github.com/Yungssu/SQLAnalysis/blob/main/BankCHURNProject/CustomerbyCreditScore.png)

### 4. Country Differences

| Country | Churn Rate | Avg Balance | Avg Age |
| ------- | ---------- | ----------- | ------- |
| Germany | 32.47%     | 119,685     | 39.76   |
| France  | 16.27%     | 62,613      | 38.73   |
| Spain   | 16.70%     | 61,505      | 38.87   |

📌 *Germany stands out for both churn and balance.*

### 5. Customer Segmentation

- **By Products:**
  - 4 Products → 100% churn
  - 3 Products → 83% churn
  - 1 Product → 27% churn
- **By Risk:**
  - High Risk = Inactive + 1 Product → 36.65% churn
  - Low Risk = Active + ≥2 Products → 9.66% churn

---

## 💡 Recommendations

- Target **high-balance, older customers** with retention offers.
- Redesign offerings for customers with **3–4 products** to address dissatisfaction.
- Focus on **Germany** with country-specific strategies.
- Enhance onboarding for **new customers** and **inactive members**.

---

## 📌 Tools Used

- **MySQL Workbench** (data import, cleaning, analysis)
- **Excel** (for Question 3 only — demographic visualizations)

---


## 🙋‍♂️ About Me

I'm Kenneth Huyong, an aspiring data analyst with a strong passion for SQL and data storytelling. This is one of my hands-on portfolio projects designed to demonstrate real-world business insight using data.

📫 Connect with me:

- [LinkedIn](https://www.linkedin.com/in/kennethhuyong)
- [GitHub](https://github.com/Yungssu)

---

## 🏁 Final Thoughts

This project demonstrates how much value can be extracted using just SQL. It mimics real-world scenarios where quick insights and solid segmentation can help drive retention strategy — all without advanced tools.

🚀 More SQL-only projects coming soon!

