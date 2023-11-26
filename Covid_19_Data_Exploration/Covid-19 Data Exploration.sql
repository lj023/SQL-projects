-- Covid 19 Data Exploration 

USE Covid;

SELECT *
  FROM coviddeaths
 WHERE continent <> ''
 ORDER BY 3,4; 

-- Select Data to Start With
SELECT Location, date, total_cases, new_cases, total_deaths, population
  FROM CovidDeaths
 WHERE continent <> ''
 ORDER BY 1, 2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in the US
SELECT Location, date, total_cases, total_deaths, 
	(total_deaths / total_cases) * 100 AS DeathPercentage
  FROM coviddeaths
 WHERE location LIKE '%states%' AND continent <> ''
 ORDER BY 1, 2;

-- Total Cases vs Population
-- Shows what percentage of the population is infected with COVID
SELECT Location, date, Population, total_cases, 
	(total_cases / population) * 100 AS PercentPopulationInfected
  FROM coviddeaths
 ORDER BY 1, 2;

-- Countries with Highest Infection Rate compared to Population
SELECT Location, Population, date, 
	MAX(CONVERT(total_cases, SIGNED)) AS HighestInfectionCount, 
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
  FROM coviddeaths
 GROUP BY Location, Population, date
 ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
  FROM coviddeaths
 WHERE continent <> ''
 GROUP BY Location
 ORDER BY TotalDeathCount DESC;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
SELECT continent, MAX(CONVERT(Total_deaths, SIGNED)) AS TotalDeathCount
  FROM CovidDeaths
 WHERE continent <> ''
 GROUP BY continent
 ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS
SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
  FROM coviddeaths
 WHERE continent <> ''
 ORDER BY 1, 2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine
SELECT d.continent, d.location, d.date, d.population,
    NULLIF(v.new_vaccinations, '') AS new_vaccinations,
    SUM(CONVERT(v.new_vaccinations, SIGNED)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
  FROM coviddeaths d
  JOIN covidvaccinations v ON d.location = v.location AND d.date = v.date
 WHERE d.continent <> ''
 ORDER BY 2, 3;

-- Using Temp Table to Perform Calculation on Partition By in Previous Query
-- Drop the table if it exists
DROP TABLE IF EXISTS PercentPopulationVaccinated;

-- Create the temporary table
CREATE TABLE PercentPopulationVaccinated
(Continent NVARCHAR(255),
 Location NVARCHAR(255),
 DATE DATETIME,
 Population NUMERIC,
 New_vaccinations NUMERIC,
 RollingPeopleVaccinated NUMERIC);

-- Insert data into the PercentPopulationVaccinated temporary table
INSERT INTO PercentPopulationVaccinated
SELECT d.continent, d.location, STR_TO_DATE(d.date, '%m/%d/%y') AS formatted_date, d.population,
    COALESCE(CONVERT(NULLIF(v.new_vaccinations, ''), SIGNED), 0) AS NewVaccinationsAsInteger,
    SUM(COALESCE(CONVERT(NULLIF(v.new_vaccinations, ''), SIGNED), 0)) OVER (PARTITION BY d.location ORDER BY d.location, STR_TO_DATE(d.date, '%m/%d/%y')) AS RollingPeopleVaccinated
  FROM coviddeaths d
  JOIN covidvaccinations v ON d.location = v.location AND d.date = v.date;

-- Query the data with additional calculation
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
  FROM PercentPopulationVaccinated;

-- Creating View to Store Data for Visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
    SUM(CONVERT(v.new_vaccinations, SIGNED)) OVER (PARTITION BY d.Location ORDER BY d.location, d.Date) AS RollingPeopleVaccinated
  FROM coviddeaths d
  JOIN covidvaccinations v ON d.location = v.location AND d.date = v.date
 WHERE d.continent <> '';
 
