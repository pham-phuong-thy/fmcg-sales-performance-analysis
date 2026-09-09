-- =========================================================
-- 2. PRODUCT PERFORMANCE - FULL DATASET
-- =========================================================
WITH product_stats AS (
    SELECT
        p.ProductID,
        p.ProductName,
        p.CategoryID,
        c.CategoryName,
        p.Class,
        SUM(s.Quantity) AS TotalQuantity,
        COUNT(DISTINCT s.TransactionNumber) AS TotalOrders,
        SUM(s.Revenue) AS TotalRevenue,
        SAFE_DIVIDE(SUM(s.Revenue), SUM(s.Quantity)) AS RevenuePerUnit
    FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis` AS s
    JOIN `sales-of-fmcg-stores.salesfmcg.products` AS p ON s.ProductID = p.ProductID
    JOIN `sales-of-fmcg-stores.salesfmcg.categories` AS c ON p.CategoryID = c.CategoryID
    GROUP BY p.ProductID, p.ProductName, p.CategoryID, c.CategoryName, p.Class
),

median_stats AS (
    SELECT
        APPROX_QUANTILES(TotalQuantity, 2)[OFFSET(1)] AS MedianQuantity,
        APPROX_QUANTILES(RevenuePerUnit, 2)[OFFSET(1)] AS MedianRevenuePerUnit
    FROM product_stats
)

SELECT
    p.ProductID,
    p.ProductName,
    p.CategoryID,
    p.CategoryName,
    p.Class,
    p.TotalQuantity,
    ROUND(SAFE_DIVIDE(p.TotalQuantity, 1000000), 2) AS TotalQuantity_Million,
    p.TotalOrders,
    ROUND(p.TotalRevenue, 2) AS TotalRevenue,
    ROUND(SAFE_DIVIDE(p.TotalRevenue, 1000000), 2) AS TotalRevenue_Million,
    ROUND(p.RevenuePerUnit, 2) AS RevenuePerUnit,
    m.MedianQuantity,
    ROUND(SAFE_DIVIDE(m.MedianQuantity, 1000000), 2) AS MedianQuantity_Million,
    ROUND(m.MedianRevenuePerUnit, 2) AS MedianRevenuePerUnit,
    CASE
        WHEN p.TotalQuantity >= m.MedianQuantity AND p.RevenuePerUnit >= m.MedianRevenuePerUnit
            THEN 'High Quantity - High Revenue per Unit'
        WHEN p.TotalQuantity >= m.MedianQuantity AND p.RevenuePerUnit < m.MedianRevenuePerUnit
            THEN 'High Quantity - Low Revenue per Unit'
        WHEN p.TotalQuantity < m.MedianQuantity AND p.RevenuePerUnit >= m.MedianRevenuePerUnit
            THEN 'Low Quantity - High Revenue per Unit'
        ELSE 'Low Quantity - Low Revenue per Unit'
    END AS ProductQuadrant
FROM product_stats AS p
CROSS JOIN median_stats AS m;

-- =========================================================
-- 2.2 CATEGORY PERFORMANCE
-- =========================================================
WITH category_summary AS (
    SELECT
        c.CategoryID,
        c.CategoryName,
        AVG(v.Discount) AS AvgDiscount,
        SUM(v.Revenue) AS TotalRevenue,
        SUM(v.Quantity) AS TotalQuantity,
        SUM(v.Quantity * v.Price) - SUM(v.TotalPrice) AS RevenueLeakage
    FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis` AS v
    JOIN `sales-of-fmcg-stores.salesfmcg.products` AS p ON v.ProductID = p.ProductID
    JOIN `sales-of-fmcg-stores.salesfmcg.categories` AS c ON p.CategoryID = c.CategoryID
    GROUP BY c.CategoryID, c.CategoryName
)
SELECT
    *,
    TotalRevenue / SUM(TotalRevenue) OVER () AS RevenueShare
FROM category_summary
ORDER BY AvgDiscount DESC;

-- =========================================================
-- 2.3 PRODUCT CLASS PERFORMANCE
-- =========================================================
SELECT
    p.Class,
    COUNT(DISTINCT p.ProductID) AS TotalProducts,
    SUM(s.Quantity) AS TotalQuantitySold,
    ROUND(SUM(s.Revenue), 2) AS TotalRevenue,
    ROUND(SAFE_DIVIDE(SUM(s.Revenue), COUNT(DISTINCT p.ProductID)), 2) AS AverageRevenuePerProduct,
    ROUND(SAFE_DIVIDE(SUM(s.Quantity), COUNT(DISTINCT p.ProductID)), 2) AS AverageQuantityPerProduct
FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis` AS s
JOIN `sales-of-fmcg-stores.salesfmcg.products` AS p ON s.ProductID = p.ProductID
GROUP BY p.Class
ORDER BY TotalRevenue DESC;
