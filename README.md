# Olist E-Commerce SQL Analysis

![SQL](https://img.shields.io/badge/SQL-T--SQL%20%2F%20SQL%20Server-CC2927?logo=microsoftsqlserver&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

SQL analysis of a real Brazilian e-commerce marketplace (100k+ orders, 9 relational tables), answering
four business questions — revenue concentration, delivery impact on satisfaction, customer retention,
and seller performance — using joins, subqueries, CTEs, and window functions in T-SQL.

**Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle, 2016–2018)
**Tools:** Microsoft SQL Server (T-SQL), SSMS

---

## Business Findings

**1. Revenue is heavily concentrated in one state.**
São Paulo (SP) generates R$5.99M in total revenue — nearly 3x Rio de Janeiro (R$2.14M), the next-closest state, and more than the next four states combined.

<img src="images/01_revenue_by_state.png" width="560">

**2. Late delivery is strongly tied to customer satisfaction.**
Orders delivered after the estimated date average a **2.0★** review, versus **4.0★** for on-time orders — a two-star gap directly attributable to delivery timing.

<img src="images/02_delivery_vs_review.png" width="380">

**3. Revenue depends far more on new customers than repeat buyers.**
One-time customers account for R$15.06M in revenue versus R$0.94M from repeat customers.
This required identifying and correcting for a data quirk: Olist assigns a **new `customer_id` per order**, even for the same person, so `customer_unique_id` had to be used to correctly identify genuine repeat buyers — using `customer_id` alone would have made every customer appear to be a one-time buyer.

<img src="images/03_new_vs_repeat_revenue.png" width="380">

**4. Monthly revenue shows sustained, compounding growth.**
Revenue grew from ~R$138K/month in early 2017 to a stable R$1.0M–1.2M/month range through 2018.

<img src="images/04_monthly_revenue_trend.png" width="680">

**5. A combined seller scorecard (revenue + review score + late-delivery rate) surfaces risk that revenue alone hides.**
The top seller by revenue (R$229K) carries an 11.6% late-delivery rate — notably higher than several lower-ranked sellers with tighter delivery reliability, making them a candidate for performance review despite strong sales.

---

## Recommendations

1. Prioritize delivery reliability — it has the single clearest, most measurable link to customer satisfaction in this data.
2. Treat São Paulo as the core operating market for logistics and seller onboarding investment.
3. Since repeat purchases are rare, optimize the first-purchase experience rather than assuming loyalty-driven revenue.
4. Use combined seller scorecards, not revenue alone, to flag delivery-risk sellers before they affect platform-wide ratings.

---

## Repository Structure

```
olist-sql-analysis/
├── README.md
├── LICENSE
├── .gitignore
├── sql/
│   ├── 01_data_exploration.sql            -- SELECT, WHERE, ORDER BY, DISTINCT
│   ├── 02_filtering_and_segmentation.sql  -- CASE WHEN, IN, LIKE, BETWEEN, IS NULL
│   ├── 03_aggregation_and_metrics.sql     -- GROUP BY, HAVING, core business metrics
│   ├── 04_joins_and_relationships.sql     -- INNER/LEFT joins across the schema
│   ├── 05_subqueries.sql                  -- scalar, correlated, derived tables
│   ├── 06_ctes.sql                        -- single & chained CTEs
│   ├── 07_window_functions.sql            -- ROW_NUMBER, RANK, LAG, running totals
│   └── 08_business_insights_analysis.sql  -- the 4 findings above, in full
└── images/
    └── *.png
```

---

## Database Schema

```mermaid
erDiagram
    CUSTOMERS ||--o{ ORDERS : places
    ORDERS ||--o{ ORDER_ITEMS : contains
    ORDERS ||--o{ ORDER_PAYMENTS : "paid via"
    ORDERS ||--o{ ORDER_REVIEWS : receives
    PRODUCTS ||--o{ ORDER_ITEMS : "sold as"
    SELLERS ||--o{ ORDER_ITEMS : sells
    PRODUCTS }o--|| CATEGORY_TRANSLATION : "categorized by"

    CUSTOMERS {
        string customer_id PK
        string customer_unique_id
        string customer_city
        string customer_state
    }
    ORDERS {
        string order_id PK
        string customer_id FK
        string order_status
        datetime order_purchase_timestamp
        datetime order_approved_at
        datetime order_delivered_customer_date
        datetime order_estimated_delivery_date
    }
    ORDER_ITEMS {
        string order_id FK
        string product_id FK
        string seller_id FK
        decimal price
    }
    ORDER_PAYMENTS {
        string order_id FK
        string payment_type
        decimal payment_value
    }
    ORDER_REVIEWS {
        string order_id FK
        int review_score
    }
    PRODUCTS {
        string product_id PK
        string product_category_name
    }
    SELLERS {
        string seller_id PK
        string seller_city
        string seller_state
    }
    CATEGORY_TRANSLATION {
        string product_category_name PK
        string product_category_name_english
    }
```

---

## How to Run

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
2. Create a SQL Server database named `olist_ecommerce`.
3. Import the 9 CSVs as tables: `customers`, `orders`, `order_items`, `order_payments`, `order_reviews`, `products`, `sellers`, `geolocation`, `category_translation`.
4. Run the scripts in `/sql`, in order, in SSMS or another SQL client.

---

## Techniques Used

Multi-table joins (INNER/LEFT) · Correlated & derived-table subqueries · Single & chained CTEs ·
Window functions (`ROW_NUMBER`, `RANK`, `LAG`) · Aggregation & business-metric design · NULL handling in real-world data

---

## Author

**Lavit Chaudhary** — Business Analytics Student | SQL, Python (Pandas, Matplotlib, Seaborn), Power BI
[LinkedIn](https://linkedin.com/in/lavit-chaudhary) · [GitHub](https://github.com/LavitDecoded)

Licensed under [MIT](LICENSE).
