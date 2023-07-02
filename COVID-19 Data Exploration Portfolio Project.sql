Select * from PortfolioProject1..CovidDeaths
WHERE 
	continent is not null
ORDER BY
	3,4

Select * from PortfolioProject1..CovidVaccinations
WHERE 
	continent is not null
ORDER BY
	3,4


--Lets Select Data that i am interested to explore and dive deep

SELECT
    Location,
    Date,
    Total_Cases,
    New_Cases,
    Total_Deaths,
    Population
FROM
    PortfolioProject1..CovidDeaths
WHERE 
	continent is not null
ORDER BY
    1,2;


-- Total Cases Reported Vs Total Deaths
-- Shows the likelihood of dying if you contract COVID-19 in your country

SELECT
	Location,
    Date,
    Total_Cases,
    Total_Deaths,
    (Total_Deaths / Total_Cases) * 100 AS DeathPercentage
FROM
    PortfolioProject1..CovidDeaths
WHERE 
	location like '%state%' AND
	continent is not null
ORDER BY
    1,2;

--Looking at Total Cases Vs Population

SELECT
	Location,
    Date,
	population,
    Total_Cases,
    (Total_cases /population) * 100 AS PercentPopulationInfected
FROM
    PortfolioProject1..CovidDeaths
WHERE 
	location like '%state%' AND
	continent is not null
ORDER BY
    1,2;


--Countries with highest Infection Rate Vs Population

SELECT
    Location,
    Population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    PortfolioProject1..CovidDeaths
WHERE 
	continent is not null
GROUP BY
    Location,
    Population
ORDER BY
    PercentPopulationInfected DESC;


--Showing Countries with highest DeathCounts per Population

SELECT
    Location,
	MAX(total_deaths) AS TotalDeathCount,
    MAX((total_deaths / population)) * 100 AS PercentTotalDeathCount
FROM
    PortfolioProject1..CovidDeaths
WHERE 
	continent is not null
GROUP BY
    Location
ORDER BY
    TotalDeathCount DESC;


--BREAKDOWN BY CONTINENT
 
 SELECT
    continent,
	MAX(total_deaths) AS TotalDeathCount,
    MAX((total_deaths / population)) * 100 AS PercentTotalDeathCount
FROM
    PortfolioProject1..CovidDeaths
WHERE 
	continent is not null
GROUP BY
    continent
ORDER BY
    TotalDeathCount DESC;


-- ** GLOBAL CALCULATIONS **

-- Calculates the total cases, total deaths, and death percentage based on new cases and new deaths per day.
-- Excludes rows with null continent values to focus on specific regions.
-- Handles potential divide-by-zero error and null values in the calculations.

SELECT
    date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    CASE
        WHEN SUM(new_cases) <> 0 THEN (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100
        ELSE NULL
    END AS DeathPercentage
FROM
    PortfolioProject1..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
   total_cases DESC, date ; 


-- WORLDWIDE Total Cases
-- Calculates total cases, total deaths, and death percentage based on new cases and deaths.
-- Handles divide-by-zero error and excludes null continent values.
-- Results are ordered by total cases and deaths.

SELECT
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    CASE
        WHEN SUM(new_cases) <> 0 THEN (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100
        ELSE NULL
    END AS DeathPercentage
FROM
    PortfolioProject1..CovidDeaths
WHERE 
    continent IS NOT NULL
ORDER BY
     1, 2 ; 


-- Using CTE to explore total population vs vaccinations
-- Calculates the rolling sum of people vaccinated over time, by location
-- Calculates the percentage of the population vaccinated

WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject1..CovidDeaths dea
    JOIN 
        PortfolioProject1..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)

SELECT *, 
    (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM 
    PopvsVac;


--TEMP TABLE


-- This query calculates the rolling sum of new vaccinations for each location and the corresponding percentage of population vaccinated.
-- The data is retrieved from the CovidDeaths and CovidVaccinations tables in the PortfolioProject database.
-- The result is stored in a temporary table called #PercentPopulationVaccinated and displayed at the end of the query.

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);


INSERT INTO #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
    PortfolioProject1..CovidDeaths dea
JOIN
    PortfolioProject1..CovidVaccinations vac ON dea.location = vac.location
                                            AND dea.date = vac.date;

SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM
    #PercentPopulationVaccinated;

--Creating Views for Later Visualization

CREATE VIEW PercentPopulationVaccinatedd AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
    PortfolioProject1..CovidDeaths dea
JOIN
    PortfolioProject1..CovidVaccinations vac ON dea.location = vac.location
                                            AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


