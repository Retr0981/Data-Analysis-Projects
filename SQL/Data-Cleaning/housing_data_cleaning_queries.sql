-- Standardize Date Format

SELECT CONVERT(SaleDate, DATE) AS SaleDate
FROM DavidNiiArmahPortfolio..NashvilleHousing;

-- The update query did not work so added a new column called SaleDate Converted instead
-- to standardize date format in a new column

UPDATE DavidNiiArmahPortfolio..NashvilleHousing
SET SaleDate = CONVERT(SaleDate, DATE);

ALTER TABLE DavidNiiArmahPortfolio..NashvilleHousing
ADD COLUMN SaleDateConverted Date;

UPDATE DavidNiiArmahPortfolio..NashvilleHousing
SET SaleDateConverted = CONVERT(SaleDate, DATE);

SELECT SaleDateConverted
FROM DavidNiiArmahPortfolio..NashvilleHousing;

-- Populate Property Address data
-- Set property address field as NULL if empty
UPDATE DavidNiiArmahPortfolio..NashvilleHousing SET PropertyAddress=IF(PropertyAddress='',NULL,PropertyAddress);

SELECT *
FROM DavidNiiArmahPortfolio..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Self Join 
-- COALESE converts NULL values from one column to another value specified after it

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM DavidNiiArmahPortfolio..NashvilleHousing a
JOIN DavidNiiArmahPortfolio..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- USE TEMPORARY TABLE TO UPDATE Property Address 

DROP  TABLE IF EXISTS #UpdatePropertyAddress;
CREATE TABLE #UpdatePropertyAddress(
a_ParcelID VARCHAR(50), 
a_PropertyAddress VARCHAR(100), 
b_ParceID VARCHAR(50), 
b_Property_Address VARCHAR(100)
);
INSERT INTO UpdatePropertyAddress
(SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM DavidNiiArmahPortfolio..NashvilleHousing a
JOIN DavidNiiArmahPortfolio..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL);

UPDATE DavidNiiArmahPortfolio..NashvilleHousing
INNER JOIN UpdatePropertyAddress
ON DavidNiiArmahPortfolio..NashvilleHousing.ParcelID = UpdatePropertyAddress.a_ParcelID
SET DavidNiiArmahPortfolio..NashvilleHousing.PropertyAddress = UpdatePropertyAddress.b_Property_Address;

-- Returns no NULL values, shows that PropertyAddress has been updated

SELECT * 
FROM DavidNiiArmahPortfolio..NashvilleHousing
WHERE PropertyAddress IS NULL;

-- Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM DavidNiiArmahPortfolio..NashvilleHousing;

-- USE SUBSTRING function to look at property address column at position one. Use LOCATE function to look 
-- for a specific string/char, in a particular column name, returning the char num  ',' is located at, 
-- so adding -1 at the end of the SUBSTRING function would take away the comma

Update a 
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
From DavidNiiArmahPortfolio..NashvilleHousing  a
Join DavidNiiArmahPortfolio..NashvilleHousing  b
         ON  a.ParcelID = b.ParcelID
		 AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM DavidNiiArmahPortfolio..NashvilleHousing;

ALTER TABLE DavidNiiArmahPortfolio..NashvilleHousing
ADD  PropertySplitAddress NVARCHAR(255);

UPDATE DavidNiiArmahPortfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE DavidNiiArmahPortfolio..NashvilleHousing
ADD  PropertySplitCity NVARCHAR(255);

UPDATE DavidNiiArmahPortfolio..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT PropertySplitAddress, PropertySplitCity 
FROM DavidNiiArmahPortfolio..NashvilleHousing



-- USE SUBSTRING_INDEX instead of SUBSTRING to split the Owner Address

Select OwnerAddress
From DavidNiiArmahPortfolio..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From DavidNiiArmahPortfolio..NashvilleHousing


ALTER TABLE DavidNiiArmahPortfolio..NashvilleHousing
ADD  OwnerSplitAddress NVARCHAR(255);

UPDATE DavidNiiArmahPortfolio..NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE DavidNiiArmahPortfolio..NashvilleHousing
ADD  OwnerSplitCity NVARCHAR(255);

UPDATE DavidNiiArmahPortfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE DavidNiiArmahPortfolio..NashvilleHousing
ADD  OwnerSplitState NVARCHAR(255);

UPDATE DavidNiiArmahPortfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT OwnerSplitAddress, OwnerSplitCity,OwnerSplitState
FROM DavidNiiArmahPortfolio..NashvilleHousing
--where OwnerSplitAddress is not null
--order by 1

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DavidNiiArmahPortfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);


SELECT SoldAsVacant,
CASE
	WHEN 'Y' THEN 'Yes'
	WHEN 'N' THEN 'No'
    ELSE SoldAsVacant
END AS SoldAsVacantUpdated
FROM DavidNiiArmahPortfolio..NashvilleHousing;

 

UPDATE DavidNiiArmahPortfolio..NashvilleHousing
SET SoldAsVacant = CASE
	WHEN 'Y' THEN 'Yes'
	WHEN 'N' THEN 'No'
    ELSE SoldAsVacant
END;




-- Remove Duplicates
-- PARTITION BY values that should be unique, where ROW_NUMBER returns the row_num 

WITH Row_Num_CTE AS (
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY 
					UniqueID
                    ) AS row_num
FROM DavidNiiArmahPortfolio..NashvilleHousing)
DELETE
FROM Row_Num_CTE
WHERE row_num > 1;

-- Deleting 

DELETE FROM DavidNiiArmahPortfolio..NashvilleHousing
WHERE UniqueID NOT IN (
    SELECT UniqueID FROM (
        SELECT UniqueID,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
            ORDER BY UniqueID
        ) AS row_num
        FROM DavidNiiArmahPortfolio..NashvilleHousing
    ) subquery
    WHERE row_num = 1
);

-- Delete Unused Columns

ALTER TABLE DavidNiiArmahPortfolio..NashvilleHousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;

-- Check final data cleaning results
SELECT * FROM DavidNiiArmahPortfolio..NashvilleHousing
