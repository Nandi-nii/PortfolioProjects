--Cleaning Data in sql
select*
from PortfolioProject.dbo.NashvilleHousing

--Standardize date format
select SaleDateConverted, convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

--Drop column SaleDate
alter table dbo.NashvilleHousing drop column SaleDate

--Populate Property Address Data
select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

select *
from PortfolioProject.dbo.NashvilleHousing

--Same for Owner Address

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
PARSENAME(replace(OwnerAddress, ',', '.'),3),
PARSENAME(replace(OwnerAddress, ',', '.'),2),
PARSENAME(replace(OwnerAddress, ',', '.'),1)
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3) 

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2) 

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else  SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else  SoldAsVacant
	 end

--Remove duplicates

with RowNUMCTE as(
select*,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 order by
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing
)


select*
from RowNUMCTE
where row_num>1


--Delete unused columns


select*
from PortfolioProject.dbo.NashvilleHousing
 
alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress






