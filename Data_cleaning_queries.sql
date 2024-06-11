-- Cleaning data in SQL Queries

Select * 
from HousingData

--Standarize date format

Select SaleDateConverted , convert(Date , SaleDate)
from HousingData

Alter Table HousingData
Add SaleDateConverted Date;

Update HousingData 
Set SaleDateConverted = convert(Date , SaleDate)

-- Populate Property address data

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingData as a
Join HousingData as b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingData as a
Join HousingData as b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- Breaking out address in individual colums(city,state,address)

Select
SUBSTRING(PropertyAddress ,1 , CHARINDEX(',' , PropertyAddress)-1)
,SUBSTRING(PropertyAddress ,CHARINDEX(',' , PropertyAddress) +1, len(PropertyAddress))
from HousingData

Alter Table HousingData
Add PropertSplitAddress nvarchar(255);

Update HousingData 
Set PropertSplitAddress = SUBSTRING(PropertyAddress ,1, CHARINDEX(',' , PropertyAddress)-1)

Alter Table HousingData
Add PropertySplitCity nvarchar(255);

Update HousingData 
Set PropertySplitCity = SUBSTRING(PropertyAddress ,CHARINDEX(',' , PropertyAddress) +1, len(PropertyAddress))

Select * from HousingData

Select 
PARSEName(Replace(OwnerAddress,',','.'),3),
PARSEName(Replace(OwnerAddress,',','.'),2),
PARSEName(Replace(OwnerAddress,',','.'),1)
from HousingData

Alter Table HousingData
Add OwnerSplitAddress nvarchar(255);

Update HousingData 
Set OwnerSplitAddress = PARSEName(Replace(OwnerAddress,',','.'),3)

Alter Table HousingData
Add OwnerSplitCity nvarchar(255);

Update HousingData 
Set OwnerSplitCity = PARSEName(Replace(OwnerAddress,',','.'),2)

Alter Table HousingData
Add OwnerSplitState nvarchar(255);

Update HousingData 
Set OwnerSplitState = PARSEName(Replace(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in sold as vacant field

Select Distinct(SoldAsVacant) ,Count(SoldAsVacant)
From HousingData
group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then  'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
From HousingData

Update HousingData
Set SoldAsVacant =  Case when SoldAsVacant = 'Y' then  'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End

-- Remove Duplicates

With RowNumCTE As(
Select * ,
ROW_NUMBER()Over(
	Partition by PropertyAddress,
				SaleDate,
				ParcelID,
				SalePrice,
				LegalReference
	order by UniqueID) as Row_num
from HousingData
)
--Delete
Select *
from RowNumCTE
Where Row_num>1
--order by Row_num desc

Select * 
from HousingData

--Delete Unused Columns

Alter Table HousingData
Drop Column PropertyAddress , OwnerAddress , TaxDistrict

Alter Table HousingData
Drop Column  SaleDate

				