# olist-ecommerce-analytics
End-to-End E-Commerce Analytics Project using Python, PostgreSQL and Power BI

# 🛒 Olist E-Commerce Analytics | End-to-End Business Intelligence Project

## 📌 Project Overview

This project analyzes the Brazilian Olist E-Commerce dataset using an end-to-end analytics workflow. Starting from raw transactional data, the project performs data cleaning in Python, builds an analytics layer in PostgreSQL using SQL views, and develops an interactive Power BI dashboard to provide actionable business insights.

The objective is to transform raw e-commerce data into meaningful KPIs and visualizations that support decision-making across sales, customers, sellers, and operational performance.

---
## Source Kaggle : https://www.kaggle.com/code/rebeltalk/data-cleaning [Data Cleaning Raw files]
## Source Kaggle : https://www.kaggle.com/code/rebeltalk/olist-visualization01 [visualization files]

## 🚀 Tech Stack

| Tool | Purpose |
|------|---------|
| Python (Pandas, NumPy, Matplotlib, Seaborn) | Data Cleaning & Exploratory Data Analysis |
| PostgreSQL | Data Modeling & Analytics Views |
| Power BI | Dashboard Development & Business Intelligence |
| Git & GitHub | Version Control |
| Kaggle | Dataset & Notebook Development |

---

## 📂 Project Architecture

```
Raw Olist Dataset (CSV)
          │
          ▼
Python Data Cleaning & EDA
          │
          ▼
Cleaned Datasets
          │
          ▼
PostgreSQL (ecommerce schema)
          │
          ▼
Analytics Schema (SQL Views)
          │
          ▼
Power BI Dashboard
```

---

## 🗄️ Analytics Data Mart

The analytics schema consists of the following SQL views:

### Core Fact Views

- order_master
- product_master

### Supporting Views

- payment_agg
- delivery_metrics

### Customer Analytics

- customer_summary
- rfm_base
- rfm_scored
- rfm_segments
- cohort_analysis

### Seller Analytics

- seller_summary

---

## 📊 Dashboard Pages

### 1️⃣ Executive Overview

- Revenue KPIs
- Order KPIs
- Average Order Value
- Monthly Revenue Trend
- Revenue by State
- Product Category Contribution

---

### 2️⃣ Revenue & Product Performance

- Category Revenue Analysis
- Top Performing Categories
- Revenue Distribution
- Product Performance

---

### 3️⃣ Customer Intelligence

- RFM Segmentation
- Customer Distribution
- Customer Spending
- Customer Lifetime Metrics
- Cohort Analysis

---

### 4️⃣ Operations & Seller Performance

- Delivery Performance
- Late Delivery Analysis
- Seller Revenue
- Seller Ratings
- Seller Tier Analysis

---

## 📈 Key Business Metrics

- Total Revenue
- Total Orders
- Average Order Value
- Average Review Score
- Delivery Performance
- Customer Lifetime Value
- RFM Segmentation
- Customer Retention (Cohort Analysis)
- Seller Performance

---

## 🧹 Data Cleaning

Python was used to:

- Handle missing values
- Remove duplicates
- Standardize column names
- Validate data quality
- Export cleaned datasets

---

## 🛠️ SQL Analytics

The PostgreSQL analytics layer includes:

- Revenue aggregation
- Customer summaries
- Seller summaries
- Payment aggregation
- Delivery metrics
- Product analytics
- RFM scoring
- Customer segmentation
- Cohort analysis

---

## 📸 Dashboard Preview

*(Add dashboard screenshots here)*

### Executive Overview

![Executive Dashboard](dashboard/screenshots/executive_overview.png)

### Revenue & Products

![Revenue Dashboard](dashboard/screenshots/revenue_products.png)

### Customer Intelligence

![Customer Dashboard](dashboard/screenshots/customer_intelligence.png)

### Operations & Sellers

![Operations Dashboard](dashboard/screenshots/operations_sellers.png)

---

## 📁 Repository Structure

```
olist-ecommerce-analytics
│
├── data/
│
├── notebooks/
│
├── sql/
│
├── dashboard/
│   ├── screenshots/
│   └── olist_dashboard.pbix
│
├── diagrams/
│
└── README.md
```

---

## 🎯 Key Learnings

- Data Cleaning using Python
- SQL View Design
- Data Modeling
- Star Schema Concepts
- Power BI Dashboard Development
- KPI Design
- Customer Segmentation (RFM)
- Cohort Analysis
- Business Intelligence Reporting

---

## 📌 Future Improvements

- Automated ETL Pipeline
- Incremental Data Loading
- Power BI Service Deployment
- Predictive Sales Forecasting
- Customer Churn Prediction
- Interactive Drill-through Reports

---

## 👤 Author

**Aditya Prakash**

- SQL
- Python
- PostgreSQL
- Power BI
- Data Analytics
