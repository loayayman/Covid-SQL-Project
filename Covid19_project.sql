-- Active: 1758446815945@@127.0.0.1@3306@project_db
CREATE DATABASE IF NOT EXISTS project_db;
USE DATABASE project_db;
SELECT * FROM coviddeaths ORDER BY date LIMIT 10;

SELECT * FROM covidvacsination ORDER BY date LIMIT 10;

-- SELECTING THE DATA WE ARE GOING TO BE USEING
SELECT location, date ,total_cases ,New_cases,  total_deaths , population
   FROM coviddeaths 
         ORDER BY location AND date ;

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
SELECT location, date, total_cases, total_deaths ,(total_deaths/total_cases)*100 AS death_percentage
   FROM coviddeaths
         ORDER BY death_percentage DESC;

-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN EGYPT
SELECT location, date ,total_cases,  total_deaths ,(total_deaths / total_cases)*100 AS death_percentage
   FROM coviddeaths 
      WHERE location LIKE 'Egypt'
         ORDER BY date;

-- LOOKING AT TOTAL CASES VS POPULATION 
-- SHOWS WAHT PERCENTAGE OF POPULATION GOT COVID IN EGYPT
SELECT location, date ,  population ,total_cases, (total_cases / population)*100 AS percent_population_infected
   FROM coviddeaths 
    WHERE location like 'Egypt'
         ORDER BY date;

-- THE DAYS WITH MOST DEATHS IN EGYPT
SELECT location, date ,  population ,total_cases, (total_cases / population)*100 AS percent_population_infected
   FROM coviddeaths 
  --  WHERE location like 'Egypt'
         ORDER BY percent_population_infected DESC;

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location ,population ,MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/ population)*100 AS percent_population_infected
   FROM coviddeaths 
    GROUP BY location ,population 
      ORDER BY percent_population_infected DESC;


-- CHANGING TOTAL DEATH COLUMN TYPE TO INTEGER
UPDATE coviddeaths
   SET total_deaths = 0
      WHERE total_deaths = '';
ALTER TABLE coviddeaths
   MODIFY total_deaths INT DEFAULT NULL;

-- SHOWING THE COUNTRIES WITH THE HIGHEST DEATH COUNT
SELECT location, MAX(total_deaths) AS total_death_count
   FROM coviddeaths 
    GROUP BY location 
      ORDER BY total_death_count DESC;

--SHOWING THE COUNTRIES WITH THE HIGHEST CASES COUNT
SELECT location, MAX(total_cases) AS total_cases_count
   FROM coviddeaths 
    GROUP BY location 
      ORDER BY total_cases_count DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT 
-- SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT continent, MAX((total_deaths)) AS total_death_count
   FROM coviddeaths 
    GROUP BY continent 
      ORDER BY total_death_count DESC


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS total_deaths_percentage
   FROM coviddeaths
      GROUP BY date
         ORDER BY total_deaths_percentage DESC;

-- DEATH PERCENTAGE AROUND THE WORLD IF YOU GOT INFECTED
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS total_deaths_percentage
   FROM coviddeaths
         ORDER BY total_deaths_percentage DESC;


-- CHANGING NEW VACCINATION COLUMN TO INTEGER
UPDATE covidvacsination
SET new_vaccinations = 0
WHERE TRIM(new_vaccinations) = '' OR new_vaccinations IS NULL;
ALTER TABLE covidvacsination
MODIFY new_vaccinations BIGINT;


-- TOTAL POPULATION VS VACCINATIONS 
-- USE CTE 
WITH pop_vs_vac (conrinent, location ,date, population,new_vaccinations ,rolling_people_vaccinated)
AS(
SELECT dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations , SUM(vac.new_vaccinations) 
   OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS rolling_people_vaccinated
    -- (rolling_people_vaccinated / population) * 100
      FROM coviddeaths AS dea
         JOIN covidvacsination AS vac
            ON dea.location = vac.location
             AND dea.date = vac.date
             --   ORDER BY 2,3
)
SELECT * , (rolling_people_vaccinated / population) * 100 AS rolling_people_vaccinated
   FROM pop_vs_vac
      ORDER BY rolling_people_vaccinated DESC;


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZAION 
CREATE VIEW percent_population_vacinated AS
SELECT dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations , SUM(vac.new_vaccinations) 
   OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS rolling_people_vaccinated  
    -- (rolling_people_vaccinated / population) * 100
      FROM coviddeaths AS dea
         JOIN covidvacsination AS vac
            ON dea.location = vac.location
             AND dea.date = vac.date
                ORDER BY 2,3

SELECT * FROM percent_population_vacinated;