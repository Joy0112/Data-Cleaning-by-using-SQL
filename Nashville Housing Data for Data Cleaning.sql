/*
Cleaning Data in SQL Queries
*/

USE `nashville`


SELECT *
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(SaleDate,DATE)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT 
	*
FROM 
	NashvilleHousing
ORDER BY
	ParcelID



SELECT 
	a.ParcelID, 
	a.PropertyAddress,
	b.ParcelID, 
	b.PropertyAddress, 
	IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM 
	NashvilleHousing a
JOIN 
	NashvilleHousing b
ON 
	a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID 
WHERE 
	a.PropertyAddress IS NULL


UPDATE `nashvillehousing` a
JOIN `nashvillehousing` b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID 
SET a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
WHERE a.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT 
	PropertyAddress
FROM 
	NashvilleHousing


SELECT
	SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1 ) AS Address,
	SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1 , LENGTH(PropertyAddress)) AS Address
FROM 
	NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1 )


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1 , LENGTH(PropertyAddress))




SELECT 
	*
FROM 
	NashvilleHousing



SELECT 
	OwnerAddress
FROM 
	NashvilleHousing


SELECT
	SUBSTRING_INDEX(OwnerAddress, ',',1),
	SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2), ',',-1),
	SUBSTRING_INDEX(OwnerAddress, ',',-1)
FROM 
	NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',',1)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2), ',',-1)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',',-1)



SELECT 
	*
FROM 
	NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

--  Change Y and N to Yes and No in 'Sold as Vacant' field
SELECT 	
	DISTINCT SoldAsVacant, COUNT(soldasvacant)
FROM 
	`nashvillehousing`
GROUP BY 
	SoldAsVacant
ORDER BY 
	2 

SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	END 
FROM 
	`nashvillehousing`

UPDATE `nashvillehousing`
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		   END 



--------------------------------------------------------------------------------------------------------------------------

-- Romove Duplicates
WITH RowNumCTE AS(
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
FROM 
	`nashvillehousing`
-- order by ParcelID
)

DELETE 
	r
FROM 
	RowNumCTE r
WHERE 
	row_num > 1


SELECT 
	*
FROM 
	`nashvillehousing`



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT 
	*
FROM 
	NashvilleHousing


ALTER TABLE `nashvillehousing`
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate


