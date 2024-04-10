SELECT Top 10*
FROM PortfolioProject..NashvilleHousing

--Setting the SALE date from datetime to show only date

ALTER TABLE PortfolioProject..NashvilleHousing
ADD UPdatedSaleDate Date;

UPDATE PortfolioProject..NashvilleHousing
SET UPdatedSaleDate = CAST(SaleDate as date) 

------
ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDate2 Date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate2 = CAST(SaleDate as date) 

--- Deleting the duplicate column created
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate2;

--------------Property Address Update 
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) as PropertyAdd
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
WHERE a.[UniqueID ] <> b.[UniqueID ] AND
a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
WHERE a.[UniqueID ] <> b.[UniqueID ] AND
a.PropertyAddress is NULL

--------------------------SPlit Address from City-------------------------------------------------------------------------------
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--STEP 1 
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--STEP 2 UPDATE
ALTER TABLE PortfolioProject..NashvilleHousing
ADD AddressLine1 varchar(255);
UPDATE PortfolioProject..NashvilleHousing
SET AddressLine1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 

ALTER TABLE PortfolioProject..NashvilleHousing
ADD City varchar(255);
UPDATE PortfolioProject..NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


-------------------------------------SPLIT OWNER ADDRESS USING PARSENAME--------------------------------------------------------------------------------------
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

---STEP 1
Select
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

--STEP 2
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--------------------------------------------------SOLD AS Vacant------------------------------------------
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS SoldCount
FROM PortfolioProject..NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY SoldCount

--STEP 1
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing 

----------STEP 2
UPDATE PortfolioProject..NashvilleHousing 
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing 

-------------------------------------------------------DELETE THE DUPLICATES--------------------------------------------
-- STEP 1 FIND OUT THE DUPLICATES
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1

------- STEP 2 DELETE OUT THE DUPLICATES
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1

----------------------------------------------------------------------------------------------------------------------------

