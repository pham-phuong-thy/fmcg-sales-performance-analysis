-- =========================================================
-- 4.1 EMPLOYEE PERFORMANCE OVERVIEW
-- Grain: SalesPersonID
-- =========================================================

SELECT
    SalesPersonID,

    COUNT(DISTINCT TransactionNumber) AS NumberOfInvoices,

    ROUND(SUM(Revenue), 2) AS TotalSalesRevenue,

    ROUND(
        SAFE_DIVIDE(
            SUM(Revenue),
            COUNT(DISTINCT TransactionNumber)
        ),
        2
    ) AS AverageRevenuePerInvoice

FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis`

GROUP BY SalesPersonID

ORDER BY TotalSalesRevenue DESC;