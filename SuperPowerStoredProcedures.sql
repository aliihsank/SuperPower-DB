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
select P.countryID as CountryID, P.population as Population, P.id as ProvinceID, R.resourceID as ResourceID, R.amount as Amount, N.type as Type
from dbo.ProvinceResources R
inner join NaturalResources N on R.resourceID = N.id
inner join Province P on R.provinceID=P.id
end

GO

/* SEALED */
/*USER LOGIN*/
Create proc userLogin (@email nvarchar(40), @password nvarchar(40)) 
as
begin
SET NOCOUNT ON;
select id as ID from dbo.Users where email=@email and pass=@password;
end

GO

/* SEALED */
/*USER REGISTER*/
Create proc userRegister (@uname nvarchar(40), @cname nvarchar(40), @email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if not exists (select * from dbo.users where email=@email)
	begin
	if not exists (select * from dbo.country where cname=@cname)
		begin
		Declare @uId int;
		Declare @cId int;
		insert into dbo.Users OUTPUT inserted.id values(@uname, @password, @email)
		SET @uId = @@IDENTITY
		insert into dbo.Country values(@cname, 10000, @uId)
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
/*MY COUNTRY DETAILS*/
Create proc myCountryDetails(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	select C.id id, C.cname cname, sum(P.population) totalpopulation, avg(P.taxRate) avgTax, count(P.id) numOfProvinces, C.remaining remaining
	from Country C 
	inner join Province P on C.id = P.countryID
	where C.userID in (select id from Users where email=@email and pass=@password)
	group by C.id, C.cname, C.remaining
	end
end

GO
								     
/* SEALED */
/*OTHER COUNTRIES DETAILS*/
Create proc otherCountriesDetails(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	select C.id id, C.cname cname, sum(P.population) totalpopulation, 0 as avgTax, count(P.id) numOfProvinces, 0 as remaining
	from Country C
	inner join Province P on C.id = P.countryID
	where C.userID not in (select id from Users where email=@email and pass=@password)
	group by C.id, C.cname, C.remaining
	end
end


GO
									  
/* SEALED */
/*MY PROVINCES DETAILS*/
Create proc myProvincesDetails(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	SELECT  P.id as id, P.pname as pname, P.governorName as governorName, P.population as population, P.taxRate as taxRate, P.countryID as countryID
	FROM dbo.Country C
	inner join Province P on C.id = P.countryID
	where C.userID in (select id from Users where email=@email and pass=@password)
	GROUP BY P.id, P.pname, P.governorName, P.population, P.taxRate, P.countryID
	end
end

GO
								       
/* SEALED */
/*OTHER PROVINCES DETAILS*/
Create proc otherProvincesDetails(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	SELECT  P.id as id, P.pname as pname, P.governorName as governorName, P.population as population, 0 as taxRate, P.countryID
	FROM dbo.Country C
	inner join Province P on C.id = P.countryID
	where C.userID not in (select id from Users where email=@email and pass=@password)
	GROUP BY P.id, P.pname, P.governorName, P.population, P.taxRate, P.countryID
	end
end


GO

/*SEALED*/
/*ARMY INFORMATIONS*/
Create proc armyInformations(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	SELECT C.corpType, C.numOfSoldiers, M.mission, P.pname
	FROM ArmyCorps C
	full outer join ArmyCorpsMissions M on C.id = M.corpId
	inner join Province P on C.provinceID=P.id
	where C.armyID in (select A.id from Army A where A.countryID in (select Co.id from Country Co inner join Users Us on Co.userID=Us.id where Us.email=@email and Us.pass=@password))
	end
end


GO

/*SEALED*/
/*GIVE MISSION TO CORPS*/
Create proc giveMissionToCorps(@email nvarchar(40), @password nvarchar(40), @corpType nvarchar(40), @targetProvinceName nvarchar(40), @mission nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin	
	insert into ArmyCorpsMissions values((select top(1) id from ArmyCorps C where C.corpType=@corpType), (select top(1) id from Province P where P.pname=@targetProvinceName) , @mission, current_timestamp, 60)
	select 1 as Result
	end
end

GO

/*ABOURT MISSION OF CORP*/
Create proc abortMissionOfCorp(@email nvarchar(40), @password nvarchar(40), @corpId int, @missionId int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
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
if exists (select * from users where email=@email and pass=@password)
	begin
	select (select Top(1) cname from Country where id=C.c1id) as cname1, (select Top(1) cname from Country where id=C.c2id) as cname2, A.aggrementType, C.endDate 
	from CountryAggrements C
	inner join Aggrements A on C.aggrementId=A.id
	where c1id in (select Co.id from Country Co inner join Users Us on Co.userID=Us.id where Us.email=@email and Us.pass=@password) or c2id in (select Co.id from Country Co inner join Users Us on Co.userID=Us.id where Us.uname=@email and Us.pass=@password)
	end
end

GO

/*DECLINE AGGREMENT*/
Create proc declineAggrement(@email nvarchar(40), @password nvarchar(40), @c1Id int, @c2Id int, @aggrementId int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
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
Create proc offerAggrement(@email nvarchar(40), @password nvarchar(40), @c1Name nvarchar(40), @c2Name nvarchar(40), @aggrementTitle nvarchar(40), @endDate DateTime)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	insert into AggrementOffers values((select top(1) id from Country C where C.cname=@c1Name), (select top(1) id from Country C where C.cname=@c2Name), (select id from Aggrements A where A.aggrementType=@aggrementTitle), @endDate)
	select 1 as Result
	end
end

GO

/*ANSWER AGGREMENT OFFER*/
Create proc answerAggrementOffer(@email nvarchar(40), @password nvarchar(40), @c1Id int, @c2Id int, @aggrementId int, @endDate DateTime, @answer int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
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
if exists (select * from users where email=@email and pass=@password)
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
if exists (select * from users where email=@email and pass=@password)
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
if exists (select * from users where email=@email and pass=@password)
	begin
	select W.title, W.content, L.startDate, L.endDate
	from CountryLaws L
	inner join Country C on L.cId=C.id
	inner join Laws W on L.lId=W.id
	where L.cId in (select Co.id from Country Co inner join Users Us on Co.userID=Us.id where Us.email=@email and Us.pass=@password)
	end
end

GO

/*DECLINE REGULATION*/
Create proc declineRegulation(@email nvarchar(40), @password nvarchar(40), @countryId int, @regulationId int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
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
if exists (select * from users where email=@email and pass=@password)
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
if exists (select * from users where email=@email and pass=@password)
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
Create proc makeLaw(@email nvarchar(40), @password nvarchar(40), @lawTitle nvarchar(40), @startDate DateTime)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	insert into CountryLaws values((select top (1) id from Country C where C.userID in (select top(1) id from Users U where U.email=@email and U.pass=@password)), (select top(1) id from Laws where title=@lawTitle), current_timestamp, @startDate)
	select 1 as Result
	end
end


GO

/*SEALED*/
/*BUDGET INFORMATIONS*/
Create proc budgetInformations(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	select P.pname, B.amount, B.year from Province P
	inner join ProvinceBudget B
	on P.id=B.provinceId
	where P.countryId in (select Co.id from Country Co inner join Users Us on Co.userID=Us.id where Us.email=@email and Us.pass=@password)
	end
end

GO

/*SEALED*/
/*SET BUDGET FOR PROVINCE*/
Create proc setBudgetForProvince(@email nvarchar(40), @password nvarchar(40), @provinceName nvarchar(40), @year nvarchar(5), @amount int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	insert into ProvinceBudget values(@amount, @year, (select top(1) id from Province where pname=@provinceName))
	select 1 as Result
	end
end

GO

/*SET BUDGET FOR ARMY*/
Create proc setBudgetForArmy(@email nvarchar(40), @password nvarchar(40), @amount int, @countryId int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
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
if exists (select * from users where email=@email and pass=@password)
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
if exists (select * from users where email=@email and pass=@password)
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
select * from Users
select * from Country
select * from AggrementOffers
select * from ArmyCorps
select * from ArmyCorpsMissions
select * from CountryLaws
select * from ProvinceBudget

