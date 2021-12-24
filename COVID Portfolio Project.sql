Select *
From PortFolio.dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortFolio.dbo.CovidVaccinations
--order by 3,4

--- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortFolio.dbo.CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths in Thailand
-- Shows likelihood of dying if you contract covid in Thailand

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortFolio.dbo.CovidDeaths
Where location like 'Thailand' AND continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
From PortFolio.dbo.CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortFolio.dbo.CovidDeaths
Where continent is not null
Group by Location, population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortFolio.dbo.CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount DESC

-- Let's break things down by continent
-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortFolio.dbo.CovidDeaths
Where continent is  not null
Group by continent
order by TotalDeathCount DESC


-- Overall Global Numbers

Select SUM(new_cases) as GlobalCases, SUM(CAST(new_deaths as int)) as GlobalDeath, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PortFolio.dbo.CovidDeaths
Where continent is not null
order by 1,2

-- Global Numbers by date

Select date, SUM(new_cases) as GlobalCases, SUM(CAST(new_deaths as int)) as GlobalDeath, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PortFolio.dbo.CovidDeaths
Where continent is not null
Group by date
order by 1,2


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From PortFolio.dbo.CovidDeaths dea
Join PortFolio.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

--- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From PortFolio.dbo.CovidDeaths dea
Join PortFolio.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From PortFolio.dbo.CovidDeaths dea
Join PortFolio.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated