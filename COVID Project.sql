SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY location, date


--SELECT *
--FROM CovidVaccinations
--ORDER BY location, date

--Select data for this project

EXEC sp_help 'dbo.CovidDeaths';
ALTER TABLE dbo.CovidDeaths
ALTER COLUMN new_deaths bigint

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY location, date


--Investigating Total Cases vis-a-vis Total Deaths

SELECT location, date, total_cases, total_deaths, [total_deaths]/[total_cases]*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY location, date

--Investigating Total Cases vis-a-vis Population: Shows the percentage of the population that contracted Covid

SELECT location, date, total_cases, population, [total_cases]/[population]*100 AS PercentageOfPopulationInfected
FROM CovidDeaths
--WHERE location like '%Nigeria%'
ORDER BY location, date


--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX([total_cases]/[population])*100 AS PercentageOfPopulationInfected
FROM CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected desc

--Countries with the Highest Death Rate by Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with the Highest Death Rate by Population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths/NULLIF(new_cases,0))*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Joning the Vac table with the deaths tables; Investigating Total Population VS Total Vaccination
--Using CTE

With PopVSVac (continent, location, date, population, new_vaccinations, VACRollingCount)
as
(
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CAST(CovidVaccinations.new_vaccinations AS bigint)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS VACRollingCount
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location
AND CovidDeaths.date = CovidDeaths.date
WHERE CovidDeaths.continent is not null
--ORDER BY continent, location, date
)
SELECT *, (VACRollingCount/population)*100
FROM PopVSVac


Create VIEW PercentageOfPOPVac AS 
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CAST(CovidVaccinations.new_vaccinations AS bigint)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS VACRollingCount
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location
AND CovidDeaths.date = CovidDeaths.date
WHERE CovidDeaths.continent is not null
--ORDER BY continent, location, date


SELECT *
FROM PercentageOfPOPVac




