SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3, 4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2


-- Looking at Total Cases VS Total Deaths
-- Shows the Likelihood of dying if you contract covid in your country.
CREATE VIEW cases_vs_deaths AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
--ORDER BY 1, 2


-- Looking at the Total Cases VS Population
--Shows what percentage of population got Covid
CREATE VIEW cases_vs_popuation AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'India'
--ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population.
CREATE VIEW high_infec_rate AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'India'
GROUP BY location, population
--ORDER BY PercentPopulationInfected DESC


--Showing the countries with Highest Death count per population.
CREATE VIEW death_count AS
SELECT location, MAX(CAST(total_deaths AS INT))  AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC


--Breaking Things down by Continent
-- Showing the continents with highest death counts
CREATE VIEW continent_death_count AS
SELECT continent, MAX(CAST(total_deaths AS INT))  AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC


-- Global Numbers
CREATE VIEW global_numb AS
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY date
--ORDER BY 1, 2


--Looking at Total Population VS Vacination
CREATE VIEW popuation_vs_vac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RolligPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RolligPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent IS NOT NULL
--ORDER BY 2,3 
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


--TEMP TABLE 
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccination numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RolligPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent IS NOT NULL
ORDER BY 2,3 

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinate AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RolligPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent IS NOT NULL
--ORDER BY 2,3 