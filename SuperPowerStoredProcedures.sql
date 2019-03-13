/* ACCESSING DATA BY STORED PROCEDURES */

use superpower

GO 

Create proc delProcedures
as
begin
declare @procName varchar(500)
declare cur cursor 

for select [name] from sys.objects where type = 'p'
open cur
fetch next from cur into @procName
while @@fetch_status = 0
begin
    exec('drop procedure [' + @procName + ']')
    fetch next from cur into @procName
end
close cur
deallocate cur
end

GO

exec delProcedures

GO

/* SEALED */
Create proc payTaxes (@taxConstant int)
as
begin

/* Give taxes to Countries */
update C set C.remaining= C.remaining + (N.totalTax/@taxConstant)
from dbo.Country as C
inner join (
/* sum all province's taxes in one country */
select M.id, M.cname, sum(provinceTax) as totalTax from
/*find every province's tax amount */
(select C.id, C.cname, (P.population / 1000) * P.taxRate as provinceTax
from Province P
inner join Country C on P.countryID=C.id) as M
group by M.id, M.cname) as N on C.id = N.id

select 1 as Result
end


GO

/* SEALED */
Create proc returnResourceValues
as
begin
select R.provinceID as ProvinceID, R.resourceID as ResourceID, R.amount as Amount, N.type as Type
from dbo.ProvinceResources R
inner join NaturalResources N on R.resourceID = N.id
end

GO

/* SEALED */
/*USER LOGIN*/
Create proc userLogin (@email nvarchar(40), @password nvarchar(40)) 
as
begin
SET NOCOUNT ON;
select id as ID from dbo.Country where email=@email and pass=@password;
end

GO

/* SEALED */
/*USER REGISTER*/
Create proc userRegister (@uname nvarchar(40), @cname nvarchar(40), @email nvarchar(40), @password nvarchar(40), @color nvarchar(8))
as
begin
SET NOCOUNT ON;
if not exists (select * from dbo.Country where email=@email)
	begin
	if not exists (select * from dbo.Country where cname=@cname)
		begin
		Declare @uId int;
		Declare @cId int;
		insert into dbo.Country OUTPUT inserted.id values(@uname, @password, @email, @cname, 10000, @color)
		SET @cId = @@IDENTITY
		update TOP (1) dbo.Province set countryID=@cId where countryID=1
		select 1 as Result
		end
	else
		select 0 as Result
	end
else
	select -1 as Result
end

GO

/* SEALED */
/*ALL COUNTRY DETAILS*/
Create proc countryDetails(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	select C.id, C.uname, C.cname, C.remaining, C.color , 'y' as isMyCountry
	from Country C 
	where email=@email and pass=@password

	union

	select C.id, 'NULL' as uname, C.cname, 0 as remaining, C.color, 'n' as isMyCountry
	from Country C
	where not (email=@email and pass=@password)
	end
end

GO
									  
/* SEALED */
/*ALL PROVINCES DETAILS*/
Create proc provincesDetails(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	SELECT  P.id, P.pname, P.governorName, P.population, P.taxRate, P.budget, P.countryID
	FROM dbo.Province P
	where P.countryID in (select id from Country where email=@email and pass=@password)

	union
	
	SELECT  P.id, P.pname, P.governorName, P.population, 0 as taxRate, 0 as budget, P.countryID
	FROM dbo.Province P
	where P.countryID not in (select id from Country where email=@email and pass=@password)
	end
end

GO

/*SEALED*/
/*ARMY INFORMATIONS*/
Create proc armyInformations(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	SELECT A.id, A.corpType, A.numOfUnits, A.countryID, A.provinceID, A.targetProvinceID, A.mission, A.startTime, A.duration
	FROM ArmyCorps A
	where A.countryID in (select id from Country C where email=@email and pass=@password)

	union
	
	SELECT A.id, A.corpType, 0 as numOfUnits, A.countryID, A.provinceID, A.targetProvinceID, A.mission, A.startTime, A.duration
	FROM ArmyCorps A
	where A.countryID not in (select id from Country C where email=@email and pass=@password)
	end
end

GO

/*SEALED*/
/*GIVE MISSION TO CORPS*/
Create proc giveMissionToCorps(@email nvarchar(40), @password nvarchar(40), @corpID int, @targetProvinceID int, @mission nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin	
	update ArmyCorps set targetProvinceID=@targetProvinceID,  mission=@mission, startTime=current_timestamp, duration=60 where id=@corpID
	select 1 as Result
	end
end

GO

/*ABORT MISSION OF CORP*/
Create proc abortMissionOfCorp(@email nvarchar(40), @password nvarchar(40), @corpId int, @missionId int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	if exists (select * from ArmyCorpsMissions where corpId=@corpId and id=@missionId and mission!='return')
		begin
		delete from ArmyCorpsMissions where id=@missionId
		return(1)
		end
	else
		begin
		return(-1)
		end
	end
else
	begin
	return(-2)
	end
end

GO

/*SEALED*/
/*AGGREMENTS INFORMATIONS*/
Create proc aggrementsInformations(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	select (select Top(1) cname from Country where id=C.c1id) as cname1, (select Top(1) cname from Country where id=C.c2id) as cname2, A.aggrementType, C.endDate 
	from CountryAggrements C
	inner join Aggrements A on C.aggrementId=A.id
	where c1id in (select id from Country where email=@email and pass=@password) or c2id in (select id from Country where email=@email and pass=@password)
	end
end

GO

/*DECLINE AGGREMENT*/
Create proc declineAggrement(@email nvarchar(40), @password nvarchar(40), @c1Id int, @c2Id int, @aggrementId int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	delete from CountryAggrements where c1id=@c1Id and c2id=@c2Id and aggrementId=@aggrementId
	return(1)
	end
else
	begin
	return(-1)
	end
end

GO

/*SEALED*/
/*OFFER AGGREMENT*/
Create proc offerAggrement(@email nvarchar(40), @password nvarchar(40), @c1ID nvarchar(40), @c2ID nvarchar(40), @aggrementID nvarchar(40), @endDate DateTime)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	insert into AggrementOffers values(@c1ID, @c2ID, @aggrementID, @endDate)
	select 1 as Result
	end
end

GO

/*ANSWER AGGREMENT OFFER*/
Create proc answerAggrementOffer(@email nvarchar(40), @password nvarchar(40), @c1Id int, @c2Id int, @aggrementId int, @endDate DateTime, @answer int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	delete from AggrementOffers where c1Id=@c1Id and c2Id=@c2Id and aggrementId=@aggrementId
	if @answer=1
		begin
		insert into CountryAggrements values(@c1Id, @c2Id, @aggrementId, @endDate)
		end
	return(1)
	end
else
	begin
	return(-1)
	end
end

GO

/*AGGREMENT OFFER INFORMATIONS*/
Create proc aggrementOfferInformations(@email nvarchar(40), @password nvarchar(40), @countryId int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	select * from AggrementOffers where c1Id=@countryId or c2Id=@countryId
	end
end

GO

/*REGULATIONS INFORMATIONS*/
Create proc regulationsInformations(@email nvarchar(40), @password nvarchar(40), @countryId int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	select * from CountryRegulations where cId=@countryId
	end
end

GO

/*SEALED*/
/*LAWS INFORMATIONS*/
Create proc lawsInformations(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	select W.title, W.content, L.startDate, L.endDate
	from CountryLaws L
	inner join Laws W on L.lId=W.id
	where L.cId in (select id from Country C where email=@email and pass=@password)
	end
end

GO

/*DECLINE REGULATION*/
Create proc declineRegulation(@email nvarchar(40), @password nvarchar(40), @countryId int, @regulationId int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	delete from CountryRegulations where cId=@countryId and rId=@regulationId
	return(1)
	end
else
	begin
	return(-1)
	end
end

GO

/*DECLINE LAW*/
Create proc declineLaw(@email nvarchar(40), @password nvarchar(40), @countryId int, @lawId int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	delete from CountryLaws where cId=@countryId and lId=@lawId
	return(1)
	end
else
	begin
	return(-1)
	end
end

GO

/*MAKE REGULATION*/
Create proc makeRegulation(@email nvarchar(40), @password nvarchar(40), @countryId int, @regulationId int, @endDate DateTime)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	insert into CountryRegulations values(@countryId, @regulationId, current_timestamp, @endDate)
	return(1)
	end
else
	begin
	return(-1)
	end
end

GO

/*SEALED*/
/*MAKE LAW*/
Create proc makeLaw(@email nvarchar(40), @password nvarchar(40), @cID int, @lawID int, @startDate DateTime)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	insert into CountryLaws values(@cID, @lawID, current_timestamp, @startDate)
	select 1 as Result
	end
end

GO

/*SEALED*/
/*SET BUDGET FOR PROVINCE*/
Create proc setBudgetForProvince(@email nvarchar(40), @password nvarchar(40), @provinceID nvarchar(40), @amount int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	update Province set budget=@amount where id=@provinceID
	select 1 as Result
	end
end

GO

/*SET BUDGET FOR ARMY*/
Create proc setBudgetForArmy(@email nvarchar(40), @password nvarchar(40), @amount int, @countryId int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	update Army set budget=@amount where countryID=@countryId
	return(1)
	end
else
	begin
	return(-1)
	end
end

GO

/*SET TAXRATE FOR PROVINCE*/
Create proc setTaxRateForProvince(@email nvarchar(40), @password nvarchar(40), @provinceId int, @taxRate int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	update Province set taxRate=@taxRate where id=@provinceId
	return(1)
	end
else
	begin
	return(-1)
	end
end

GO

/*MAKE INVESTMENT*/
Create proc makeInvestment(@email nvarchar(40), @password nvarchar(40), @provinceId int, @investmentId int, @degree int)
as
begin
SET NOCOUNT ON;
if exists (select * from dbo.Country where email=@email and pass=@password)
	begin
	insert into ProvinceInvestments values(@provinceId, @investmentId, @degree)
	return(1)
	end
else
	begin
	return(-1)
	end
end



GO

/*Info About Current Data*/
select * from Country
select * from Province
select * from AggrementOffers
select * from ArmyCorps
select * from ArmyCorpsMissions
select * from CountryLaws
