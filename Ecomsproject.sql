use ecomm
select * from customer_churn
#CHECK ORIGINAL DATA
SELECT COUNT(*) AS Original_Row_Count FROM customer_churn
SELECT * FROM customer_churn LIMIT 10
#CLEANED TABLE
CREATE TABLE customer_churn_cleaned LIKE customer_churn
INSERT INTO customer_churn_cleaned SELECT * FROM customer_churn
SELECT COUNT(*) AS Cleaned_Table_Row_Count FROM customer_churn_cleaned
#DELETE OUTLIERS
DELETE FROM customer_churn_cleaned WHERE WarehouseToHome > 100
SELECT COUNT(*) AS Remaining_Outliers FROM customer_churn_cleaned WHERE WarehouseToHome > 100
#MISSING VALUES
SELECT COUNT(*) AS Total_Rows,
SUM(WarehouseToHome IS NULL) AS Missing_WarehouseToHome,
SUM(HourSpendOnApp IS NULL) AS Missing_HourSpendOnApp,
SUM(OrderAmountHikeFromlastYear IS NULL) AS Missing_OrderAmountHike,
SUM(DaySinceLastOrder IS NULL) AS Missing_DaySinceLastOrder,
SUM(Tenure IS NULL) AS Missing_Tenure,
SUM(CouponUsed IS NULL) AS Missing_CouponUsed,
SUM(OrderCount IS NULL) AS Missing_OrderCount FROM customer_churn_cleaned
# Calculate the mean
UPDATE customer_churn_cleaned SET WarehouseToHome =
(
    SELECT ROUND(AVG(WarehouseToHome))
    FROM
    (
        SELECT WarehouseToHome
        FROM customer_churn_cleaned
        WHERE WarehouseToHome IS NOT NULL
    ) AS temp
) WHERE WarehouseToHome IS NULL

UPDATE customer_churn_cleaned SET HourSpendOnApp =
(
    SELECT ROUND(AVG(HourSpendOnApp))
    FROM
    (
        SELECT HourSpendOnApp
        FROM customer_churn_cleaned
        WHERE HourSpendOnApp IS NOT NULL
    ) AS temp
) WHERE HourSpendOnApp IS NULL

UPDATE customer_churn_cleaned SET OrderAmountHikeFromlastYear =
(
    SELECT ROUND(AVG(OrderAmountHikeFromlastYear))
    FROM
    (
        SELECT OrderAmountHikeFromlastYear
        FROM customer_churn_cleaned
        WHERE OrderAmountHikeFromlastYear IS NOT NULL
    ) AS temp
) WHERE OrderAmountHikeFromlastYear IS NULL

UPDATE customer_churn_cleaned SET DaySinceLastOrder =
(
    SELECT ROUND(AVG(DaySinceLastOrder))
    FROM
    (
        SELECT DaySinceLastOrder
        FROM customer_churn_cleaned
        WHERE DaySinceLastOrder IS NOT NULL
    ) AS temp
) WHERE DaySinceLastOrder IS NULL
SELECT
    SUM(WarehouseToHome IS NULL) AS Missing_WarehouseToHome,
    SUM(HourSpendOnApp IS NULL) AS Missing_HourSpendOnApp,
    SUM(OrderAmountHikeFromlastYear IS NULL) AS Missing_OrderAmountHike,SUM(DaySinceLastOrder IS NULL) AS Missing_DaySinceLastOrder FROM customer_churn_cleaned
#MODE IMPUTATION
UPDATE customer_churn_cleaned SET Tenure =
(
    SELECT Tenure FROM
    (
        SELECT Tenure, COUNT(*) AS Frequency
        FROM customer_churn_cleaned
        WHERE Tenure IS NOT NULL
        GROUP BY Tenure
        ORDER BY Frequency DESC, Tenure ASC
        LIMIT 1
    ) AS temp)WHERE Tenure IS NULL

UPDATE customer_churn_cleaned
SET CouponUsed =
(
    SELECT CouponUsed
    FROM
    (
        SELECT CouponUsed, COUNT(*) AS Frequency
        FROM customer_churn_cleaned
        WHERE CouponUsed IS NOT NULL
        GROUP BY CouponUsed
        ORDER BY Frequency DESC, CouponUsed ASC
        LIMIT 1
    ) AS temp
)
WHERE CouponUsed IS NULL

UPDATE customer_churn_cleaned
SET OrderCount =
(
    SELECT OrderCount
    FROM
    (
        SELECT OrderCount, COUNT(*) AS Frequency
        FROM customer_churn_cleaned
        WHERE OrderCount IS NOT NULL
        GROUP BY OrderCount
        ORDER BY Frequency DESC, OrderCount ASC
        LIMIT 1
    ) AS temp
)
WHERE OrderCount IS NULL

SELECT SUM(Tenure IS NULL) AS Missing_Tenure,
    SUM(CouponUsed IS NULL) AS Missing_CouponUsed,SUM(OrderCount IS NULL) AS Missing_OrderCount FROM customer_churn_cleaned

#Phone → Mobile Phone
UPDATE customer_churn_cleaned SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone'  
SELECT PreferredLoginDevice, COUNT(*) AS Customer_Count FROM customer_churn_cleaned
GROUP BY PreferredLoginDevice  

#Mobile → Mobile Phone
UPDATE customer_churn_cleaned SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile'
SELECT PreferedOrderCat, COUNT(*) AS Customer_Count FROM customer_churn_cleaned
GROUP BY PreferedOrderCat
#COD → Cash on Delivery CC  → Credit Card
UPDATE customer_churn_cleaned SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD'
UPDATE customer_churn_cleaned SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC'
SELECT PreferredPaymentMode, COUNT(*) AS Customer_Count FROM customer_churn_cleaned
GROUP BY PreferredPaymentMode
#RENAME COLUMNS
ALTER TABLE customer_churn_cleaned RENAME COLUMN PreferedOrderCat TO PreferredOrderCat
ALTER TABLE customer_churn_cleaned RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp
DESCRIBE customer_churn_cleaned
#   Complain = 1 → Yes Complain = 0 → No
ALTER TABLE customer_churn_cleaned ADD COLUMN ComplaintReceived VARCHAR(3)
UPDATE customer_churn_cleaned SET ComplaintReceived =
    CASE
    
        WHEN Complain = 1 THEN 'Yes'
        ELSE 'No'
    END
SELECT  COUNT(*) AS Customer_Count FROM customer_churn_cleaned

#DROP ORIGINAL Churn AND Complain COLUMNS
ALTER TABLE customer_churn_cleaned DROP COLUMN Churn
ALTER TABLE customer_churn_cleaned DROP COLUMN Complain
SELECT * FROM customer_churn_cleaned LIMIT 10

#QUESTION 1 Retrieve the count of churned and active customers
SELECT
    ChurnStatus,
    COUNT(*) AS Customer_Count
FROM customer_churn_cleaned
GROUP BY ChurnStatus
ORDER BY ChurnStatus
#   QUESTION 2 Average tenure and total cashback amount of churned customers.
SELECT ROUND(AVG(Tenure), 2) AS Average_Tenure,
    SUM(CashbackAmount) AS Total_Cashback_Amount
FROM customer_churn_cleaned WHERE ChurnStatus = 'Churned'

#   QUESTION 3 Percentage of churned customers who complained.
SELECT
    ROUND(
        SUM(
            CASE
                WHEN ChurnStatus = 'Churned'
                 AND ComplaintReceived = 'Yes'
                THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        SUM(
            CASE
                WHEN ChurnStatus = 'Churned'
                THEN 1
                ELSE 0
            END
        ),
        2
    ) AS Percentage_Churned_Customers_Who_Complained
FROM customer_churn_cleaned

#   QUESTION 4    City tier with the highest number of churned customers
SELECT
    CityTier,
    COUNT(*) AS Churned_Customer_Count
FROM customer_churn_cleaned
WHERE ChurnStatus = 'Churned'
  AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY Churned_Customer_Count DESC
LIMIT 1

#    Most preferred payment mode among active customers.
SELECT PreferredPaymentMode, COUNT(*) AS Customer_Count
FROM customer_churn_cleaned
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY Customer_Count DESC
LIMIT 1
#QUESTION 6    Total order amount hike from last year for customers who are single and prefer mobile phones
SELECT SUM(OrderAmountHikeFromlastYear) AS Total_Order_Amount_Hike
FROM customer_churn_cleaned
WHERE MaritalStatus = 'Single' AND PreferredOrderCat = 'Mobile Phone'

#QUESTION 7 Average number
SELECT ROUND(AVG(NumberOfDeviceRegistered), 2) AS Average_Devices_Registered
FROM customer_churn_cleaned
WHERE PreferredPaymentMode = 'UPI'
#QUESTION 8 highest number of customers
SELECT CityTier, COUNT(*) AS Customer_Count
FROM customer_churn_cleaned
GROUP BY CityTier
ORDER BY Customer_Count DESC
LIMIT 1

#QUESTION 9 highest number of coupons
SELECT Gender, SUM(CouponUsed) AS Total_Coupons_Used
FROM customer_churn_cleaned
GROUP BY Gender
ORDER BY Total_Coupons_Used DESC
LIMIT 1

#QUESTION 10 maximum hours spent on the app in each preferred order category

SELECT PreferredOrderCat, COUNT(*) AS Customer_Count, MAX(HoursSpentOnApp) AS Maximum_Hours_Spent_On_App
FROM customer_churn_cleaned
GROUP BY PreferredOrderCat
ORDER BY PreferredOrderCat

#QUESTION 11  Total order count for customers who prefer Credit Card
SELECT
    SUM(OrderCount) AS Total_Order_Count
FROM customer_churn_cleaned
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore =
      (
          SELECT MAX(SatisfactionScore)
          FROM customer_churn_cleaned
      )

#QUESTION 12 Average satisfaction score of customers
SELECT ROUND(AVG(SatisfactionScore), 2) AS Average_Satisfaction_Score
FROM customer_churn_cleaned
WHERE ComplaintReceived = 'Yes'

#QUESTION 13 Preferred order categories among customers
SELECT PreferredOrderCat, COUNT(*) AS Customer_Count
FROM customer_churn_cleaned
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat
ORDER BY Customer_Count DESC

#  QUESTION 14 Top 3 preferred order categories with the highest average cashback amount
SELECT PreferredOrderCat, ROUND(AVG(CashbackAmount), 2) AS Average_Cashback_Amount
FROM customer_churn_cleaned
GROUP BY PreferredOrderCat
ORDER BY Average_Cashback_Amount DESC
LIMIT 3

#QUESTION 15 Preferred payment modes
SELECT PreferredPaymentMode, ROUND(AVG(Tenure), 2) AS Average_Tenure, SUM(OrderCount) AS Total_Order_Count
FROM customer_churn_cleaned
GROUP BY PreferredPaymentMode
HAVING ROUND(AVG(Tenure)) = 10
   AND SUM(OrderCount) > 500
ORDER BY Total_Order_Count DESC

#QUESTION 16 Categorize customers according to WarehouseToHome distance and show churn status breakdown

SELECT
    CASE
        WHEN WarehouseToHome <= 5
            THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10
            THEN 'Close Distance'
        WHEN WarehouseToHome <= 15
            THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS Distance_Category,

    ChurnStatus,

    COUNT(*) AS Customer_Count

FROM customer_churn_cleaned

GROUP BY
    CASE
        WHEN WarehouseToHome <= 5
            THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10
            THEN 'Close Distance'
        WHEN WarehouseToHome <= 15
            THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END,
    ChurnStatus

ORDER BY
    CASE
        WHEN Distance_Category = 'Very Close Distance' THEN 1
        WHEN Distance_Category = 'Close Distance' THEN 2
        WHEN Distance_Category = 'Moderate Distance' THEN 3
        WHEN Distance_Category = 'Far Distance' THEN 4
    END,
    ChurnStatus


#QUESTION 17
SELECT CustomerID, MaritalStatus, CityTier, OrderCount, PreferredOrderCat, PreferredPaymentMode, ChurnStatus, ComplaintReceived
FROM customer_churn_cleaned
WHERE MaritalStatus = 'Married'
  AND CityTier = 1
  AND OrderCount >
      (
          SELECT AVG(OrderCount)
          FROM customer_churn_cleaned
      )
ORDER BY OrderCount DESC

CREATE TABLE customer_returns
(
    ReturnID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    ReturnDate DATE,
    RefundAmount INT,

    CONSTRAINT fk_customer_returns_customer
        FOREIGN KEY (CustomerID)
        REFERENCES customer_churn(CustomerID)
)


INSERT INTO customer_returns
(
    ReturnID,
    CustomerID,
    ReturnDate,
    RefundAmount
)
VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990)

SELECT
    r.ReturnID,
    r.CustomerID,
    r.ReturnDate,
    r.RefundAmount,
    c.Tenure,
    c.PreferredLoginDevice,
    c.CityTier,
    c.WarehouseToHome,
    c.PreferredPaymentMode,
    c.Gender,
    c.HoursSpentOnApp,
    c.NumberOfDeviceRegistered,
    c.PreferredOrderCat,
    c.SatisfactionScore,
    c.MaritalStatus,
    c.NumberOfAddress,
    c.OrderAmountHikeFromlastYear,
    c.CouponUsed,
    c.OrderCount,
    c.DaySinceLastOrder,
    c.CashbackAmount,
    c.ComplaintReceived,
    c.ChurnStatus

FROM customer_returns r

INNER JOIN customer_churn_cleaned c
    ON r.CustomerID = c.CustomerID

WHERE c.ChurnStatus = 'Churned'
  AND c.ComplaintReceived = 'Yes'

ORDER BY r.ReturnDate