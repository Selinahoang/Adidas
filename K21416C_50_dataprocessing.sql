-- Xem kiểu dữ liệu của bảng
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sale' AND TABLE_SCHEMA = 'dbo';

-- thêm cột day
ALTER TABLE [dbo].[sale]
ADD invoice_day INT;

ALTER TABLE [dbo].[sale]
ADD invoice_month INT;

ALTER TABLE [dbo].[sale]
ADD invoice_year INT;


CREATE TABLE dbo.Date
(
    InvoiceDate DATETIME,
    InvoiceDay VARCHAR(2),
    InvoiceMonth VARCHAR(2),
    InvoiceYear VARCHAR(4)
);

-- Insert dữ liệu vào bảng tạm từ bảng Sale
INSERT INTO [dbo].[Date] (InvoiceDate)
SELECT DISTINCT [Invoice Date]
FROM [dbo].[sale]
WHERE [Invoice Date] IS NOT NULL;


-- Cập nhật cột InvoiceDay, InvoiceMonth, InvoiceYear
UPDATE dbo.Date
SET
    InvoiceDay = RIGHT('0' + CONVERT(VARCHAR(2), DAY(InvoiceDate)), 2),
    InvoiceMonth = RIGHT('0' + CONVERT(VARCHAR(2), MONTH(InvoiceDate)), 2),
    InvoiceYear = CONVERT(VARCHAR(4), YEAR(InvoiceDate));

	-- Thêm cột date_id vào bảng dbo.date
ALTER TABLE dbo.date
ADD date_id VARCHAR(8);

-- Cập nhật giá trị cho cột date_id
UPDATE dbo.date
SET date_id = REPLACE(CONVERT(VARCHAR(10), InvoiceDate, 120), '-', '');

-- 
CREATE TABLE dbo.Retailer
(
    Retailer_id int,
    Retailer VARCHAR(500)
);

INSERT INTO [dbo].[Retailer] (Retailer_id)
SELECT DISTINCT [Retailer ID]
FROM [dbo].[sale]
WHERE [Retailer ID] IS NOT NULL;

UPDATE r
SET
    r.[Retailer]=s.[Retailer]
FROM [dbo].[Retailer] r
JOIN [dbo].[sale] s ON r.[Retailer_id] = s.[Retailer ID];
-- tạo bảng city
CREATE TABLE dbo.city
(
    city_id int,
    city VARCHAR(500),
	State VARCHAR(500)
);
INSERT INTO [dbo].[city](city)
SELECT DISTINCT [City]
FROM [dbo].[sale]
WHERE [City] IS NOT NULL;

UPDATE c
SET
    c.[State]=s.[State]
FROM [dbo].[city] c
JOIN [dbo].[sale] s ON c.[city] = s.[City];
-- set city_id
ALTER TABLE [dbo].[city]
ADD [city_id] INT IDENTITY(1,1) PRIMARY KEY;
-- set bảng product
CREATE TABLE dbo.product
(
    Product VARCHAR(500)
);
INSERT INTO [dbo].[product](Product)
SELECT DISTINCT [Product]
FROM [dbo].[sale]
WHERE [Product] IS NOT NULL;
-- set product id
ALTER TABLE [dbo].[product]
ADD [city_id] INT IDENTITY(1,1) PRIMARY KEY;

--set bảng sales Method
CREATE TABLE dbo.SalesMethod
(
    [Sales Method] VARCHAR(500)
);
INSERT INTO [dbo].[SalesMethod]([Sales Method])
SELECT DISTINCT [Sales Method]
FROM [dbo].[sale]
WHERE [Sales Method] IS NOT NULL;
-- set method_id
ALTER TABLE [dbo].[SalesMethod]
ADD [method_id] INT IDENTITY(1,1) PRIMARY KEY;
--thêm các cột id vào bảng sale
ALTER TABLE [dbo].[sale]
ADD [city_id] INT,
	[date_id] int,
	[product_id] int,
	[Region_ID] int,
	[method_id] int;

UPDATE s
SET
    s.[method_id]=m.[method_id]
FROM [dbo].[sale] s
JOIN [dbo].[SalesMethod] m ON s.[Sales Method] = m.[Sales Method];
-- set sale_id
ALTER TABLE [dbo].[sale]
ADD [sale_id] INT IDENTITY(1,1) PRIMARY KEY;

-- Thêm một cột tạm thời để lưu trữ dữ liệu mới
ALTER TABLE dbo.sale
ADD retailer_id_temp int;

-- Cập nhật dữ liệu mới từ cột cũ sang cột tạm thời
UPDATE dbo.sale
SET retailer_id_temp = CONVERT(int, [Retailer ID]);

-- Xóa cột cũ
ALTER TABLE dbo.sale
DROP COLUMN [Retailer ID];

-- Đổi tên cột tạm thời thành tên cột cũ
EXEC sp_rename 'dbo.sale.retailer_id_temp', 'Retailer ID', 'COLUMN';

-- Thêm cột reviewer_id vào bảng dbo.sale
ALTER TABLE dbo.sale
ADD  INT;

-- Cập nhật giá trị của cột reviewer_id
WITH RankedRetailers AS (
  SELECT
    Retailer,
    [Retailer_ID],
    ROW_NUMBER() OVER (PARTITION BY [Retailer] ORDER BY [Retailer_ID]) AS [retailerid]
  FROM [dbo].[Retailer]
)
UPDATE r
SET r.retailerid = rr.retailerid
FROM dbo.Retailer AS r
JOIN RankedRetailers AS rr
ON r.Retailer = rr.Retailer AND r.[Retailer_id] = rr.[Retailer_id];

EXEC sp_rename 'dbo.sale.reviewer_id', 'retailerid', 'COLUMN';

ALTER TABLE dbo.retailer
ADD retailerid INT;

INSERT INTO [dbo].[retail](retailerid)
SELECT DISTINCT [retailerid]
FROM [dbo].[Retailer]
WHERE [retailerid] IS NOT NULL;

alter table [dbo].[Retailer]
add Retailer VARCHAR(500) ;

UPDATE [dbo].[retail]
SET
    [dbo].[Retail].[Retailer_id]=[dbo].[sale].[Retailer ID]
FROM [dbo].[retail]
JOIN [dbo].[sale] ON [dbo].[Retail].[retailerid]=[dbo].[sale].[retailerid];

update s
set
	s.retailerid=r.[retailerid]
from [dbo].[sale] s
join [dbo].[retailer] r on s.Retailer=r.Retailer and s.[Retailer ID]=r.Retailer_id
-- Thêm cột retailerid vào bảng dbo.retailer
ALTER TABLE dbo.sale
add retailerid int;

-- Cập nhật giá trị của cột retailerid
ALTER TABLE [dbo].[retailer]
ADD [retailerid] INT IDENTITY(1,1) PRIMARY KEY;
