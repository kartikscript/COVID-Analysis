-- total cases vs total deaths and % of death rate 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage 
FROM coviddeaths 
;

-- total cases vs population and % of death rate 
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infected_population_percentage 
FROM coviddeaths 
WHERE location LIKE "India"
;


-- countries with highest infection rate
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS infected_population_percentage 
FROM coviddeaths 
GROUP BY location, population
ORDER BY infected_population_percentage DESC
;


-- countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS highest_death_count
FROM coviddeaths 
GROUP BY location
ORDER BY highest_death_count DESC
;

SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS highest_death_count
FROM coviddeaths 
GROUP BY continent
ORDER BY highest_death_count DESC
;

-- global nums
 
 -- sum of cases and deaths of all countries in a day ie ACCROSS the world
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM coviddeaths
GROUP BY date
;


-- total vaccination vs total population

-- using cte
WITH PopVsVac (continent, location, date, population, new_vacinations, rolling_people_vaccinated) AS
(
SELECT cd.continent, cd.location, STR_TO_DATE(cd.date, '%m/%d/%Y') AS date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY STR_TO_DATE(cd.date, '%m/%d/%Y') ) 
FROM coviddeaths cd
JOIN covidvaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
ORDER BY 2
)
SELECT continent,location,MAX(population),MAX(date) AS vacinated_till_date, MAX(rolling_people_vaccinated/population)*100 AS vaccinated_people_percentage
FROM PopVsVac
GROUP BY continent,location
;


-- with temp table
-- DROP TABLE IF EXISTS PercentagePopulationVaccinated;
-- CREATE TABLE PercentagePopulationVaccinated
-- (
-- continent nvarchar(255),
-- location nvarchar(255),
-- date datetime,
-- population numeric,
-- new_vacinations numeric,
-- rolling_people_vaccinated numeric
-- );

-- INSERT INTO PercentagePopulationVaccinated
-- SELECT cd.continent, cd.location, STR_TO_DATE(cd.date, '%m/%d/%Y') AS date, cd.population, cv.new_vaccinations,
-- SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY STR_TO_DATE(cd.date, '%m/%d/%Y') ) 
-- FROM coviddeaths cd
-- JOIN covidvaccinations cv
-- 	ON cd.location = cv.location AND cd.date = cv.date
-- ORDER BY 2
-- ;

-- SELECT *, (rolling_people_vaccinated/population)*100
-- FROM PercentagePopulationVaccinated
-- ;


-- creating view to store data for visualizations

CREATE VIEW PercentagePopulationVaccinatedViewpercentagepopulationvaccinatedview AS 
(
SELECT cd.continent, cd.location, STR_TO_DATE(cd.date, '%m/%d/%Y') AS date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY STR_TO_DATE(cd.date, '%m/%d/%Y') ) 
FROM coviddeaths cd
JOIN covidvaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
ORDER BY 2
)
;

SELECT `percentagepopulationvaccinatedview`.`continent`,
    `percentagepopulationvaccinatedview`.`location`,
    `percentagepopulationvaccinatedview`.`date`,
    `percentagepopulationvaccinatedview`.`population`,
    `percentagepopulationvaccinatedview`.`new_vaccinations`,
    `percentagepopulationvaccinatedview`.`Name_exp_6`
FROM `covid_insights`.`percentagepopulationvaccinatedview`;

