select * from dbo.nashvillehousing

-- standardize date format--
select saleDate 
from dbo.nashvillehousing

alter table nashvillehousing 
add saleDateConverted Date

update nashvillehousing 
set saleDateConverted = convert(Date,saleDate)

select saleDateConverted
from nashvillehousing

select saleDateConverted, convert(Date, saleDate)
from nashvillehousing

-- populate property address data --

select *  
from nashvillehousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a 
join nashvillehousing b 
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a 
join nashvillehousing b 
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null
                 
-- breaking out address into individual columns(address, city, state)

select 
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address,
substring(PropertyAddress, charindex(',',PropertyAddress) + 1 , len(propertyAddress)) as city
from nashvillehousing

alter table nashvillehousing
add PropertySplitAddress varchar(255)

update nashvillehousing
set PropertySplitAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity varchar(255)

update nashvillehousing
set PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress) +1, len(PropertyAddress))


-- populate  owner address-- 

select owneraddress
from nashvillehousing
where owneraddress is not null

select 
PARSENAME(replace(OwnerAddress, ',' , '.'),3),
PARSENAME(replace(owneraddress, ',' , '.'),2),
PARSENAME(replace(owneraddress, ',' , '.'),1)
from nashvillehousing
where OwnerAddress is not null

alter table nashvillehousing
add ownerSplitAddress varchar(255)

alter table nashvillehousing
add ownerSplitCity varchar(255)

alter table nashvillehousing
add ownerSplitState varchar(255)

update nashvillehousing 
set ownerSplitAddress = parsename(replace(owneraddress, ',', '.'),3)

update nashvillehousing 
set ownerSplitCity = parsename(replace(owneraddress, ',', '.'),2)

update nashvillehousing 
set ownerSplitState = parsename(replace(owneraddress, ',', '.'),1)

select ownerSplitAddress, ownerSplitCity,ownerSplitState
from nashvillehousing
where ownerSplitAddress is not null

-- change Y and N to Yes and No in "sold as vacant field"

select distinct SoldAsVacant, count(soldasvacant)
from nashvillehousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y'  then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from nashvillehousing

update nashvillehousing
set SoldAsVacant = 
case when SoldAsVacant = 'Y'  then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


-- remove dupiclates -- 
with rownumcte as (
select *,
  ROW_NUMBER()over (
  partition by parcelID, propertyaddress, saleprice, saledate,legalreference
  order by uniqueid
  ) row_num
from nashvillehousing
)
select *  
from rownumcte
where row_num > 1

-- delete  unused columns--

alter table nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress

alter table nashvillehousing
drop column saledate

select *
from nashvillehousing









