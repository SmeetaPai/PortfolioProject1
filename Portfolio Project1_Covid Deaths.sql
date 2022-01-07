Select *
From PortfolioProject1.dbo.CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--Order by 3,4

--Selecting data that we are going to be using
Select Location,date,total_cases,New_cases,total_deaths,population
From PortfolioProject1..CovidDeaths
order by 1,2

-- Total Cases Vs Total Deaths
--Shows likelihood of dying if you get covid in USA
Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where Location like '%states%'
order by 1,2

--Total Cases Vs Total Population
-- Shows what percentage of people got covid
Select Location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
where Location like '%states%'
order by 1,2

--looking at countries with highest infection rate Vs Population
Select Location,population,Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count
Select Location,population,Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
where continent is not Null
Group by Location, population
order by TotalDeathCount desc

--Lets break things down by continent

--showing continents with highest death count per population
Select location,Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
where continent is NULL
and location NOT IN ('Upper middle income','High income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date,sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,(sum(new_cases)/sum(cast(new_deaths as int)))*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not NULL
group by date
order by 1,2

Select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not NULL
order by 1,2

--Total Population Vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is Not Null
	order by 2,3


--Use CTE
With PopVsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is Not Null
)
Select * ,(RollingPeopleVaccinated/population)*100
from PopVsVac

--TEMP Table

Drop Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated

From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is Not Null
Select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is Not Null

  Select * from PercentPopulationVaccinated

  --Max Deaths
Select Sum(Cast(new_cases as int)),Max(Cast(total_cases as int))
from PortfolioProject1..CovidDeaths
where location='World'