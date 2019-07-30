use sp_db

select name from sys.tables

GO

Create proc register (@email nvarchar(40), @password nvarchar(40), @cName nvarchar(40), @remaining int, @color nvarchar(8))
as
begin
SET NOCOUNT ON;
if not exists (select * from dbo.Country where email=@email)
	begin
	if not exists (select * from dbo.Country where cName=@cName)
		begin
		Declare @uId int;
		Declare @cId int;
		insert into dbo.Country OUTPUT inserted.id values(@email, @password, @cName, @remaining, @color)
		SET @cId = @@IDENTITY
		update TOP (1) dbo.Province set countryID=@cId where countryID=1
		select @cId as Result
		end
	else
		select 0 as Result
	end
else
	select -1 as Result
end

GO

Create proc login (@email nvarchar(40), @password nvarchar(40)) 
as
begin
SET NOCOUNT ON;
if exists(select id as Result from dbo.Country where email=@email and pass=@password)
	begin
	select id as Result from dbo.Country where email=@email and pass=@password
	end
else
	select -1 as Result
end

GO

/*Get all aggrements which includes user's country*/
Create proc getAggrements(@cId int)
as
begin
SET NOCOUNT ON;
select CA.id, C1.cname, C2.cname, A.aggrementType, CA.endDate
from CountryAggrements CA
inner join Aggrements A on CA.aggrementId=A.id
inner join Country C1 on CA.c1id=C1.id
inner join Country C2 on CA.c2id=C2.id
where CA.c1id=@cId or CA.c2id=@cId
end

GO

/*Get Aggrement with given CountryAggrement.id*/
Create proc getAggrement(@cAggrementId int)
as
begin
SET NOCOUNT ON;
select CA.id, C1.cname, C2.cname, A.aggrementType, CA.endDate
from CountryAggrements CA
inner join Aggrements A on CA.aggrementId=A.id
inner join Country C1 on CA.c1id=C1.id
inner join Country C2 on CA.c2id=C2.id
where CA.id=@cAggrementId
end

GO

Create proc getAggrementTypes
as
begin
SET NOCOUNT ON;
select * from dbo.Aggrements
end

GO

Create proc getAggrementOffers(@cId int)
as
begin
SET NOCOUNT ON;
select CA.id, C1.cname, C2.cname, A.aggrementType, CA.offerEndDate
from AggrementOffers CA
inner join Aggrements A on CA.aggrementId=A.id
inner join Country C1 on CA.c1Id=C1.id
inner join Country C2 on CA.c2Id=C2.id
where CA.c1id=@cId or CA.c2id=@cId
end

GO

Create proc getAggrementOffer(@id int)
as
begin
SET NOCOUNT ON;
select CA.id, C1.cname, C2.cname, A.aggrementType, CA.offerEndDate
from AggrementOffers CA
inner join Aggrements A on CA.aggrementId=A.id
inner join Country C1 on CA.c1Id=C1.id
inner join Country C2 on CA.c2Id=C2.id
where CA.id=@id
end

GO

Create proc offerAggrement(@myCountryId int, @otherCountryId int, @aggrementId int, @endDate datetime)
as
begin
SET NOCOUNT ON;
insert into dbo.AggrementOffers(c1Id, c2Id, aggrementId, offerEndDate) values(@myCountryId, @otherCountryId, @aggrementId, @endDate)
end

GO

Create proc answerAggrement(@offerId int, @answer int)
as
begin
SET NOCOUNT ON;
if @answer=1
	begin
	insert into CountryAggrements (c1Id, c2Id, aggrementId, endDate) select AO.c1Id, AO.c2Id, AO.aggrementId, AO.offerEndDate from AggrementOffers AO where AO.id=@offerId
	delete from AggrementOffers where id=@offerId
	end
end

GO

Create proc cancelAggrement(@id int)
as
begin
SET NOCOUNT ON;
delete from CountryAggrements where id=@id
end

GO

Create proc getMyArmyCorpsWithMissions(@myCountryId int)
as
begin
SET NOCOUNT ON;
select AC.id, AC.corpType, AC.numOfUnits, SourceProvince.pname SProvince, AC.mission, AC.startTime, AC.duration, TargetProvince.pname DProvince
from ArmyCorps AC
inner join Province SourceProvince on AC.provinceID=SourceProvince.id
inner join Province TargetProvince on AC.targetProvinceID=TargetProvince.id
where AC.countryID=@myCountryId
end

GO

Create proc giveMissionToCorp(@corpId int, @mission nvarchar(40), @targetProvinceID int, @duration int)
as
begin
SET NOCOUNT ON;
update ArmyCorps set mission=@mission, targetProvinceID=@targetProvinceID, startTime=GETDATE(), duration=@duration
end

GO

Create proc cancelMissionOfCorp(@corpId int)
as
begin
SET NOCOUNT ON;
update ArmyCorps set mission='',targetProvinceID=0
end

GO

Create proc getLaws(@cId int)
as
begin
SET NOCOUNT ON;
select CL.cId, CL.lId, CL.startDate, L.title, L.content
from CountryLaws CL
inner join Laws L on CL.lId=L.id
where CL.cId=@cId
end

GO

Create proc getLaw(@cId int, @lId int)
as
begin
SET NOCOUNT ON;
select CL.cId, CL.lId, CL.startDate, L.title, L.content
from CountryLaws CL
inner join Laws L on CL.lId=L.id
where CL.cId=@cId and CL.lId=@lId
end

GO

Create proc getLawTypes
as
begin
SET NOCOUNT ON;
select * from dbo.Laws
end

GO

Create proc setLaw(@cId int, @lId int)
as
begin
SET NOCOUNT ON;
insert into CountryLaws (cId, lId, startDate) values(@cId, @lId, GETDATE())
end

GO

Create proc cancelLaw(@cId int, @lId int)
as
begin
SET NOCOUNT ON;
delete from CountryLaws where cId=@cId and lId=@lId
end

GO

Create proc setProvincesBudgets(@countryId int, @budget int)
as
begin
SET NOCOUNT ON;
update Province set budget=@budget where countryID=@countryId
end

GO

Create proc setProvinceBudget(@provinceId int, @budget int)
as
begin
SET NOCOUNT ON;
update Province set budget=@budget where id=@provinceId
end

GO

Create proc getTaxRates(@countryId int)
as
begin
SET NOCOUNT ON;
select taxRate from Province where countryID=@countryId
end

GO

Create proc getTaxRate(@provinceId int)
as
begin
SET NOCOUNT ON;
select taxRate from Province where id=@provinceId
end

GO

Create proc setTaxRate(@provinceId int, @taxRate int)
as
begin
SET NOCOUNT ON;
update Province set taxRate=@taxRate where id=@provinceId
end

GO


/*Will be updated, for now, it takes only other countries*/
Create proc getCountries(@myCountryId int)
as
begin
SET NOCOUNT ON;
select id, cName, remaining, color from dbo.Country where id!=@myCountryId
end

GO

Create proc getAllProvinces
as
begin
SET NOCOUNT ON;
select * from Province
end

GO

/*Will be updated : kaynaklar, ürünler ve yatırımları da dahil et*/
Create proc getProvincesOf(@countryId int)
as
begin
SET NOCOUNT ON;
select * from Province where countryID=@countryId
end

GO

Create proc getAllArmyCorpsWithMissions
as
begin
SET NOCOUNT ON;
select *
from ArmyCorps AC
inner join Province SourceProvince on AC.provinceID=SourceProvince.id
inner join Province TargetProvince on AC.targetProvinceID=TargetProvince.id
end

GO

Create proc getProvinceResourcesOf(@provinceId int)
as
begin
SET NOCOUNT ON;
select NR.name, NR.type, PR.remaing 
from ProvinceResources PR
inner join NaturalResources NR on PR.resourceID=NR.id
where PR.provinceID=@provinceId
end

GO

Create proc getProvinceProductsOf(@provinceId int)
as
begin
SET NOCOUNT ON;
select P.name, PP.remaing 
from ProvinceProducts PP
inner join Products P on PP.productID=P.id
where PP.provinceID=@provinceId
end

GO

Create proc getProvinceInvestmentsOf(@provinceId int)
as
begin
SET NOCOUNT ON;
select I.type, I.price, PI.degree
from ProvinceInvestments PI
inner join Investments I on PI.investmentID=I.id
where PI.provinceID=@provinceId
end

GO

