-- =========================================================
-- 0. OVERVIEW
-- Grain: Entire dataset
-- =========================================================

SELECT
    ROUND(SUM(Revenue), 2) AS TotalRevenue,

    COUNT(DISTINCT TransactionNumber) AS TotalOrders,

    SUM(Quantity) AS TotalQuantity,

    ROUND(
        SAFE_DIVIDE(
            SUM(Revenue),
            COUNT(DISTINCT TransactionNumber)
        ),
        2
    ) AS AOV,

    ROUND(AVG(Discount), 2) AS AvgDiscount,

    COUNT(DISTINCT ProductID) AS NumberOfProducts

FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis`;