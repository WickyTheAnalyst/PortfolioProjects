
-- Standardize Date Format

-- Add a new column for converted date
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

-- Update the new column with converted dates
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

-- Verify the changes
SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing;


----------------------------------------------------------------------------------------
-- Populate PropertyAddress

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

-- Retrieve ParcelID, PropertyAddress from NashvilleHousing where PropertyAddress is NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


-- Retrieve ParcelID, PropertyAddress, and corresponding values from NashvilleHousing where PropertyAddress is NULL, 
-- while comparing the rows based on ParcelID and excluding rows with the same UniqueID.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


-- Update PropertyAddress in NashvilleHousing by setting it to the non-null value between a.PropertyAddress and b.PropertyAddress,
-- based on matching ParcelID and excluding rows with the same UniqueID, for rows where PropertyAddress is NULL.

UPDATE a	
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


-- Breaking out Address into individual Columns (Address, City, State)

-- Select all columns from NashvilleHousing table
SELECT *
FROM NashvilleHousing;

-- Split PropertyAddress into separate columns for Address, City, and State
SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS CityState
FROM NashvilleHousing;


-- Adding new columns for split address

-- Add PropertySplitAddress column to NashvilleHousing table
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

-- Update PropertySplitAddress with the substring of Address
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

-- Add PropertySplitCity column to NashvilleHousing table
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

-- Update PropertySplitCity with the substring of City
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

------------------------------------------------------------------------------------ 

-- Select OwnerAddress column from NashvilleHousing table
SELECT OwnerAddress
FROM NashvilleHousing;

-- Extract last component of OwnerAddress using PARSENAME
SELECT PARSENAME(OwnerAddress, 1)
FROM NashvilleHousing;

-- Split OwnerAddress into separate components (City, State, Address) using PARSENAME and REPLACE
SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS City,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS State,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS Address
FROM NashvilleHousing;

-- Adding new columns for split owner address

-- Add OwnerSplitAddress column to NashvilleHousing table
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

-- Update OwnerSplitAddress with the parsed address component
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

-- Add OwnerSplitCity column to NashvilleHousing table
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

-- Update OwnerSplitCity with the parsed city component
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

-- Add OwnerSplitState column to NashvilleHousing table
ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

-- Update OwnerSplitState with the parsed state component
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Select all columns from NashvilleHousing table
SELECT *
FROM NashvilleHousing;
---------------------------------
--Change Y And N to Yes and No in "Sold As Vaccant"
-- Retrieve distinct SoldAsVacant values and their counts, ordered by count in descending order
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant) DESC;

-- Display SoldAsVacant values as 'YES' or 'No' using CASE statement
SELECT SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM NashvilleHousing;

-- Update SoldAsVacant values to 'YES' or 'No' using CASE statement
UPDATE NashvilleHousing
SET SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;


----------------------------------------
-- Remove duplicates using CTE and ROW_NUMBER()
-- (CTE)  RowNumCTE is used to assign row numbers to each row within groups of duplicates 
-- PARTITION BY clause defines the grouping criteria based on the specified columns. 
-- ORDER BY clause within ROW_NUMBER() determines the order of rows within each group.
-- DELETE statement removes rows from the RowNumCTE CTE where the row number is greater than 1, 
-- meaning only the first occurrence of each group (the row with row_num = 1) will be retained, effectively removing duplicates.

WITH RowNumCTE AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID) AS row_num
    FROM NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1;



---------------LEts Confirm it--

-- Display using CTE and ROW_NUMBER()

WITH RowNumCTE AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID) AS row_num
    FROM NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;




-- Delete unused columns from NashvilleHousing table

-- Drop columns OwnerAddress, TaxDistrict, and PropertyAddress from NashvilleHousing table
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress;

-- Drop column SaleDate from NashvilleHousing table
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

-- Select all columns from NashvilleHousing table
SELECT *
FROM NashvilleHousing;
