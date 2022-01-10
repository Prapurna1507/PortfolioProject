select * from [Portfolio Project]..CovidDeaths
order by 3,4

--
select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project]..CovidDeaths
order by 1,2

--Looking for Total Cases vs Total Deaths
--Likelihood of dying if you contract Covid in your country
select location,population,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio Project]..CovidDeaths
where location = 'India'
order by 1,2

--Looking at Total Popultaion vs Total Cases in your country
--Likelihood of contracting Corona Virus in your country
select location,date,population,total_cases, (total_cases/population)*100 as Covid_Percentage
from [Portfolio Project]..CovidDeaths
where location = 'India'
order by 1,2

--Countries with HIGHEST infection rate
select location,population,max(total_cases) as TotalCases, max((total_cases/population)*100) as InfectedPercentage
from [Portfolio Project]..CovidDeaths
group by location,population
order by 4 desc

--Showing countries with Highest Death Count per Population
select location,max(total_deaths) as Total_Death_Count
from [Portfolio Project]..CovidDeaths
where continent is not null 
group by location,population
having max(total_deaths) >0
order by 2 desc

--Let us break per continent
select location,max(cast(total_deaths as int)) as Total_Death_Count
from [Portfolio Project]..CovidDeaths
where continent is null 
group by location
order by 2 desc

--GLOBAL NUMBERS
--Number of cases registered on each day & Number of deaths each day
select date,sum(new_cases)as Total_Cases, SUM(cast(new_deaths as float)) as Total_Deaths,
(SUM(cast(new_deaths as float))/sum(new_cases))*100 as death_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null 
group by date
order by date desc

--Total Cases vs Total Deaths vs Death Percentage till Date
select sum(new_cases)as Total_Cases, SUM(cast(new_deaths as float)) as Total_Deaths,
(SUM(cast(new_deaths as float))/sum(new_cases))*100 as death_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null 
--group by date
--order by date desc

--Joining CovidDeaths and CovidVaccinations table
select CD.continent,CD.location,CD.date, CD.population, CV.new_vaccinations
from [Portfolio Project]..CovidDeaths as CD
join [Portfolio Project]..CovidVaccinations as CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null
group by CD.continent
order by CD.continent,CD.location,CD.date

--Looking at Total Population vs Toal Vaccinated People
select CD.continent,CD.location,CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(bigint,new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.LOCATION,CD.DATE) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as CD
join [Portfolio Project]..CovidVaccinations as CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null 
order by CD.location,CD.date

--Now, I want to see the % of people vaccintaed by the day in each country
--Use CTE / Temp Table

--Let us use CTE
--if exists
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(select CD.continent,CD.location,CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(bigint,new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.LOCATION,CD.DATE) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as CD
join [Portfolio Project]..CovidVaccinations as CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null 
)

select *, (RollingPeopleVaccinated/population)*100 as Percentage_People_Vaccinated
from PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
select CD.continent,CD.location,CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(bigint,new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.LOCATION,CD.DATE) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as CD
join [Portfolio Project]..CovidVaccinations as CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null 

select * , RollingPeopleVaccinated/population*100
from #PercentPeopleVaccinated 

--Creating View for storing data for visulaization later
CREATE VIEW PercentPeopleVaccinated1
AS
select CD.continent,CD.location,CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(bigint,new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.LOCATION,CD.DATE) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as CD
join [Portfolio Project]..CovidVaccinations as CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null 

select * from PercentPeopleVaccinated1





