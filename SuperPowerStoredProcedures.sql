/* ACCESSING DATA BY STORED PROCEDURES */

/*
GO - Deallocates variables
*/

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

exec delProcedures

GO

/*USER LOGIN*/
Create proc userLogin (@email nvarchar(40), @password nvarchar(40)) 
as
begin
SET NOCOUNT ON;
select id as ID from dbo.Users where email=@email and pass=@password;
end

GO

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

/*MY COUNTRY DETAILS*/
Create proc myCountriesDetails(@email nvarchar(40), @password nvarchar(40))
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

/*OTHER COUNTRIES DETAILS*/
Create proc otherCountriesDetails(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	select C.id id, C.cname cname, sum(P.population) totalpopulation, avg(P.taxRate) avgTax, count(P.id) numOfProvinces, C.remaining remaining
	from Country C 
	inner join Province P on C.id = P.countryID
	where C.userID not in (select id from Users where email=@email and pass=@password)
	group by C.id, C.cname, C.remaining
	end
end


GO

/*MY PROVINCES DETAILS*/
Create proc myProvincesDetails(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	SELECT  P.id, P.pname, P.governorName, P.population, P.taxRate
	FROM dbo.Country C
	inner join Province P on C.id = P.countryID
	where C.userID in (select id from Users where email=@email and pass=@password)
	GROUP BY P.id, P.pname, P.governorName, P.population, P.taxRate
	end
end

GO

/*OTHER PROVINCES DETAILS*/
Create proc otherProvincesDetails(@email nvarchar(40), @password nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	SELECT  P.id, P.pname, P.governorName, P.population, P.taxRate
	FROM dbo.Country C
	inner join Province P on C.id = P.countryID
	where C.userID not in (select id from Users where email=@email and pass=@password)
	GROUP BY P.id, P.pname, P.governorName, P.population, P.taxRate
	end
end


GO

/*ARMY INFORMATIONS*/
Create proc armyInformations(@email nvarchar(40), @password nvarchar(40), @countryId int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	SELECT  A.id, A.budget,
		stuff(
                (
                    select  ',' + cast(A.corpType as varchar(40)) + ':' + cast(A.numOfSoldiers as varchar(40)) + ':' + cast(M.mission as varchar(40))
                    from    dbo.ArmyCorps A
					left outer join ArmyCorpsMissions M
					on A.id=M.corpId
                    where A.armyID in (select K.id from Army K where K.countryID=@countryId)
                    order by A.id
                    for xml path('')
                ),1,1,'') Corps
	FROM dbo.Army A
	GROUP BY A.id, A.budget
	end
end

GO

/*GIVE MISSION TO CORPS*/
Create proc giveMissionToCorps(@email nvarchar(40), @password nvarchar(40), @corpId int, @targetProvinceId int, @mission nvarchar(40))
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	insert into ArmyCorpsMissions values(@corpId, @targetProvinceId, @mission, current_timestamp, 60)
	return(1)
	end
else
	begin
	return(-1)
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

/*AGGREMENTS INFORMATIONS*/
Create proc aggrementsInformations(@email nvarchar(40), @password nvarchar(40), @countryId int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	select * from CountryAggrements where c1id=@countryId or c2id=@countryId
	end
else
	begin
	return(-1)
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

/*OFFER AGGREMENT*/
Create proc offerAggrement(@email nvarchar(40), @password nvarchar(40), @c1Id int, @c2Id int, @aggrementId int, @endDate DateTime)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	insert into AggrementOffers values(@c1Id, @c2Id, @aggrementId, @endDate)
	return(1)
	end
else
	begin
	return(-1)
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

/*LAWS INFORMATIONS*/
Create proc lawsInformations(@email nvarchar(40), @password nvarchar(40), @countryId int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	select * from CountryLaws where cId=@countryId
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

/*MAKE LAW*/
Create proc makeLaw(@email nvarchar(40), @password nvarchar(40), @countryId int, @lawId int, @endDate DateTime)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	insert into CountryLaws values(@countryId, @lawId, current_timestamp, @endDate)
	return(1)
	end
else
	return(-1)
end

GO

/*BUDGET INFORMATIONS*/
Create proc budgetInformations(@email nvarchar(40), @password nvarchar(40), @countryId int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	select P.id, B.amount, B.remaining, B.year from Province P
	inner join ProvinceBudget B
	on P.id=B.provinceId
	where P.countryId=@countryId
	end
end

GO

/*SET BUDGET FOR PROVINCE*/
Create proc setBudgetForProvince(@email nvarchar(40), @password nvarchar(40), @provinceId int, @year nvarchar(5), @amount int)
as
begin
SET NOCOUNT ON;
if exists (select * from users where email=@email and pass=@password)
	begin
	insert into ProvinceBudget values(@amount, @amount, @year, @provinceId)
	return(1)
	end
else
	begin
	return(-1)
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

/*****************************************/
