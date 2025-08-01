 

-- Standardize Date Format 

UPDATE Nashville
SET SaleDate = CONVERT(Sale,SaleDate)

--Populate Property Adress data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--Breaking out Address into Individual Columns (Adress, City, State)

SELECT PropertyAddress 
FROM Nashville

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))AS Address
FROM Nashville


ALTER TABLE Nashville
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE Nashville
ADD PropertySplitCity Nvarchar(255);

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM Nashville


SELECT OwnerAddress
FROM Nashville



SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Nashville



ALTER TABLE Nashville
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE Nashville
ADD OwnerSplitCity Nvarchar(255);

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE Nashville
ADD OwnerSplitState Nvarchar(255);

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldASVacant), COUNT(SoldAsVacant)
FROM Nashville
GROUP BY SoldASVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM Nashville

UPDATE Nashville
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END




--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     ORDER BY 
                     UniqueID
    ) row_num
    FROM Nashville
    --ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress



--Delete Unused Coulmns

SELECT *
FROM Nashville

ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Nashville
DROP COLUMN SaleDate