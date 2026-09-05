-- =========================================================
-- 1.1 MONTHLY REVENUE AND MOM GROWTH
-- =========================================================
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC(DATE(SalesDate), MONTH) AS SalesMonth,
        SUM(Revenue) AS TotalRevenue,
        COUNT(DISTINCT TransactionNumber) AS TotalOrders
    FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis`
    WHERE SalesDate IS NOT NULL
      AND DATE(SalesDate) < '2018-05-01'
    GROUP BY SalesMonth
)
SELECT
    SalesMonth,
    ROUND(TotalRevenue, 2) AS TotalRevenue,
    TotalOrders,
    ROUND(
        LAG(TotalRevenue) OVER (
            ORDER BY SalesMonth
        ),
        2
    ) AS PreviousMonthRevenue,
    ROUND(
        SAFE_DIVIDE(
            TotalRevenue
                - LAG(TotalRevenue) OVER (
                    ORDER BY SalesMonth
                ),
            LAG(TotalRevenue) OVER (
                ORDER BY SalesMonth
            )
        ) * 100, 2
    ) AS MoM_Growth_Percentage
FROM monthly_revenue
ORDER BY SalesMonth;

-- =========================================================
-- 1.1B MAY 2018 MONTH-TO-DATE PERFORMANCE
-- Grain: SalesMonth
-- Display separately from the main MoM trend
-- =========================================================

SELECT
    DATE_TRUNC(DATE(SalesDate), MONTH) AS SalesMonth,

    MAX(DATE(SalesDate)) AS LastAvailableDate,

    COUNT(DISTINCT DATE(SalesDate)) AS AvailableDays,

    ROUND(
        SUM(Revenue),
        2
    ) AS ActualRevenueMTD,

    ROUND(
        SAFE_DIVIDE(
            SUM(Revenue),
            COUNT(DISTINCT DATE(SalesDate))
        ) * 30,
        2
    ) AS Revenue_MTD_Normalized

FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis`

WHERE SalesDate IS NOT NULL
  AND DATE(SalesDate) >= '2018-05-01'

GROUP BY SalesMonth

ORDER BY SalesMonth;

-- =========================================================
-- 1.2 MONTHLY CATEGORY REVENUE
-- Grain: SalesMonth × CategoryID
-- =========================================================

WITH monthly_category AS (
    SELECT
        DATE_TRUNC(DATE(s.SalesDate), MONTH) AS SalesMonth,

        c.CategoryID,

        c.CategoryName,

        SUM(s.Revenue) AS CategoryRevenue

    FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis` AS s

    JOIN `sales-of-fmcg-stores.salesfmcg.products` AS p
        ON s.ProductID = p.ProductID

    JOIN `sales-of-fmcg-stores.salesfmcg.categories` AS c
        ON p.CategoryID = c.CategoryID

    WHERE s.SalesDate IS NOT NULL
      AND DATE(s.SalesDate) < '2018-05-01'

    GROUP BY
        SalesMonth,
        c.CategoryID,
        c.CategoryName
)

SELECT
    SalesMonth,

    CategoryID,

    CategoryName,

    ROUND(CategoryRevenue, 2) AS CategoryRevenue,

    ROUND(
        SAFE_DIVIDE(
            CategoryRevenue,
            SUM(CategoryRevenue) OVER (
                PARTITION BY SalesMonth
            )
        ) * 100,
        2
    ) AS PctOfMonthlyRevenue

FROM monthly_category

ORDER BY
    SalesMonth,
    CategoryRevenue DESC;

-- =========================================================
-- 1.3 MONTHLY REVENUE VS QUANTITY
-- Grain: SalesMonth
-- =========================================================

SELECT
    DATE_TRUNC(DATE(SalesDate), MONTH) AS SalesMonth,

    ROUND(SUM(Revenue), 2) AS TotalRevenue,

    SUM(Quantity) AS TotalQuantity

FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis`

WHERE SalesDate IS NOT NULL
  AND DATE(SalesDate) < '2018-05-01'

GROUP BY SalesMonth

ORDER BY SalesMonth;
