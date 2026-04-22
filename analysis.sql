-- =============================================================
-- Zepto Sales Intelligence - SQL Exploratory Data Analysis
-- Dataset : Zepto Grocery Sales (8,523 records, 12 columns)
-- Author  : Abhinav Yadav
-- Tool    : PostgreSQL / SQLite compatible
-- Purpose : Pre-dashboard EDA to surface key business insights
--           before visualization in Power BI
-- =============================================================

-- SECTION 0 : TABLE DEFINITION
-- =============================================================

CREATE TABLE IF NOT EXISTS zepto_sales (
    item_fat_content         VARCHAR(20),
    item_identifier          VARCHAR(10),
    item_type                VARCHAR(50),
    outlet_establishment_year INT,
    outlet_identifier        VARCHAR(10),
    outlet_location_type     VARCHAR(10),
    outlet_size              VARCHAR(10),
    outlet_type              VARCHAR(30),
    item_visibility          DECIMAL(10, 8),
    item_weight              DECIMAL(6, 2),
    sales                    DECIMAL(10, 4),
    rating                   DECIMAL(3, 1)
);


-- SECTION 1 : DATA CLEANING
-- The raw dataset has inconsistent fat content labels which need to be standardised before any analysis.
-- =============================================================

-- 1.1  Inspect raw fat content values
SELECT
    item_fat_content,
    COUNT(*) AS record_count
FROM zepto_sales
GROUP BY item_fat_content
ORDER BY record_count DESC;
-- Expected dirty values: 'LF', 'low fat' (should all be 'Low Fat')
--                        'reg'           (should be 'Regular')


-- 1.2  Standardise fat content labels
UPDATE zepto_sales
SET item_fat_content = CASE
    WHEN LOWER(item_fat_content) IN ('lf', 'low fat') THEN 'Low Fat'
    WHEN LOWER(item_fat_content) IN ('reg', 'regular') THEN 'Regular'
    ELSE item_fat_content
END;


-- 1.3  Verify null / missing values across all key columns
SELECT
    SUM(CASE WHEN item_fat_content         IS NULL THEN 1 ELSE 0 END) AS null_fat_content,
    SUM(CASE WHEN item_type                IS NULL THEN 1 ELSE 0 END) AS null_item_type,
    SUM(CASE WHEN item_weight              IS NULL THEN 1 ELSE 0 END) AS null_item_weight,
    SUM(CASE WHEN sales                    IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN rating                   IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN outlet_size              IS NULL THEN 1 ELSE 0 END) AS null_outlet_size,
    SUM(CASE WHEN outlet_establishment_year IS NULL THEN 1 ELSE 0 END) AS null_est_year
FROM zepto_sales;


-- SECTION 2 : BUSINESS KPIs  (matches dashboard header cards)
-- =============================================================

-- 2.1  Top-level KPIs
SELECT
    ROUND(SUM(sales) / 1000000.0, 2)   AS total_sales_million,
    COUNT(*)                            AS total_items,
    ROUND(AVG(sales), 2)               AS avg_sales_per_item,
    ROUND(AVG(rating), 1)              AS avg_customer_rating
FROM zepto_sales;


-- 2.2  KPIs segmented by fat content
SELECT
    item_fat_content,
    COUNT(*)                            AS item_count,
    ROUND(SUM(sales), 2)               AS total_sales,
    ROUND(AVG(sales), 2)               AS avg_sales,
    ROUND(AVG(rating), 2)              AS avg_rating,
    ROUND(SUM(sales) * 100.0 /
          SUM(SUM(sales)) OVER (), 1)  AS sales_pct
FROM zepto_sales
GROUP BY item_fat_content
ORDER BY total_sales DESC;


-- SECTION 3 : ITEM TYPE ANALYSIS
-- =============================================================

-- 3.1  Revenue ranked by item category
SELECT
    item_type,
    COUNT(*)                            AS item_count,
    ROUND(SUM(sales), 2)               AS total_sales,
    ROUND(AVG(sales), 2)               AS avg_sales,
    ROUND(AVG(rating), 2)              AS avg_rating,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM zepto_sales
GROUP BY item_type
ORDER BY total_sales DESC;


-- 3.2  Item types that punch above their weight
--      (avg_sales higher than overall average)
SELECT
    item_type,
    ROUND(AVG(sales), 2)               AS avg_sales,
    ROUND(AVG(sales) - AVG(AVG(sales)) OVER (), 2) AS vs_overall_avg
FROM zepto_sales
GROUP BY item_type
HAVING AVG(sales) > (SELECT AVG(sales) FROM zepto_sales)
ORDER BY avg_sales DESC;


-- SECTION 4 : OUTLET ANALYSIS
-- =============================================================

-- 4.1  Revenue by outlet type
SELECT
    outlet_type,
    COUNT(DISTINCT outlet_identifier)  AS outlet_count,
    COUNT(*)                           AS total_items_sold,
    ROUND(SUM(sales), 2)              AS total_sales,
    ROUND(AVG(sales), 2)              AS avg_sales,
    ROUND(AVG(rating), 2)             AS avg_rating
FROM zepto_sales
GROUP BY outlet_type
ORDER BY total_sales DESC;


-- 4.2  Revenue by outlet location tier
SELECT
    outlet_location_type,
    COUNT(DISTINCT outlet_identifier)  AS outlet_count,
    ROUND(SUM(sales), 2)              AS total_sales,
    ROUND(AVG(sales), 2)              AS avg_sales,
    ROUND(SUM(sales) * 100.0 /
          SUM(SUM(sales)) OVER (), 1) AS revenue_share_pct
FROM zepto_sales
GROUP BY outlet_location_type
ORDER BY total_sales DESC;


-- 4.3  Revenue by outlet size
SELECT
    outlet_size,
    COUNT(DISTINCT outlet_identifier)  AS outlet_count,
    ROUND(SUM(sales), 2)              AS total_sales,
    ROUND(AVG(sales), 2)              AS avg_sales
FROM zepto_sales
GROUP BY outlet_size
ORDER BY total_sales DESC;


-- 4.4  Fat content split within each outlet location tier
--      (replicates "Fat by Outlet" bar chart in dashboard)
SELECT
    outlet_location_type,
    item_fat_content,
    ROUND(SUM(sales), 2)              AS total_sales,
    COUNT(*)                           AS item_count
FROM zepto_sales
GROUP BY outlet_location_type, item_fat_content
ORDER BY outlet_location_type, total_sales DESC;


-- 4.5  Individual outlet performance leaderboard
SELECT
    outlet_identifier,
    outlet_type,
    outlet_location_type,
    outlet_size,
    outlet_establishment_year,
    COUNT(*)                           AS items_sold,
    ROUND(SUM(sales), 2)              AS total_sales,
    ROUND(AVG(sales), 2)              AS avg_sales,
    ROUND(AVG(rating), 2)             AS avg_rating
FROM zepto_sales
GROUP BY
    outlet_identifier, outlet_type,
    outlet_location_type, outlet_size,
    outlet_establishment_year
ORDER BY total_sales DESC;


-- SECTION 5 : TIME-SERIES / ESTABLISHMENT YEAR ANALYSIS
-- (replicates Outlet Establishment area chart)
-- =============================================================

-- 5.1  Annual sales by outlet establishment year
SELECT
    outlet_establishment_year,
    COUNT(DISTINCT outlet_identifier)  AS outlets_opened,
    ROUND(SUM(sales), 2)              AS total_sales,
    ROUND(AVG(sales), 2)              AS avg_sales_per_item
FROM zepto_sales
GROUP BY outlet_establishment_year
ORDER BY outlet_establishment_year;


-- 5.2  Identify peak revenue year
SELECT
    outlet_establishment_year          AS peak_year,
    ROUND(SUM(sales), 2)              AS total_sales
FROM zepto_sales
GROUP BY outlet_establishment_year
ORDER BY total_sales DESC
LIMIT 1;


-- SECTION 6 : ITEM VISIBILITY & WEIGHT ANALYSIS
-- =============================================================

-- 6.1  Correlation bucket: does higher visibility drive more sales?
SELECT
    CASE
        WHEN item_visibility < 0.03  THEN 'Low  (<0.03)'
        WHEN item_visibility < 0.10  THEN 'Mid  (0.03–0.10)'
        ELSE                              'High (>0.10)'
    END                                AS visibility_bucket,
    COUNT(*)                           AS item_count,
    ROUND(AVG(sales), 2)              AS avg_sales,
    ROUND(AVG(rating), 2)             AS avg_rating
FROM zepto_sales
GROUP BY visibility_bucket
ORDER BY avg_sales DESC;


-- 6.2  Zero-visibility items (data quality flag)
SELECT
    item_identifier,
    item_type,
    item_fat_content,
    item_visibility,
    sales
FROM zepto_sales
WHERE item_visibility = 0
ORDER BY sales DESC;


-- SECTION 7 : RATING ANALYSIS
-- =============================================================

-- 7.1  Rating distribution
SELECT
    rating,
    COUNT(*)                           AS item_count,
    ROUND(AVG(sales), 2)              AS avg_sales
FROM zepto_sales
GROUP BY rating
ORDER BY rating DESC;


-- 7.2  Low rated high-revenue items (risk / improvement candidates)
SELECT
    item_type,
    item_identifier,
    ROUND(sales, 2)                    AS sales,
    rating,
    outlet_type,
    outlet_location_type
FROM zepto_sales
WHERE rating < 3.5
ORDER BY sales DESC
LIMIT 15;


-- SECTION 8 : ADVANCED WINDOW FUNCTION QUERIES
-- =============================================================

-- 8.1  Running total of sales ordered by establishment year
SELECT
    outlet_establishment_year,
    ROUND(SUM(sales), 2)              AS yearly_sales,
    ROUND(SUM(SUM(sales))
          OVER (ORDER BY outlet_establishment_year
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
          2)                           AS running_total_sales
FROM zepto_sales
GROUP BY outlet_establishment_year
ORDER BY outlet_establishment_year;


-- 8.2  Percentile rank of each outlet by total revenue
SELECT
    outlet_identifier,
    outlet_type,
    ROUND(SUM(sales), 2)              AS total_sales,
    ROUND(PERCENT_RANK()
          OVER (ORDER BY SUM(sales)), 2) AS revenue_percentile
FROM zepto_sales
GROUP BY outlet_identifier, outlet_type
ORDER BY total_sales DESC;


-- 8.3  Item type contribution within each outlet location tier
SELECT
    outlet_location_type,
    item_type,
    ROUND(SUM(sales), 2)              AS sales,
    ROUND(SUM(sales) * 100.0 /
          SUM(SUM(sales))
          OVER (PARTITION BY outlet_location_type), 1) AS pct_of_tier_sales
FROM zepto_sales
GROUP BY outlet_location_type, item_type
ORDER BY outlet_location_type, sales DESC;


-- =============================================================
-- END OF ANALYSIS
-- Key findings fed into Power BI dashboard (Zepto_Dashboard.pbix)
-- =============================================================
