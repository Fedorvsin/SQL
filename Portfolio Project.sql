/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- Looking at data

SELECT * FROM PortfolioProject..CovidDeaths$
ORDER BY LOCATION

SELECT * FROM PortfolioProject..CovidVaccinations$
ORDER BY LOCATION

--Select data that we are going to use
 

SELECT location,continent, date, total_cases, new_cases, total_deaths, new_deaths 
FROM PortfolioProject..CovidDeaths$
where continent is not null
ORDER BY LOCATION, date

--Looking at Total Cases VS Total Deaths
--Shows a chance of death you were infected

SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
--WHERE location like '%Russia%'
ORDER BY LOCATION, date

--Looking at GDP and Total Of Vaccinated People

--SELECT location, population, max(gdp_per_capita) as GDPInThisCountry, max(total_vaccinations) as AllVaccinations
--FROM PortfolioProject..CovidVaccinations$
--where continent is not null and gdp_per_capita is not null
--group by location, population
--ORDER BY GDPInThisCountry desc


--Looking at Total Cases VS Population
-- Shows percentage of population that got a covid

SELECT location, date, total_cases, new_cases, population, (total_cases/population)*100 as PercentageofInfection
FROM PortfolioProject..CovidDeaths$
where continent is not null
--WHERE location like '%Russia%'
ORDER BY LOCATION, date

--Looking at Highest infection rate compared to each country

SELECT location, population, SUM(cast(new_cases as int)) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentageOfInfection
FROM PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
ORDER BY PercentageOfInfection desc


--Countries With Highest Death Count

SELECT location, population, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
ORDER BY HighestDeathCount 

--Look at this stats from a view of continent 

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
group by continent
ORDER BY HighestDeathCount desc

--Global numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 as DeathDepcentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 1

--Looking at Total Population vs Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (Partition by cd.location
    Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as cd
Join PortfolioProject..CovidVaccinations$ as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

With PopulationVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (Partition by cd.location
    Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as cd
Join PortfolioProject..CovidVaccinations$ as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 from PopulationVsVac

--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (Partition by cd.location
    Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as cd
Join PortfolioProject..CovidVaccinations$ as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

Select * from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (Partition by cd.location
    Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as cd
Join PortfolioProject..CovidVaccinations$ as cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3