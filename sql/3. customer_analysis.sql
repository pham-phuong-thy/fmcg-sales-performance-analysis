-- =========================================================
-- 3.1 CUSTOMER SEGMENTATION
-- =========================================================
WITH customer_stats AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT TransactionNumber) AS Frequency,
        SUM(Revenue) AS Monetary
    FROM `sales-of-fmcg-stores.salesfmcg.vw_sales_analysis`
    GROUP BY CustomerID
),
scored AS (
    SELECT *,
        NTILE(4) OVER (
            ORDER BY Monetary DESC
        ) AS MonetaryQuartile,
        NTILE(4) OVER (
            ORDER BY Frequency DESC
        ) AS FrequencyQuartile
    FROM customer_stats
),
segmented AS (
    SELECT
        CustomerID,
        CASE
            WHEN MonetaryQuartile = 1
             AND FrequencyQuartile = 1
                THEN 'VIP - High Value & High Frequency'
            WHEN MonetaryQuartile = 1
             AND FrequencyQuartile > 1
                THEN 'Big Spender'
            WHEN MonetaryQuartile > 1
             AND FrequencyQuartile = 1
                THEN 'Frequent Shopper'
            WHEN MonetaryQuartile = 4
             AND FrequencyQuartile = 4
                THEN 'Low Value Customer'
            ELSE 'Regular Customer'
        END AS CustomerSegment
    FROM scored
)
SELECT
    CustomerSegment,
    COUNT(*) AS NumberOfCustomers,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage
FROM segmented
GROUP BY CustomerSegment
ORDER BY NumberOfCustomers DESC;
