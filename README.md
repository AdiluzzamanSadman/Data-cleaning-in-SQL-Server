# Data-cleaning-in-SQL-Server


Select *
From PortfolioProject..NashvilleHousing


--Standardize Date Format

Select SaleDate, Convert(Date, Saledate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;


Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)


--Populate Property Address Data


Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,a.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null



Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is Null


--Breaking out Property Address into individual Columns(Address, City, States)

Select PropertyAddress
From PortfolioProject..NashvilleHousing



Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255);


Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255);


Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
FRom PortfolioProject..NashvilleHousing




Select OwnerAddress
FRom PortfolioProject..NashvilleHousing



Select
PARSENAME(Replace(OwnerAddress,',', '.'),3)
,PARSENAME(Replace(OwnerAddress,',', '.'),2)
,PARSENAME(Replace(OwnerAddress,',', '.'),1)
FRom PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);


Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'),3)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255);


Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'),2)




ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255);


Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'),1)


Select *
From PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject..NashvilleHousing



Update PortfolioProject..NashvilleHousing
set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End



-- Remove Duplicates


With RowNumCTE as (
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order BY 
					UniqueID
					) as row_num
From PortfolioProject..NashvilleHousing

)

Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress



-- Delete Unused Columns



Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column PropertyAddress, TaxDistrict, OwnerAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate
