/*
Cleaning Data in SQL Queries
*/

select *
from PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--Standardize Date Format

select SaleDateConverted
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address data

--Analyzing data for duplicate 'ParcelID' values
select *
from PortfolioProject..NashvilleHousing
order by ParcelID

--Analyzing 'PropertyAddress' column for rows with same 'ParcelID' but different 'UniqueID'
select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, isnull(t1.PropertyAddress, t2.PropertyAddress)
from PortfolioProject..NashvilleHousing t1
join PortfolioProject..NashvilleHousing t2
	on t1.ParcelID = t2.ParcelID
	and t1.[UniqueID ] != t2.[UniqueID ]
where t1.PropertyAddress is null

--Populating 'PropertyAddress' column for rows with same 'ParcelID' but different 'UniqueID'
update t1
set PropertyAddress = isnull(t1.PropertyAddress, t2.PropertyAddress)
from PortfolioProject..NashvilleHousing t1
join PortfolioProject..NashvilleHousing t2
	on t1.ParcelID = t2.ParcelID
	and t1.[UniqueID ] != t2.[UniqueID ]
where t1.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

--Analyzing 'PropertyAddress' column
select PropertyAddress
from PortfolioProject..NashvilleHousing

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

--Adding and populating 'PropertySplitAddress' column
alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

--Adding and populating 'PropertySpliCity' column
alter table NashvilleHousing
add PropertySpliCity nvarchar(255);

update NashvilleHousing
set PropertySpliCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))

--Analyzing 'OwnerAddress' column
select OwnerAddress 
from PortfolioProject..NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

--Adding and populating 'OwnerSplitAddress' column
alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

--Adding and populating 'OwnerSpliCity' column
alter table NashvilleHousing
add OwnerSpliCity nvarchar(255);

update NashvilleHousing
set OwnerSpliCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

--Adding and populating 'OwnerSplitState' column
alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

--Analyzing 'SoldAsVacant' column
select distinct(SoldAsVacant), count(SoldAsVacant) as SoldAsVacantCount
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2 desc

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

with RowNumCTE as(
	select *, ROW_NUMBER() over (
		partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
		order by UniqueID) row_num
	from PortfolioProject..NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--select *
--from PortfolioProject..NashvilleHousing