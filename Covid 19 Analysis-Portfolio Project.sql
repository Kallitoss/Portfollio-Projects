/* Covid 19 Data Emploration

Skills used: Joins, CTE'S, Temp Tables, Windows Functions,
Aggregate functions, Creating views and Converting data types

*/

SELECT * FROM COVIDDEATHS
WHERE continent is not null
ORDER BY 3,4

--SELECTING DATA THAT I'AM GOING TO START WITH

SELECT location, date , total_cases, new_cases, total_deaths, population
FROM COVIDDEATHS
ORDER BY 1,2 


--lookin at total casses v total deaths
--Shows likelihood of dying if infected by COVID

SELECT location, date, total_cases, total_deaths, (total_deaths/nullif(total_cases,0)*100)  AS DeathProcentage
FROM COVIDDEATHS
WHERE continent IS NOT NULL
ORDER BY 1,2


--lookin at total casses v total deaths in my country

SELECT location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases, 0) *100) AS DeathProcentage
FROM COVIDDEATHS
WHERE location LIKE '%erbia%'
ORDER BY 1,2

--looking at total casses v total deaths in all countrys whose names start on letter S

SELECT location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases, 0) *100) AS DeathProcentage
FROM COVIDDEATHS
WHERE location LIKE 'S%' AND
continent IS NOT NULL
ORDER BY 1,2

--Looking at  Total Casses vs Population 
--Shows us what percentage of population got infected by COVID

SELECT location, date,population, total_cases, (total_cases/NULLIF(population, 0) *100) AS ProcentageOfPeopleThatGotCovid
FROM COVIDDEATHS
--WHERE location LIKE '%erbia%'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population

SELECT location,population, MAX(total_cases) AS HighestInfectionCountInCOuntry, MAX((total_cases/NULLIF(population, 0) *100)) AS ProcentageOfPeopleThatGotCovid
FROM COVIDDEATHS
--WHERE location LIKE '%erbia%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY ProcentageOfPeopleThatGotCovid DESC


--Showing countries with highest death rate PER POPULATION

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM COVIDDEATHS
--WHERE location LIKE '%erbia%'
WHERE continent IS NOT NULL
GROUP BY location  
ORDER BY TotalDeathCount DESC 

--LET'S BREAK THINGS DOWN BY CONTINET

--Here i will show continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM COVIDDEATHS
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



------Looking at total population vs vaccinations
-- Showing percentage of population that recieved at least one covid vaccine

SELECT DEATHS.continent, DEATHS.location, DEATHS.date, DEATHS.population, 
VAX.new_vaccinations, SUM(CONVERT(float,VAX.new_vaccinations)) OVER (PARTITION BY DEATHS.location ORDER BY DEATHS.location , DEATHS.date) AS RollingPoepleVaccinated
 FROM COVIDDEATHS AS DEATHS
JOIN CovidVaccinations AS VAX
ON DEATHS.location = VAX.location
AND DEATHS.date = VAX.date
WHERE DEATHS.continent IS NOT NULL
ORDER BY 2, 3 


--Using CTE to perform calculation on partition by COLUMN that was created in previous query

WITH PopvsVax (Continent, Location, Date, population, new_vaccinations, RollingPoepleVaccinated)
AS
(
SELECT DEATHS.continent, DEATHS.location, DEATHS.date, DEATHS.population, 
VAX.new_vaccinations, SUM(CONVERT(float,VAX.new_vaccinations)) OVER (PARTITION BY DEATHS.location ORDER BY DEATHS.location , DEATHS.date) AS RollingPoepleVaccinated
 FROM COVIDDEATHS AS DEATHS
JOIN CovidVaccinations AS VAX
ON DEATHS.location = VAX.location
AND DEATHS.date = VAX.date
WHERE DEATHS.continent IS NOT NULL
--ORDER BY 2, 3 
)
SELECT * , (RollingPoepleVaccinated/population) *100
FROM PopvsVax 


--- Using Temp table to perform calculation on partition by COLUMN that was created in previous query
DROP TABLE IF EXISTS
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPoepleVaccinated numeric
)
 
 INSERT INTO #PercentPopulationVaccinated
 SELECT DEATHS.continent, DEATHS.location, DEATHS.date, DEATHS.population, 
VAX.new_vaccinations, SUM(CONVERT(float,VAX.new_vaccinations)) OVER (PARTITION BY DEATHS.location ORDER BY DEATHS.location , DEATHS.date) AS RollingPoepleVaccinated
 FROM COVIDDEATHS AS DEATHS
JOIN CovidVaccinations AS VAX
ON DEATHS.location = VAX.location
AND DEATHS.date = VAX.date
WHERE DEATHS.continent IS NOT NULL
--ORDER BY 2, 3 


SELECT * , (RollingPoepleVaccinated/population) *100
FROM #PercentPopulationVaccinated

--Creating view to store data for future visualizations 

CREATE VIEW PercentPopulationVaccinatedD AS
 SELECT DEATHS.continent, DEATHS.location, DEATHS.date, DEATHS.population, 
VAX.new_vaccinations, SUM(CONVERT(float,VAX.new_vaccinations)) OVER (PARTITION BY DEATHS.location ORDER BY DEATHS.location , DEATHS.date) AS RollingPoepleVaccinated
 FROM COVIDDEATHS AS DEATHS
JOIN CovidVaccinations AS VAX
ON DEATHS.location = VAX.location
AND DEATHS.date = VAX.date
WHERE DEATHS.continent IS NOT NULL


