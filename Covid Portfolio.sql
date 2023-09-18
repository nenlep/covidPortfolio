Select *
FROM PortfolioProject..CovidDeaths

Select *
FROM PortfolioProject..CovidVaccinations

SELECT Location, date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 6

total cases v total deaths
SELECT Location, date,total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
order by 1,2

percentage of population with covid
SELECT Location, date,total_cases, Population, total_deaths, (CONVERT(float, total_deaths)/population)*100 as PopulationDeadPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
order by 1,2

countries with highest infection count
SELECT Location,Population, MAX(total_cases) as HighestInfectionCount,MAX(CONVERT(float, total_cases)/population)*100 
as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
group by population,location
order by PercentPopulationInfected DESC

countries with highest death count
SELECT Location,MAX(total_deaths) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
group by population,location
order by HighestDeathCount DESC

continent with highest death count
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
group by location
order by TotalDeathCount DESC

showing continent with highest death count
SELECT continent,MAX(cast(total_deaths as int)) as TotalContinentDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by continent
order by TotalContinentDeathCount DESC

percentage of world population dead
select sum(cast (total_cases as float)) as newCases, sum(cast (new_deaths as float)) as newDeaths, sum(cast (new_deaths as float)) / sum(cast (total_cases as float))*100 
as DeathPercentage 
from PortfolioProject..covidDeaths
where continent is not null
order by 1,2

total population v new vaccinations per day for Nigeria
select cd.continent, cd.location, cd.date, population, cv.new_vaccinations
from PortfolioProject..covidDeaths cd
join PortfolioProject..covidVaccinations cv
	on cd.location = cv.location and
	cd.date = cv.date
where cd.location like '%Nigeria%'
order by 1,2,3


rolling count of new vaccinations for each country
select cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
SUM(CONVERT(float,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location , cd.date) as RollingTotalVaccinated 
from PortfolioProject..covidDeaths cd
join PortfolioProject..covidVaccinations cv
	on cd.location = cv.location and
	cd.date = cv.date
where cd.continent is not null
order by 2,3

percentage of population with vaccinations
TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
SUM(CONVERT(float,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location , cd.date) 
as RollingPeopleVaccinated
From PortfolioProject..covidDeaths cd
join PortfolioProject..covidVaccinations cv
	on cd.location = cv.location and
	cd.date = cv.date
where cd.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
DROP VIEW PercentPopulationVaccinated;

creating view to store data for visualisation
create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
SUM(CONVERT(float,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location , cd.date) 
as RollingPeopleVaccinated
From PortfolioProject..covidDeaths cd
join PortfolioProject..covidVaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null



select *
from PercentPopulationVaccinated