-- Create the Date Dimension Table
CREATE TABLE DateDimension (
    DateKey NUMBER(10) PRIMARY KEY,
    DimensionDate DATE, 
    Day NUMBER,
    Month NUMBER,
    Year NUMBER,
    Quarter NUMBER,
    Weekday VARCHAR2(10),
    IsHoliday NUMBER(1)
);


-- Create the Customer Dimension Table
CREATE TABLE CustomerDimension (
    CustomerID NUMBER PRIMARY KEY,      
    FirstName VARCHAR2(50),
    LastName VARCHAR2(50),
    Email VARCHAR2(100),
    Address VARCHAR2(100),
    City VARCHAR2(50),
    Country VARCHAR2(50),
    Phone VARCHAR2(20)
);

-- Create the Product Dimension Table
CREATE TABLE ProductDimension (
    ProductID NUMBER PRIMARY KEY,
    ProductName VARCHAR2(100),
    Category VARCHAR2(50),
    Description VARCHAR2(255),
    Price NUMBER(10, 2),
    StockQuantity NUMBER
);

-- Create the Payment Dimension Table
CREATE TABLE PaymentDimension (
    PaymentID NUMBER PRIMARY KEY,
    OrderID NUMBER,
    PaymentDate DATE,
    PaymentAmount NUMBER(10, 2),
    PaymentMethod VARCHAR2(50)
);

-- Create the Promotion Dimension Table
CREATE TABLE PromotionDimension (
    PromotionID NUMBER,
    PromotionName VARCHAR2(100),
    DiscountPercentage NUMBER(5, 2),
    StartDate DATE,
    EndDate DATE
);


-- Create the Sales Fact Table
CREATE TABLE SalesFact (
    SalesID INT,
    DateKey NUMBER(10),
    CustomerID INT,
    ProductID INT,
    OrderID INT,
    Quantity INT,
    ItemPrice DECIMAL(10, 2),
    DiscountAmount DECIMAL(10, 2),
    TotalPrice DECIMAL(10, 2),
    PaymentID INT,
    PromotionID INT,
    CONSTRAINT fk_date_dim FOREIGN KEY (DateKey) REFERENCES DateDimension(DateKey),
    CONSTRAINT fk_customer_dim FOREIGN KEY (CustomerID) REFERENCES CustomerDimension(CustomerID),
    CONSTRAINT fk_product_dim FOREIGN KEY (ProductID) REFERENCES ProductDimension(ProductID),
    CONSTRAINT fk_payment_dim FOREIGN KEY (PaymentID) REFERENCES PaymentDimension(PaymentID)
);
