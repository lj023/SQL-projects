-- Cleaning Data in MySQL

USE Projects;

Select *
From nashville_housing;

-- Populate Property Address data

SELECT *
FROM nashville_housing
-- WHERE PropertyAddress = ''
ORDER BY ParcelID;


-- Disable safe updates to allow the update without a WHERE clause
SET SQL_SAFE_UPDATES = 0;

-- Update NewPropertyAddress based on matching ParcelID and different UniqueID
UPDATE nashville_housing a
JOIN nashville_housing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.NewPropertyAddress = IF(a.NewPropertyAddress = '', b.NewPropertyAddress, a.NewPropertyAddress)
WHERE a.NewPropertyAddress = '' OR a.NewPropertyAddress IS NULL;

-- Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;

-- Display rows where NewPropertyAddress is still empty
SELECT *
FROM nashville_housing
WHERE NewPropertyAddress = '';


-- Breaking out Address into Individual Columns (Address, City, State)

-- Display the original NewPropertyAddress
SELECT NewPropertyAddress
FROM nashville_housing;

-- Split NewPropertyAddress into Address1 and Address2 based on comma
SELECT
    SUBSTRING(NewPropertyAddress, 1, LOCATE(',', NewPropertyAddress) - 1) AS Address1,
    SUBSTRING(NewPropertyAddress, LOCATE(',', NewPropertyAddress) + 1, LENGTH(NewPropertyAddress)) AS Address2
FROM nashville_housing;


-- Add columns for split property address
ALTER TABLE nashville_housing
ADD PropertySplitAddress NVARCHAR(255);

-- Update PropertySplitAddress with the first part of NewPropertyAddress
UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(NewPropertyAddress, 1, LOCATE(',', NewPropertyAddress) - 1);

-- Add columns for split property city
ALTER TABLE nashville_housing
ADD PropertySplitCity NVARCHAR(255);

-- Update PropertySplitCity with the second part of NewPropertyAddress
UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(NewPropertyAddress, LOCATE(',', NewPropertyAddress) + 1, LENGTH(NewPropertyAddress));

-- Display the updated nashville_housing table
SELECT *
FROM nashville_housing;

-- Display OwnerAddress for reference
SELECT OwnerAddress
FROM nashville_housing;


-- Extract Address, City, and State from OwnerAddress

SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1) AS Address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS State
FROM nashville_housing;


-- Add columns for split owner address
ALTER TABLE nashville_housing
ADD OwnerSplitAddress NVARCHAR(255);

-- Update OwnerSplitAddress with the first part of OwnerAddress
UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1);

-- Add columns for split owner city
ALTER TABLE nashville_housing
ADD OwnerSplitCity NVARCHAR(255);

-- Update OwnerSplitCity with the second part of OwnerAddress
UPDATE nashville_housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

-- Add columns for split owner state
ALTER TABLE nashville_housing
ADD OwnerSplitState NVARCHAR(255);

-- Update OwnerSplitState with the third part of OwnerAddress
UPDATE nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);

-- Display the updated nashville_housing table
SELECT *
FROM nashville_housing;


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant,
                COUNT(SoldAsVacant) AS Count
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY Count;

-- Display SoldAsVacant with updated values (changing Y to Yes, N to No)
SELECT SoldAsVacant,
       CASE 
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'No'
           ELSE SoldAsVacant
       END AS UpdatedSoldAsVacant
FROM nashville_housing;


-- Select duplicate rows based on certain columns
SELECT *
FROM (
    SELECT
        UniqueID,
        ROW_NUMBER() OVER (PARTITION BY ParcelID, NewPropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
    FROM
        nashville_housing
) AS A 
WHERE row_num > 1;

    
-- Remove Duplicates
DELETE n
FROM nashville_housing n
JOIN (
    SELECT
        UniqueID,
        ROW_NUMBER() OVER (PARTITION BY ParcelID, NewPropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
    FROM
        nashville_housing
) AS cte
ON n.UniqueID = cte.UniqueID
WHERE cte.row_num > 1;


-- Display the original table
SELECT *
FROM nashville_housing;

-- Remove unused columns
ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN NewPropertyAddress,
DROP COLUMN SaleDate;
