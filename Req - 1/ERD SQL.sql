-- Create the Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Address VARCHAR(100),
    City VARCHAR(50),
    Country VARCHAR(50),
    Phone VARCHAR(20)
);

-- Create the Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Description VARCHAR(255),
    Price DECIMAL(10, 2),
    StockQuantity INT
);

-- Create the Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    OrderTotal DECIMAL(10, 2),
    ShippingAddress VARCHAR(100),
    ShippingCity VARCHAR(50),
    ShippingCountry VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create the Payments Table
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    OrderID INT,
    PaymentDate DATE,
    PaymentAmount DECIMAL(10, 2),
    PaymentMethod VARCHAR(50),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Create the Reviews Table
CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    ReviewDate DATE,
    Rating INT,
    ReviewText VARCHAR(500),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Create the Promotions Table
CREATE TABLE Promotions (
    PromotionID INT PRIMARY KEY,
    PromotionName VARCHAR(100),
    DiscountPercentage DECIMAL(5, 2),
    StartDate DATE,
    EndDate DATE
);

-- Create the PromotionUsage Table
CREATE TABLE PromotionUsage (
    PromotionUsageID INT PRIMARY KEY,
    OrderID INT,
    PromotionID INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (PromotionID) REFERENCES Promotions(PromotionID)
);

-- Create the OrderItems Table
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    ItemPrice DECIMAL(10, 2),
    DiscountAmount DECIMAL(10, 2),
    PromotionID INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);



--  DROP TABLE PromotionUsage;
--  DROP TABLE Promotions;
--  DROP TABLE Reviews;
--  DROP TABLE Payments;
--  DROP TABLE OrderItems;
--  DROP TABLE Orders;
--  DROP TABLE Products;
--  DROP TABLE Customers;