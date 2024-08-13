/* 

Cleaning data in SQL queries

*/

SELECT * FROM NashvileHousing

---Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate) AS AdequateDate
FROM NashvileHousing

UPDATE NashvileHousing 
SET SaleDate = CONVERT(Date, SaleDate)


--If it doesen't update properly we can also do it like this

ALTER TABLE NashvileHousing
ADD SaleDateConverted Date;


UPDATE NashvileHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Adress data

SELECT * 
FROM NashvileHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-- Here we joined the table onitself because there are ParcelID's  with same name but different ID
 
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvileHousing A 
JOIN NashvileHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A 
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvileHousing A 
JOIN NashvileHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


------------------------------------
--Breaking out Adress Into Individual Columns(Address, City, State)

SELECT PropertyAddress
FROM NashvileHousing



SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvileHousing

ALTER TABLE NashvileHousing
ADD PropertySplitAdress NVARCHAR(255);


UPDATE NashvileHousing 
SET PropertySplitAdress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvileHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvileHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



---------- Same with PARSENAME function (Easier)

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvileHousing



ALTER TABLE NashvileHousing
ADD OwnerSplitAdress NVARCHAR(255)


UPDATE NashvileHousing 
SET OwnerSplitAdress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvileHousing
ADD OwnerSplitCity NVARCHAR(255)


UPDATE NashvileHousing 
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvileHousing
ADD OwnerplitState NVARCHAR(255)


UPDATE NashvileHousing 
SET OwnerplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------


----Change Y and N TO Yes and No in "Sold as vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT  SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END AS FixedName
FROM NashvileHousing



UPDATE NashvileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END


-----

------- Find and Remove duplicates

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
 FROM NashvileHousing
 )
 SELECT * FROM RowNumCTE
 WHERE row_num > 1

--
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
 FROM NashvileHousing
 )
 DELETE FROM RowNumCTE
 WHERE row_num > 1










--Delete unused collumns from cleared table

SELECT * FROM NashvileHousing

ALTER TABLE NashvileHousing
DROP COLUMN OwnerAdress,TaxDistrict, PropertyAddress, SaleDate












