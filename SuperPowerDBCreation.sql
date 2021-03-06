create database sp_db

use sp_db

GO

/*Table Creation*/

CREATE TABLE Country
(
id int identity	primary key,
email nvarchar(30) not null,
pass nvarchar(30) not null,
cName nvarchar(40) not null,
remaining int not null,
color nvarchar(10) not null
)

CREATE TABLE Province
(
id int identity primary key,
pname nvarchar(40) not null,
governorName nvarchar(40), /*Might be null*/
population int not null,
taxRate int not null default 10,
budget int not null,
countryID int references Country(id) not null,
capital tinyint default 0
)

CREATE TABLE StatusWith
(
c1id int references Country(id) not null,
c2id int references Country(id) not null,
statusBetween nvarchar(40) not null,
primary key(c1id, c2id)
)

CREATE TABLE Aggrements
(
id int identity primary key,
aggrementType nvarchar(50) not null,
) 

CREATE TABLE CountryAggrements
(
id int identity primary key,
c1Id int references Country(id) not null,
c2Id int references Country(id) not null,
aggrementId int references Aggrements(id) not null,
endDate DateTime not null
)

CREATE TABLE NaturalResources
(
id int identity primary key,
name nvarchar(40) not null,
type nvarchar(40) not null
)

CREATE TABLE Products
(
id int identity primary key,
name nvarchar(40) not null
)

CREATE TABLE Investments
(
id int identity primary key,
type nvarchar(40) not null,
price int not null default 0
)

CREATE TABLE ProvinceResources
(
provinceID int references Province(id) not null,
resourceID int references NaturalResources(id) not null,
reserve int not null,
primary key(provinceID, resourceID)
)

CREATE TABLE ProvinceProducts
(
provinceID int references Province(id) not null,
productID int references Products(id) not null,
primary key(provinceID, productID)
)

CREATE TABLE ProvinceInvestments
(
provinceID int references Province(id) not null,
investmentID int references Investments(id) not null,
degree int not null,
primary key(provinceID, investmentID)
)

CREATE TABLE CountryResources
(
countryID int references Country(id) not null,
resourceID int references NaturalResources(id) not null,
remaining int not null,
maxCapacity int not null,
primary key(countryID, resourceID)
)

CREATE TABLE CountryProducts
(
countryID int references Country(id) not null,
productID int references Products(id) not null,
remaining int not null,
maxCapacity int not null,
primary key(countryID, productID)
)

CREATE TABLE ArmyCorps
(
id int identity primary key,
corpType nvarchar(40) not null,
numOfUnits int not null,
countryID int references Country(id) not null,
provinceID int references Province(id) not null,
targetProvinceID int references Province(id), /*might be null*/
mission nvarchar(40) not null,
startTime DateTime not null,
duration int not null
)

CREATE TABLE Battle
(
id int identity primary key,
c1ID int references Country(id) not null,
c2ID int references Country(id) not null,
result nvarchar(40) not null
)

CREATE TABLE Regulations
(
id int identity primary key,
title nvarchar(40) not null,
content nvarchar(200) not null
)

CREATE TABLE Laws
(
id int identity primary key,
title nvarchar(40) not null,
content nvarchar(200) not null
)

CREATE TABLE CountryRegulations
(
cId int references Country(id) not null,
rId int references Regulations(id) not null,
startDate DateTime not null,
endDate DateTime not null
primary key(cId,rId)
)

CREATE TABLE CountryLaws
(
cId int references Country(id) not null,
lId int references Laws(id) not null,
startDate DateTime not null,
primary key(cId,lId)
)


CREATE TABLE AggrementOffers
(
id int identity primary key,
c1Id int references Country(id) not null,
c2Id int references Country(id) not null,
aggrementId int references Aggrements(id) not null,
offerEndDate DateTime not null
)


/*Default data*/

insert into dbo.Country values('x@hotmail.com', 'passx', 'Free Lands', 10000, 'FF6347')

insert into dbo.Province values('adana','NULL',2200000, 10, 0, 1, 0)
insert into dbo.Province values('adıyaman','NULL',615000, 10, 0, 1, 0)
insert into dbo.Province values('afyon','NULL', 715000, 10, 0, 1, 0)
insert into dbo.Province values('ağrı','NULL', 536000, 10, 0, 1, 0)
insert into dbo.Province values('amasya','NULL', 329000, 10, 0, 1, 0)
insert into dbo.Province values('ankara','NULL', 5400000, 10, 0, 1, 0)
insert into dbo.Province values('antalya','NULL', 2300000, 10, 0, 1, 0)
insert into dbo.Province values('artvin','NULL', 166000, 10, 0, 1, 0)
insert into dbo.Province values('aydın','NULL', 1000000, 10, 0, 1, 0)
insert into dbo.Province values('balıkesir','NULL', 1200000, 10, 0, 1, 0)
insert into dbo.Province values('bilecik','NULL', 221000, 10, 0, 1, 0)
insert into dbo.Province values('bingöl','NULL', 273000, 10, 0, 1, 0)
insert into dbo.Province values('bitlis','NULL', 341000, 10, 0, 1, 0)
insert into dbo.Province values('bolu','NULL', 303000, 10, 0, 1, 0)
insert into dbo.Province values('burdur','NULL', 264000, 10, 0, 1, 0)
insert into dbo.Province values('bursa','NULL', 2900000, 10, 0, 1, 0)
insert into dbo.Province values('çanakkale','NULL', 530000, 10, 0, 1, 0)
insert into dbo.Province values('çankırı','NULL', 186000, 10, 0, 1, 0)
insert into dbo.Province values('çorum','NULL', 528000, 10, 0, 1, 0)
insert into dbo.Province values('denizli','NULL', 1000000, 10, 0, 1, 0)
insert into dbo.Province values('diyarbakır','NULL', 1700000, 10, 0, 1, 0)
insert into dbo.Province values('edirne','NULL', 406000, 10, 0, 1, 0)
insert into dbo.Province values('elazığ','NULL', 583000, 10, 0, 1, 0)
insert into dbo.Province values('erzincan','NULL', 231000, 10, 0, 1, 0)
insert into dbo.Province values('erzurum','NULL', 760000, 10, 0, 1, 0)
insert into dbo.Province values('eskişehir','NULL', 860000, 10, 0, 1, 0)
insert into dbo.Province values('gaziantep','NULL', 2000000, 10, 0, 1, 0)
insert into dbo.Province values('giresun','NULL', 437000, 10, 0, 1, 0)
insert into dbo.Province values('gümüşhane','NULL', 170000, 10, 0, 1, 0)
insert into dbo.Province values('hakkari','NULL', 275000, 10, 0, 1, 0)
insert into dbo.Province values('hatay','NULL', 1500000, 10, 0, 1, 0)
insert into dbo.Province values('ısparta','NULL', 433000, 10, 0, 1, 0)
insert into dbo.Province values('mersin','NULL', 1700000, 10, 0, 1, 0)
insert into dbo.Province values('istanbul','NULL', 15000000, 10, 0, 1, 0)
insert into dbo.Province values('izmir','NULL', 4200000, 10, 0, 1, 0)
insert into dbo.Province values('kars','NULL', 287000, 10, 0, 1, 0)
insert into dbo.Province values('kastamonu','NULL', 373000, 10, 0, 1, 0)
insert into dbo.Province values('kayseri','NULL', 1300000, 10, 0, 1, 0)
insert into dbo.Province values('kırklareli','NULL', 356000, 10, 0, 1, 0)
insert into dbo.Province values('kırşehir','NULL', 234000, 10, 0, 1, 0)
insert into dbo.Province values('kocaeli','NULL', 1800000, 10, 0, 1, 0)
insert into dbo.Province values('konya','NULL', 2100000, 10, 0, 1, 0)
insert into dbo.Province values('kütahya','NULL', 572000, 10, 0, 1, 0)
insert into dbo.Province values('malatya','NULL', 786000, 10, 0, 1, 0)
insert into dbo.Province values('manisa','NULL', 1400000, 10, 0, 1, 0)
insert into dbo.Province values('kahramanmaraş','NULL', 1100000, 10, 0, 1, 0)
insert into dbo.Province values('mardin','NULL', 809000, 10, 0, 1, 0)
insert into dbo.Province values('muğla','NULL', 938000, 10, 0, 1, 0)
insert into dbo.Province values('muş','NULL', 404000, 10, 0, 1, 0)
insert into dbo.Province values('nevşehir','NULL', 292000, 10, 0, 1, 0)
insert into dbo.Province values('niğde','NULL', 352000, 10, 0, 1, 0)
insert into dbo.Province values('ordu','NULL', 742000, 10, 0, 1, 0)
insert into dbo.Province values('rize','NULL', 331000, 10, 0, 1, 0)
insert into dbo.Province values('sakarya','NULL', 990000, 10, 0, 1, 0)
insert into dbo.Province values('samsun','NULL', 1300000, 10, 0, 1, 0)
insert into dbo.Province values('siirt','NULL', 324000, 10, 0, 1, 0)
insert into dbo.Province values('sinop','NULL', 207000, 10, 0, 1, 0)
insert into dbo.Province values('sivas','NULL', 621000, 10, 0, 1, 0)
insert into dbo.Province values('tekirdağ','NULL', 1000000, 10, 0, 1, 0)
insert into dbo.Province values('tokat','NULL', 602000, 10, 0, 1, 0)
insert into dbo.Province values('trabzon','NULL', 786000, 10, 0, 1, 0)
insert into dbo.Province values('tunceli','NULL', 82000, 10, 0, 1, 0)
insert into dbo.Province values('şanlıurfa','NULL', 1900000, 10, 0, 1, 0)
insert into dbo.Province values('uşak','NULL', 364000, 10, 0, 1, 0)
insert into dbo.Province values('van','NULL', 1100000, 10, 0, 1, 0)
insert into dbo.Province values('yozgat','NULL', 418000, 10, 0, 1, 0)
insert into dbo.Province values('zonguldak','NULL', 596000, 10, 0, 1, 0)
insert into dbo.Province values('aksaray','NULL', 402000, 10, 0, 1, 0)
insert into dbo.Province values('bayburt','NULL', 80000, 10, 0, 1, 0)
insert into dbo.Province values('karaman','NULL', 246000, 10, 0, 1, 0)
insert into dbo.Province values('kırıkkale','NULL', 278000, 10, 0, 1, 0)
insert into dbo.Province values('batman','NULL', 585000, 10, 0, 1, 0)
insert into dbo.Province values('şırnak','NULL', 503000, 10, 0, 1, 0)
insert into dbo.Province values('bartın','NULL', 193000, 10, 0, 1, 0)
insert into dbo.Province values('ardahan','NULL', 97000, 10, 0, 1, 0)
insert into dbo.Province values('ığdır','NULL', 194000, 10, 0, 1, 0)
insert into dbo.Province values('yalova','NULL', 251000, 10, 0, 1, 0)
insert into dbo.Province values('karabük','NULL', 244000, 10, 0, 1, 0)
insert into dbo.Province values('kilis','NULL', 136000, 10, 0, 1, 0)
insert into dbo.Province values('osmaniye','NULL', 527000, 10, 0, 1, 0)
insert into dbo.Province values('düzce','NULL', 377000, 10, 0, 1, 0)

insert into dbo.Aggrements values('Declare War')
insert into dbo.Aggrements values('Cease-fire Aggrement')
insert into dbo.Aggrements values('Peace Aggrement')
insert into dbo.Aggrements values('Tax Payment Aggrement')
insert into dbo.Aggrements values('Open Borders For Army')
insert into dbo.Aggrements values('Weapon Aggrement')
insert into dbo.Aggrements values('Medic Tool Aggrement')

insert into dbo.NaturalResources values('water', 'drink')
insert into dbo.NaturalResources values('wheat', 'food')
insert into dbo.NaturalResources values('iron', 'resource')
insert into dbo.NaturalResources values('silicon', 'resource')

insert into dbo.Products values('weapon')
insert into dbo.Products values('medic tool')

insert into dbo.Investments values('hospital', 1000)
insert into dbo.Investments values('barracks', 1500)
insert into dbo.Investments values('water stock', 750)
insert into dbo.Investments values('food stock', 750)

GO

/*RESOURCES*/
/*Water*/
DECLARE @cnt INT = 1;
WHILE @cnt < 82
BEGIN
	insert into dbo.ProvinceResources values(@cnt,1,99999)
	SET @cnt = @cnt + 1;
END;

GO

/*Wheat*/
DECLARE @cnt INT = 1;
WHILE @cnt < 82
BEGIN
	insert into dbo.ProvinceResources values(@cnt,2,99999)
	SET @cnt = @cnt + 1;
END;

GO


/*Iron*/
DECLARE @cnt INT = 1;
WHILE @cnt < 82
BEGIN
	insert into dbo.ProvinceResources values(@cnt,3,999)
	SET @cnt = @cnt + 1;
END;

GO

/*Silicon*/
DECLARE @cnt INT = 1;
WHILE @cnt < 82
BEGIN
	insert into dbo.ProvinceResources values(@cnt,4,99)
	SET @cnt = @cnt + 1;
END;

GO


/*PRODUCTS*/
/*Weapon*/
DECLARE @cnt INT = 1;
WHILE @cnt < 82
BEGIN
	insert into dbo.ProvinceProducts values(@cnt,1)
	SET @cnt = @cnt + 1;
END;

GO


/*Medic tool*/
DECLARE @cnt INT = 1;
WHILE @cnt < 82
BEGIN
	insert into dbo.ProvinceProducts values(@cnt,2)
	SET @cnt = @cnt + 1;
END;

GO

DECLARE @cnt INT = 1;
WHILE @cnt < 4
BEGIN
	insert into dbo.CountryResources values(1, @cnt, 1000, 9999 / @cnt)
	SET @cnt = @cnt + 1;
END;
