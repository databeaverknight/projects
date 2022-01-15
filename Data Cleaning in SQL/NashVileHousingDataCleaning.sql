/*
Cleaning Data in SQL

*/

-- Overview of dataset
SELECT TOP 10 *
FROM PortFolio..NashvileHousing

-- Standardize Date Format
--- Check the new format
SELECT CONVERT(date,SaleDate)
FROM PortFolio..NashvileHousing

-- Create a new column for converting date
ALTER TABLE NashvileHousing
ADD SaleDateConverted Date

-- Update the SaleDateConverted column
UPDATE NashvileHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- See if it works
SELECT TOP 5 SaleDateConverted
FROM PortFolio..NashvileHousing


-- Sort Query by ParcelID
SELECT ParcelID, PropertyAddress
FROM PortFolio..NashvileHousing
ORDER BY ParcelID

--Populate PropertyAddress
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortFolio..NashvileHousing a
JOIN PortFolio..NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortFolio..NashvileHousing as a
JOIN PortFolio..NashvileHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Check the update

SELECT *
FROM PortFolio.dbo.NashVileHousing

-- Create new column for PropertyAddress
ALTER TABLE NashVileHousing
ADD PropertySplitAddress nvarchar(255)

-- Create new column for PropertyCity
ALTER TABLE NashVileHousing
ADD PropertySplitCity nvarchar(255)

-- Update PropertyAddress
UPDATE NashVileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

-- Update PropertyCity
UPDATE NashVileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- Check the update
SELECT TOP 10 PropertysplitAddress, PropertysplitCity
FROM PortFolio.dbo.NashVileHousing

SELECT TOP 10 OwnerAddress
FROM PortFolio..NashvileHousing

-- Create new column for OwnerAddress
ALTER TABLE NashVileHousing
ADD OwnerSplitAddress nvarchar(255)

-- Create new column for OwnerCity
ALTER TABLE NashVileHousing
ADD OwnerSplitCity nvarchar(255)

-- Create new column for OwnerState
ALTER TABLE NashVileHousing
ADD OwnerSplitState nvarchar(255)

-- Update OwnerSplitAddress to be included only address
UPDATE PortFolio..NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

-- Update OwnerSplitCity to be included only city
UPDATE PortFolio..NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

-- Update OwnerSplitState to be included only State
UPDATE PortFolio..NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

-- Check the updates
SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortFolio..NashvileHousing

-- Y/N or Yes/No ?
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortFolio.dbo.NashVileHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Convert Y/N to Yes/No
UPDATE PortFolio.dbo.NashVileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Check duplicates
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

-- Delete Duplicates

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

FROM Portfolio..NashVileHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
