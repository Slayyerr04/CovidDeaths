
--Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


SELECT * 
FROM CovidDeaths
Where continent is not null 
ORDER BY 3,4;


-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
Where continent is not null 
ORDER BY 1,2;

--Looking at the Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths as float) / CAST(total_cases as float))*100 AS Death_Percentage
FROM CovidDeaths
Where location like '%Nigeria%'
and continent is not null 
ORDER BY 1,2;



--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
--WHERE Location LIKE '%Nigeria%'
ORDER BY 1,2;


--Looking at the Countries with Highest Infection rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidDeaths
--WHERE Location LIKE '%Nigeria%'
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC

--Showing Countries with Highest Death Count Per Population
SELECT Location, MAX(total_deaths) AS HighestDeathCount
FROM CovidDeaths
--WHERE Location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY 2 DESC

--Showing Continent with Highest Death Count Per Population
SELECT Location, MAX(total_deaths) AS HighestDeathCount
FROM CovidDeaths
--WHERE Location LIKE '%Nigeria%'
WHERE continent IS NULL
GROUP BY Location
ORDER BY 2 DESC

--Global Cases
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) AS total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NUL
--WHERE Location LIKE '%Nigeria%'
ORDER BY 1,2

--Looked at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

Population vs Vaccination

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations)
    OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac
ORDER BY 2,3


--TEMP TABLES
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
     SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations)
    OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to Store data for later visualizations

Create view PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations)
OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


