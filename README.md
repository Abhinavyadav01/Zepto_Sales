# Zepto Sales Intelligence Dashboard

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-Measures-purple?style=for-the-badge)
![Dataset](https://img.shields.io/badge/Dataset-8523%20Records-green?style=for-the-badge)

A **sales intelligence dashboard** built on Zepto's grocery dataset — analysing $1.2M in revenue across outlet types, item categories, fat content segments, and geographic tiers. Exploratory analysis was performed in SQL before visualization in Power BI.

---

## Dashboard Preview

![Zepto Dashboard](Zepto%20Dashboard.png)

---

## Project Overview

Zepto is a leading instant grocery delivery app in India. This project answers key business questions a category manager or operations analyst would ask:

- Which item categories drive the most revenue?
- Do Tier 1, Tier 2, or Tier 3 outlets generate higher sales?
- How does outlet size and outlet type affect performance?
- Is there any relationship between item visibility and sales?
- Which outlets and item types carry low ratings despite high revenue — and are therefore risk candidates?

---

## Dataset

**Source:** [Kaggle — Zepto Grocery Dataset](https://www.kaggle.com/)

| Column | Description |
|---|---|
| `Item Fat Content` | Whether the item is Low Fat or Regular |
| `Item Identifier` | Unique product code |
| `Item Type` | Category (e.g. Fruits & Vegetables, Snack Foods, Dairy) |
| `Outlet Establishment Year` | Year the outlet was opened |
| `Outlet Identifier` | Unique outlet code |
| `Outlet Location Type` | Geographic tier — Tier 1, Tier 2, or Tier 3 |
| `Outlet Size` | Physical size of the outlet — Small, Medium, or High |
| `Outlet Type` | Supermarket Type 1/2/3 or Grocery Store |
| `Item Visibility` | Shelf visibility score (0–1) |
| `Item Weight` | Weight of the item in kg |
| `Sales` | Sales revenue in USD |
| `Rating` | Customer rating (1–5) |

**Records:** 8,523 &nbsp;|&nbsp; **Columns:** 12 &nbsp;|&nbsp; **Total Revenue:** $1.20M

---

## SQL Analysis

Before building the Power BI dashboard, exploratory data analysis was performed in SQL (`analysis.sql`). This covers:

| Section | What it does |
|---|---|
| Data Cleaning | Standardises dirty fat content labels (`LF`, `low fat`, `reg`) via `UPDATE` |
| Null Audit | Checks missing values across all 12 columns |
| Business KPIs | Total sales, avg sales, avg rating — overall and by fat content segment |
| Item Type Analysis | Revenue ranked by category; items outperforming the average with `HAVING` |
| Outlet Analysis | Revenue by outlet type, location tier, size; fat-content split per tier |
| Time-Series | Sales trend by outlet establishment year; peak year identified |
| Visibility Analysis | Bucketed visibility vs. sales correlation; zero-visibility data quality flag |
| Rating Analysis | Rating distribution; low-rated high-revenue risk items |
| Window Functions | Running totals, `PERCENT_RANK()` outlet leaderboard, tier-level contribution % |

> `analysis.sql` is PostgreSQL/SQLite compatible and can be run independently against the raw dataset.

---

## Power BI Dashboard

### KPI Cards
| Metric | Value |
|---|---|
| Total Sales | $1.20M |
| Number of Items | 8,523 |
| Average Sales | $141 |
| Average Rating | 3.9 |

### Visuals
- **Donut Chart** — Fat content split (Low Fat vs Regular) with total sales label
- **Donut Chart** — Outlet size distribution (Small / Medium / High)
- **Horizontal Bar Chart** — Sales by item type (16 categories)
- **Horizontal Bar Chart** — Fat content sales by outlet location tier
- **Stacked Bar Chart** — Outlet location tier revenue comparison
- **Matrix Table** — Outlet type breakdown: Total Sales, Avg Sales, Avg Rating, No. of Items
- **Area Chart** — Revenue trend by outlet establishment year (2010–2022)

### Filters
Interactive slicers for **Outlet Location Type**, **Outlet Size**, and **Item Type** — all visuals respond to filter selection.

### Data Cleaning (Power Query)
- Standardised inconsistent `Item Fat Content` labels (`LF` → `Low Fat`, `reg` → `Regular`)
- Filled down missing `Item Weight` values using `Table.FillDown`
- Promoted headers and corrected data types across all columns

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| Power BI Desktop | Dashboard creation and visualization |
| Power Query (M) | Data transformation and cleaning |
| DAX | Calculated measures and dynamic KPIs |
| SQL (PostgreSQL) | Pre-dashboard exploratory data analysis |
| GitHub | Version control and portfolio hosting |

---

## Key Business Insights

- **Supermarket Type 1** dominates revenue at **$787K** — nearly 4× any other outlet type
- **Tier 3 outlets** generate the highest revenue ($472K) despite being outside metro areas
- **Fruits & Vegetables** and **Snack Foods** are the top two revenue categories at **$0.18M each**
- **Regular fat items** account for **64.5%** of total sales vs Low Fat at 35.5%
- Outlets established in **2018** generated peak revenue at $205K — newer outlets show a decline
- Average rating is consistent at **3.9 across all outlet types**, suggesting no outlet-specific quality gap

---

## How to Run

**Power BI Dashboard**
1. Download `Zepto_Dashboard.pbix`
2. Open in Power BI Desktop
3. Use the filter panel on the left to explore segments

**SQL Analysis**
1. Load the dataset into PostgreSQL or SQLite
2. Run `analysis.sql` section by section
3. Section 0 contains the `CREATE TABLE` statement

---

## Author

**Abhinav Yadav**
B.Tech Civil Engineering — NIT Jalandhar
Data Analyst | Power BI · SQL · Python

[![GitHub](https://img.shields.io/badge/GitHub-Abhinavyadav01-black?style=flat&logo=github)](https://github.com/Abhinavyadav01)

