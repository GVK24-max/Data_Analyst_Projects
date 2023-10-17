SELECT *
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]


  ---------------------------------------------------------------------------------
--Standardizing date format in the columns

SELECT SaleDateConverted, Convert(Date,SaleDate)
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)


-------------------------------------------------------------------------------------
--Cleaning the Property address column

Select *
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]
  Where PropertyAddress is null

  Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing] as a
  Join [Portfolio_Project_2].[dbo].[NashvilleHousing] as b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

  Update a
  Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing] as a
  Join [Portfolio_Project_2].[dbo].[NashvilleHousing] as b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null


  ---------------------------------------------------------------------------------------
--Breaking the Address into Individual columns (Address, City, State)

Select PropertyAddress
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]
  --Where PropertyAddress is null 

--Separate columns for the Address and city name. 
Select 
Substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) AS Address,
Substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) AS Address
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))


SELECT *
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]


  --------------------------------------------------------------------------------------------------
--Splitting the owner Address.
SELECT OwnerAddress
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]


SELECT 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


SELECT *
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]


---------------------------------------------------------------------------------------
  --Change Y and N to Yes & No in column SoldAsVacant

 SELECT Distinct(SoldAsVacant), Count (SoldAsVacant)
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]
  group by SoldAsVacant
  order by 2


  Select SoldAsVacant,
  Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant 
		End
 FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]


 Update NashvilleHousing
 SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant 
		End


---------------------------------------------------------------------------------------------------------
--Remove Duplicates 

With RownumCTE AS(
Select *,
	Row_Number() Over (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID
					) row_num

 FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]
 --Order By ParcelID
 )
Select *
 From RownumCTE
 where row_num > 1
 --Order by PropertyAddress


 SELECT *
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]


---------------------------------------------------------------------------------------------------
--Deleting Unused Columns

SELECT *
  FROM [Portfolio_Project_2].[dbo].[NashvilleHousing]

Alter Table [Portfolio_Project_2].[dbo].[NashvilleHousing]
Drop Column SaleDate