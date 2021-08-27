/*

Cleaning Data in SQL Queries

*/
SELECT *
FROM PortFolio.dbo.NashVileHousing

-- Standardize Data Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortFolio.dbo.NashVileHousing

UPDATE NashVileHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashVileHousing
Add SaleDateConverted Date;

UPDATE NashVileHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data

SELECT *
FROM PortFolio.dbo.NashVileHousing
--Where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortFolio.dbo.NashVileHousing AS a
JOIN PortFolio.dbo.NashVileHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortFolio.dbo.NashVileHousing AS a
JOIN PortFolio.dbo.NashVileHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortFolio.dbo.NashVileHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortFolio.dbo.NashVileHousing

ALTER TABLE NashVileHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashVileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashVileHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashVileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT*
FROM PortFolio.dbo.NashVileHousing

SELECT OwnerAddress
FROM PortFolio.dbo.NashVileHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortFolio.dbo.NashVileHousing

ALTER TABLE PortFolio.dbo.NashVileHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PortFolio.dbo.NashVileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE PortFolio.dbo.NashVileHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortFolio.dbo.NashVileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE PortFolio.dbo.NashVileHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortFolio.dbo.NashVileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


SELECT*
FROM PortFolio.dbo.NashVileHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortFolio.dbo.NashVileHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortFolio.dbo.NashVileHousing

UPDATE PortFolio.dbo.NashVileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

FROM PortFolio.dbo.NashVileHousing

)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Delete Unused Columns

SELECT *
FROM PortFolio.dbo.NashVileHousing

ALTER TABLE PortFolio.dbo.NashVileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

