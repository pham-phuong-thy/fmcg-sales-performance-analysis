-- =========================================================
-- 5. GEOGRAPHIC PERFORMANCE - FULL CITY DATASET
-- =========================================================
WITH city_stats AS (
    SELECT
        co.CountryID,
        co.CountryName,
        ci.CityID,
        ci.CityName,
        COUNT(DISTINCT v.CustomerID) AS NumberOfCustomers,
        COUNT(DISTINCT v.TransactionNumber) AS NumberOfInvoices,
        SUM(v.Revenue) AS TotalRevenue,
        SUM(v.Quantity) AS TotalQuantity
    FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis` AS v
    JOIN `sales-of-fmcg-stores.salesfmcg.customers` AS cu
        ON v.CustomerID = cu.CustomerID
    JOIN `sales-of-fmcg-stores.salesfmcg.cities` AS ci
        ON cu.CityID = ci.CityID
    JOIN `sales-of-fmcg-stores.salesfmcg.countries` AS co
        ON ci.CountryID = co.CountryID
    GROUP BY
        co.CountryID,
        co.CountryName,
        ci.CityID,
        ci.CityName
)
SELECT
    CountryID,
    CountryName,
    CtyID,
    CityName,
    NumberOfCustomers,
    NumberOfInvoices,
    ROUND(TotalRevenue, 2) AS TotalRevenue,
    TotalQuantity,
    ROUND(
        SAFE_DIVIDE(
            TotalRevenue,
            NumberOfCustomers
        ), 2
    ) AS AverageRevenuePerCustomer,
    ROUND(
        SAFE_DIVIDE(
            TotalRevenue,
            NumberOfInvoices
        ), 2
    ) AS AOV,
    ROUND(
        SAFE_DIVIDE(
            TotalRevenue * 100.0,
            SUM(TotalRevenue) OVER ()
        ), 2
    ) AS TotalRevenueContributionPercentage,
    RANK() OVER (
        ORDER BY TotalQuantity DESC
    ) AS ConsumptionVolumeRank
FROM city_stats
ORDER BY TotalRevenue DESC;
