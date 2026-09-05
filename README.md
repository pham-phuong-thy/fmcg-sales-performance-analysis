# FMCG Sales Performance Analysis (BigQuery + Tableau)

End-to-end analytics project on a FMCG (Fast-Moving Consumer Goods) retail dataset — from raw transactional data in **Google BigQuery** to two interactive **Tableau Public** dashboards, covering revenue trends, category/product performance, customer segmentation, and geographic distribution.

---

## Project Overview

| | |
|---|---|
| **Period** | January – May 2018 |
| **Market** | United States |
| **Total Revenue** | $4.33B |
| **Orders** | 6.76M |
| **AOV** | $641 |
| **Units Sold** | 87.88M |
| **SKUs** | 452 |
| **Avg. Discount** | 3.00% |

The dataset covers FMCG transactions across categories (Confections, Meat, Poultry, Cereals, Dairy, Beverages, Snails, Produce, Seafood, Grain, Shell fish), customers, cities, and sales employees.

## Business Questions

1. How is revenue trending month over month, and is growth concentrated in any single price tier or region?
2. Which product categories drive the most revenue, and which are underperforming?
3. Is there a trade-off between SKU count (portfolio breadth) and revenue per unit (value per SKU)? Where are the growth opportunities and the categories that need review?
4. How valuable/loyal are customers, and can they be segmented for targeted action?
5. Which cities and sales employees contribute most to revenue?

## Data Model

Source data lives in BigQuery (`sales-of-fmcg-stores.salesfmcg`):

- `vw_sales_analysis` — transaction-level fact view (Revenue, Quantity, Price, Discount, Sales Date, Transaction Number)
- `products`, `categories` — product dimension
- `customers`, `cities`, `countries` — customer/geo dimension

## SQL Analysis (BigQuery)

| File | Purpose |
|---|---|
| `0_overview.sql` | Top-line KPIs: total revenue, orders, quantity, AOV, avg discount, number of SKUs |
| `1_time_revenue_analysis.sql` | Monthly revenue & MoM growth (`LAG` window function), monthly revenue by category, revenue vs. quantity trend — **May excluded from MoM comparison and reported separately as month-to-date (MTD), normalized to a 30-day equivalent, to avoid misreading a partial month as a decline** |
| `2_product_performance.sql` | Product-level revenue, quantity and revenue-per-unit; segments every product into a **quantity × revenue-per-unit quadrant** using median benchmarks (`APPROX_QUANTILES`); category-level average discount and revenue leakage (`Quantity × Price` vs. actual `TotalPrice`); performance by product Class (High/Medium/Low) |
| `3_customer_analysis.sql` | RFM-style customer segmentation (VIP, Big Spender, Frequent Shopper, Regular, Low Value) using `NTILE` quartiles on monetary value and purchase frequency |
| `4_employee_performance.sql` | Revenue and average revenue per invoice by salesperson |
| `5_geographic_performance.sql` | City-level revenue, customers, AOV, revenue contribution %, and consumption volume rank (`RANK`) |

**Techniques used:** CTEs, window functions (`LAG`, `NTILE`, `RANK`, `APPROX_QUANTILES`), `SAFE_DIVIDE` for null-safe ratios, median-based segmentation logic, data-quality handling for partial-period data.

## Dashboards (Tableau)

### 1. FMCG Sales Performance Overview
Executive-level view: KPI summary row, monthly revenue & orders trend with MoM % callouts, revenue-by-category treemap, top 10 cities by revenue, product Class mix (Order/Quantity/Revenue share), and a narrative insight panel.
- Explicit annotation that **May 2018 is a partial month**, so it isn't misread as a revenue collapse.

### 2. Category Performance Overview
Category-level deep dive: 5 KPI cards highlighting **Top Revenue Category**, **Bottom Revenue Category**, **Growth Opportunity**, **Category to Monitor**, and **Largest Product Portfolio** — each derived from the quantity × revenue-per-unit quadrant logic rather than raw totals alone. Supported by a stacked area chart (revenue by category over time), a stacked bar (revenue by category × class), a bubble chart (SKU count vs. revenue per unit), and a SKU distribution heatmap by category and quadrant.

## Key Insights

- Revenue held steady near $1.0B/month through Q1, dipped -9.85% in February and rebounded +11.08% in March.
- **Confections** is the top revenue category ($556.93M) *and* has the largest SKU portfolio (57 SKUs) — but most of its SKUs sit in the "High Quantity – Low Revenue per Unit" quadrant (17 of 57), meaning its lead comes from high-volume, lower-value sales rather than premium products.
- **Meat** and **Poultry** have the most SKUs in the best-performing quadrant ("High Quantity – High Revenue per Unit": 16 and 15 SKUs respectively) — strong benchmarks for portfolio health.
- **Snails** is flagged as a growth opportunity: a below-median SKU count (37) paired with an above-median revenue per unit ($1.91K) suggests room to expand the assortment without diluting value.
- **Shell fish** is flagged for review: it has the lowest revenue per unit ($1.55K) despite a SKU count on par with Seafood — pointing to a pricing/product-mix problem rather than under-investment.
- High/Medium/Low product tiers each contribute roughly a third of total revenue — performance isn't concentrated in a single price tier.
- Demand is geographically broad: the top city (Tucson) holds only ~1% of total revenue, with the next nine cities close behind.

## Tech Stack

- **Google BigQuery** — SQL data modeling, transformation, and window-function analysis
- **Tableau Public** — dashboard design and interactive visualization

## Repository Structure

```
├── sql/
│   ├── 0_overview.sql
│   ├── 1_time_revenue_analysis.sql
│   ├── 2_product_performance.sql
│   ├── 3_customer_analysis.sql
│   ├── 4_employee_performance.sql
│   └── 5_geographic_performance.sql
├── screenshots/
│   ├── dashboard_1_overview.png
│   └── dashboard_2_category_performance.png
└── README.md
```

## Limitations

- Analysis is based on revenue and discount data only; cost/margin data was not available, so profitability could not be assessed.
- May 2018 data is partial (month-to-date at time of extraction) and excluded from month-over-month trend comparisons.

## 👤 Author

*[Your name]* — [LinkedIn] · [Portfolio] · [Email]
