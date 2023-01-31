/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
-- The data used in these queries is from 2020-02-24 till 2021-04-30 


SELECT *
FROM dbo.CovidDeaths$ 
WHERE continent is not null;

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths$
WHERE continent is not null 
ORDER BY 1,2;

-- Total Cases vs. Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths$
WHERE continent is not null
  --and location like 'Canada'
ORDER BY 1,2;

-- Total Cases vs. Population
-- Shows what percentage of population infected with Covid

SELECT continent, location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM dbo.CovidDeaths$
--WHERE location like 'United States'
ORDER BY 1,2;

-- Continents with Highest Infection Rate compared to Population

SELECT continent, location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths$
--WHERE location like 'United States'
GROUP BY continent, location, population
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Infection Rate compared to Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM dbo.CovidDeaths$
--WHERE location like 'United States'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Continents with Highest Death Count per Population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM dbo.CovidDeaths$
--WHERE location like 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths$ 
WHERE continent is not null
ORDER BY 1,2;

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
FROM dbo.CovidDeaths$ as dea 
JOIN dbo.CovidVaccinations$ as vac 
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac as 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
FROM dbo.CovidDeaths$ as dea 
JOIN dbo.CovidVaccinations$ as vac 
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (Rolling_People_Vaccinated/population)*100 as Percent_of_People_Vaccinated
FROM PopvsVac;

-- Cretaing View to store data for later visualizations

CREATE VIEW PopvsVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
FROM dbo.CovidDeaths$ as dea 
JOIN dbo.CovidVaccinations$ as vac 
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3;

CREATE VIEW TotalCasesVsTotalDeaths as
SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths$
WHERE continent is not null
  --and location like 'Canada'

CREATE VIEW TotalCasesVsPopulation as
SELECT continent, location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM dbo.CovidDeaths$
--WHERE location like 'United States'

CREATE VIEW HighestInfectionRateComparedToPopulation as
SELECT continent, location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths$
--WHERE location like 'United States'
GROUP BY continent, location, population

CREATE VIEW CountriesHighestDeathCountPerPopulation as
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM dbo.CovidDeaths$
--WHERE location like 'United States'
WHERE continent is not null
GROUP BY location

CREATE VIEW ContinentsHighestDeathCountPerPopulation as
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM dbo.CovidDeaths$
--WHERE location like 'United States'
WHERE continent is not null
GROUP BY continent

CREATE VIEW WorldTotalsBasedOnDate as
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date