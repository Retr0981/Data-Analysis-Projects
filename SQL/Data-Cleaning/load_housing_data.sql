

CREATE TABLE DavidNiiArmahPortfolio.dbo.NashvilleHousing (
    UniqueID VARCHAR(20),
    ParcelID VARCHAR(50),
    LandUse VARCHAR(50),
    PropertyAddress VARCHAR(100),
    SaleDate VARCHAR(50),
    SalePrice FLOAT,
    LegalReference VARCHAR(50),
    SoldAsVacant VARCHAR (10),
    OwnerName VARCHAR(100),
    OwnerAddress VARCHAR(100),
    Acreage FLOAT,
    TaxDistrict VARCHAR(50),
    LandValue INT,
    BuildingValue INT,
    TotalValue INT,
    YearBuilt INT,
    Bedrooms SMALLINT,
    FullBath SMALLINT,
    HalfBath SMALLINT
);

BULK INSERT DavidNiiArmahPortfolio.dbo.NashvilleHousing
FROM 'C:\Users\david\Downloads\Nashville Housing Data for Data Cleaning.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

SELECT * FROM dbo.housing_data;

