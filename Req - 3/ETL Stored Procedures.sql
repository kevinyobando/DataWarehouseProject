CREATE OR REPLACE PROCEDURE PopulateStagingTables AS
BEGIN
    -- Insert data into StagingCustomers
    INSERT INTO StagingCustomers (CustomerID, FirstName, LastName, Email, Address, City, Country, Phone)
    SELECT CustomerID, FirstName, LastName, Email, Address, City, Country, Phone
    FROM eCommerce_db_user.Customers;

    -- Insert data into StagingProducts
    INSERT INTO StagingProducts (ProductID, ProductName, Category, Description, Price, StockQuantity)
    SELECT ProductID, ProductName, Category, Description, Price, StockQuantity
    FROM eCommerce_db_user.Products;

    -- Insert data into StagingOrders
    INSERT INTO StagingOrders (OrderID, CustomerID, OrderDate, OrderTotal, ShippingAddress, ShippingCity, ShippingCountry)
    SELECT OrderID, CustomerID, OrderDate, OrderTotal, ShippingAddress, ShippingCity, ShippingCountry
    FROM eCommerce_db_user.Orders;

    -- Insert data into StagingOrderItems
    INSERT INTO StagingOrderItems (OrderItemID, OrderID, ProductID, Quantity, ItemPrice, DiscountAmount, PromotionID)
    SELECT OrderItemID, OrderID, ProductID, Quantity, ItemPrice, DiscountAmount, PromotionID
    FROM eCommerce_db_user.OrderItems;

    -- Insert data into StagingPayments
    INSERT INTO StagingPayments (PaymentID, OrderID, PaymentDate, PaymentAmount, PaymentMethod)
    SELECT PaymentID, OrderID, PaymentDate, PaymentAmount, PaymentMethod
    FROM eCommerce_db_user.Payments;

    -- Insert data into StagingReviews
    INSERT INTO StagingReviews (ReviewID, CustomerID, ProductID, ReviewDate, Rating, ReviewText)
    SELECT ReviewID, CustomerID, ProductID, ReviewDate, Rating, ReviewText
    FROM eCommerce_db_user.Reviews;

    -- Insert data into StagingPromotions
    INSERT INTO StagingPromotions (PromotionID, OrderID, PromotionName, DiscountPercentage, StartDate, EndDate)
    SELECT p.PromotionID, pu.OrderID, p.PromotionName, p.DiscountPercentage, p.StartDate, p.EndDate
    FROM eCommerce_db_user.Promotions p
    JOIN eCommerce_db_user.PromotionUsage pu ON p.PromotionID = pu.PromotionID;

    -- Commit the transaction
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        -- Handle exceptions if any
        ROLLBACK;
        RAISE;
END;
/




-- select * from stagingcustomers;
-- select * from stagingorderitems;
-- select * from stagingorders;
-- select * from stagingpayments;
-- select * from stagingproducts;
-- select * from stagingpromotions;
-- select * from stagingreviews;

CREATE OR REPLACE NONEDITIONABLE PROCEDURE PopulatePreLoadTables AS
BEGIN
    -- Load and transform data into PreLoadOrderData (Type 1 SCD)
    MERGE INTO PreLoadOrderData tgt
    USING (
        SELECT
            oi.orderitemid,
            so.OrderID,
            dd.DateKey,
            so.CustomerID,
            oi.ProductID,
            oi.Quantity,
            oi.ItemPrice,
            oi.DiscountAmount,
            oi.Quantity * oi.ItemPrice - oi.DiscountAmount as TotalPrice,
            p.PaymentID,
            pu.PromotionID
        FROM StagingOrders so
        JOIN StagingOrderItems oi ON so.OrderID = oi.OrderID
        JOIN DateDimension dd ON so.OrderDate = dd.DimensionDate
        LEFT JOIN StagingPayments p ON so.OrderID = p.OrderID
        LEFT JOIN StagingPromotions pu ON so.OrderID = pu.OrderID
    ) src ON (tgt.OrderItemID = src.OrderItemID)
    WHEN MATCHED THEN
        UPDATE SET tgt.OrderID = src.OrderID,
                   tgt.DateKey = src.DateKey,
                   tgt.CustomerID = src.CustomerID,
                   tgt.ProductID = src.ProductID,
                   tgt.Quantity = src.Quantity,
                   tgt.ItemPrice = src.ItemPrice,
                   tgt.DiscountAmount = src.DiscountAmount,
                   tgt.TotalPrice = src.TotalPrice,
                   tgt.PaymentID = src.PaymentID,
                   tgt.PromotionID = src.PromotionID
    WHEN NOT MATCHED THEN
        INSERT (OrderItemID, OrderID, DateKey, CustomerID, ProductID, Quantity, ItemPrice, DiscountAmount, TotalPrice, PaymentID, PromotionID)
        VALUES (src.OrderItemID, src.OrderID, src.DateKey, src.CustomerID, src.ProductID, src.Quantity, src.ItemPrice, src.DiscountAmount, src.TotalPrice, src.PaymentID, src.PromotionID);

    -- Load data into PreLoadDateDimension (Type 1 SCD)
    MERGE INTO PreLoadDateDimension tgt
    USING (
        SELECT DISTINCT dd.DateKey, dd.DimensionDate, dd.Day, dd.Month, dd.Year, dd.Quarter, dd.Weekday, dd.IsHoliday
        FROM PreLoadOrderData pod
        JOIN DateDimension dd ON pod.DateKey = dd.DateKey
    ) src ON (tgt.DateKey = src.DateKey)
    WHEN MATCHED THEN
        UPDATE SET tgt.DimensionDate = src.DimensionDate,
                   tgt.Day = src.Day,
                   tgt.Month = src.Month,
                   tgt.Year = src.Year,
                   tgt.Quarter = src.Quarter,
                   tgt.Weekday = src.Weekday,
                   tgt.IsHoliday = src.IsHoliday
    WHEN NOT MATCHED THEN
        INSERT (DateKey, DimensionDate, Day, Month, Year, Quarter, Weekday, IsHoliday)
        VALUES (src.DateKey, src.DimensionDate, src.Day, src.Month, src.Year, src.Quarter, src.Weekday, src.IsHoliday);

    -- Load data into PreLoadCustomerDimension (Type 1 SCD)
    MERGE INTO PreLoadCustomerDimension tgt
    USING (
        SELECT DISTINCT
               CustomerID,
               FirstName,
               LastName,
               Email,
               Address,
               City,
               Country,
               Phone
        FROM StagingCustomers
    ) src ON (tgt.CustomerID = src.CustomerID)
    WHEN MATCHED THEN
        UPDATE SET tgt.FirstName = src.FirstName,
                   tgt.LastName = src.LastName,
                   tgt.Email = src.Email,
                   tgt.Address = src.Address,
                   tgt.City = src.City,
                   tgt.Country = src.Country,
                   tgt.Phone = src.Phone
    WHEN NOT MATCHED THEN
        INSERT (CustomerID, FirstName, LastName, Email, Address, City, Country, Phone)
        VALUES (src.CustomerID, src.FirstName, src.LastName, src.Email, src.Address, src.City, src.Country, src.Phone);

    -- Load data into PreLoadProductDimension (Type 1 SCD)
    MERGE INTO PreLoadProductDimension tgt
    USING (
        SELECT DISTINCT
               ProductID,
               ProductName,
               Category,
               Description,
               Price,
               StockQuantity
        FROM StagingProducts
    ) src ON (tgt.ProductID = src.ProductID)
    WHEN MATCHED THEN
        UPDATE SET tgt.ProductName = src.ProductName,
                   tgt.Category = src.Category,
                   tgt.Description = src.Description,
                   tgt.Price = src.Price,
                   tgt.StockQuantity = src.StockQuantity
    WHEN NOT MATCHED THEN
        INSERT (ProductID, ProductName, Category, Description, Price, StockQuantity)
        VALUES (src.ProductID, src.ProductName, src.Category, src.Description, src.Price, src.StockQuantity);

    -- Load data into PreLoadPaymentDimension (Type 1 SCD)
    MERGE INTO PreLoadPaymentDimension tgt
    USING (
        SELECT DISTINCT PaymentID, OrderID, PaymentDate, PaymentAmount, PaymentMethod
        FROM StagingPayments
    ) src ON (tgt.PaymentID = src.PaymentID)
    WHEN MATCHED THEN
        UPDATE SET tgt.OrderID = src.OrderID,
                   tgt.PaymentDate = src.PaymentDate,
                   tgt.PaymentAmount = src.PaymentAmount,
                   tgt.PaymentMethod = src.PaymentMethod
    WHEN NOT MATCHED THEN
        INSERT (PaymentID, OrderID, PaymentDate, PaymentAmount, PaymentMethod)
        VALUES (src.PaymentID, src.OrderID, src.PaymentDate, src.PaymentAmount, src.PaymentMethod);

    -- Load data into PreLoadPromotionDimension (Type 2 SCD)
    MERGE INTO PreLoadPromotionDimension tgt
    USING StagingPromotions src
    ON (tgt.PromotionID = src.PromotionID)
    WHEN MATCHED THEN
        UPDATE SET tgt.EndDate = src.StartDate - INTERVAL '1' DAY
    WHERE src.EndDate IS NOT NULL
        AND tgt.EndDate IS NULL
    WHEN NOT MATCHED THEN
        INSERT (PromotionID, PromotionName, DiscountPercentage, StartDate, EndDate)
        VALUES (src.PromotionID, src.PromotionName, src.DiscountPercentage, src.StartDate, src.EndDate);

    -- Commit the transaction
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Handle exceptions if any
        ROLLBACK;
        RAISE;
END;


CREATE OR REPLACE PROCEDURE PopulateSalesFact AS
BEGIN
    -- Clear existing data in the Sales Fact table
    DELETE FROM SalesFact;

    -- Load data into SalesFact from StagingOrderItems and StagingPayments
    INSERT INTO SalesFact (SalesID, DateKey, CustomerID, ProductID, OrderID, Quantity, ItemPrice, DiscountAmount, TotalPrice, PaymentID, PromotionID)
    SELECT
          OrderItemID
        , DateKey
        , CustomerID
        , ProductID
        , OrderID
        , Quantity
        , ItemPrice
        , DiscountAmount
        , TotalPrice
        , PaymentID
        , PromotionID
    FROM PreLoadOrderData

    -- Commit the transaction
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Handle exceptions if any
        ROLLBACK;
        RAISE;
END;
/
