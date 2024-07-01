--Cleaning data drom SQL Queries:

SELECT *
FROM [PortfolioProject].dbo.NashvilleHousing

--1) Standardize Date Format:
ALTER TABLE NashvilleHousing
ALTER COLUMN  SaleDate DATE;

--2) Populating PropertyAddress Data:
SELECT *
FROM [PortfolioProject].dbo.NashvilleHousing
WHERE PropertyAddress is NULL

--(Using ParcelID as a reference to populate PropertyAddress Column)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].dbo.NashvilleHousing a
JOIN [PortfolioProject].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--(final query)
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].dbo.NashvilleHousing a
JOIN [PortfolioProject].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--3) Breaking Property Address into Individual Columns(Address, City, State):
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Property_Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Property_City
FROM [PortfolioProject].dbo.NashvilleHousing

--Adding the Property_Address and Property_City Columns to the Original Table:
ALTER TABLE NashvilleHousing
ADD Property_Address Nvarchar(255);

UPDATE NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD Property_City Nvarchar(255);

UPDATE NashvilleHousing
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--4) Breaking Owner Address into Individual Columns(Address, City, State):
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Owner_Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS Owner_City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS Owner_State
FROM [PortfolioProject].dbo.NashvilleHousing

--Adding the Owner_Address, Owner_City and Owner_State Columns to the Original Table:
ALTER TABLE NashvilleHousing
ADD Owner_Address Nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD Owner_City Nvarchar(255);

UPDATE NashvilleHousing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD Owner_State Nvarchar(255);

UPDATE NashvilleHousing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Changing Y and N to Yes and No in "SoldAsVacant" Column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PortfolioProject].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END

--Removing Duplicates:
WITH Duplicate_Rec_CTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY 
					UniqueID
					) AS row_num

FROM [PortfolioProject].dbo.NashvilleHousing
)
SELECT *
FROM Duplicate_Rec_CTE
WHERE row_num > 1
ORDER BY ParcelID

--Delete Unused Columns
SELECT *
FROM [PortfolioProject].dbo.NashvilleHousing

ALTER TABLE [PortfolioProject].dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress