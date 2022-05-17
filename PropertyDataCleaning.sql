Select * 
From PortfolioProject.dbo.NashvilleHousing


--Standardize Date Format


Select SaleDateConverted, Convert(date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
Set SaleDate = Convert(date, SaleDate)


alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date, SaleDate)


-- Populate Property address Data


Select *
From PortfolioProject.dbo.NashvilleHousing 
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

Where a.PropertyAddress is NULL


Update a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	
Where a.PropertyAddress is NULL


-- Breaking out Address into Individual Coloumns ( address, City, State )

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing 
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address  -- To search a special word or something
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing 


alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing



-- OWNER Address using ParseName


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


Select *
From PortfolioProject.dbo.NashvilleHousing


--Change Y and N for Sold and Vacant


Select Distinct(SoldAsVacant), COUNT(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'no'
	   Else SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'no'
	   Else SoldAsVacant
	   END



-- Remove Duplicates

WITH RownNumCTE AS (
Select *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RownNumCTE
Where row_num > 1






-- Delete Unused Coloumn

Select *
From PortfolioProject.dbo.NashvilleHousing
 

Alter Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress , TaxDistrict, PropertyAddress


Alter Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate