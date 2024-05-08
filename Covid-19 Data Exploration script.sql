----Table names (CovidDeaths,covidVaccination)



SELECT * FROM CovidDeaths;

SELECT * FROM covidVaccination;



/* Data Exploration on Covid-19 dataset

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views

*/

Select *
From CovidDeaths
Where continent is not null 
order by 3,4;


-- To select the starting Data 

Select Location, trunc(datetime), total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2;




-- Total Cases vs Total Deaths
-- Shows the chance of dying if you contract covid-19 in various countries

Select Location, trunc(datetime) Date_, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%Nigeria%'
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of a countries population is infected with Covid-19

Select Location, datetime, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%Nigeria%'
order by 1,2;


-- Percentage of population infected with covid-19

Select Location, max(Population), MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%Nigeria%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- Total Covid-19 deaths per country

Select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- A BREAKDOWN BY CONTINENT

-- Total Covid-19 deaths per continent

Select continent, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%Nigeria%'
where continent is not null 
--Group By date
order by 1,2;



-- Total Population against Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid-19 Vaccine

Select dea.continent, dea.location, trunc(dea.datetime), dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Datetime) as TotalPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.datetime = vac.datetime
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Datetime, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, trunc(dea.datetime), dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Datetime) as TotalPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.datetime = vac.datetime
where dea.continent is not null 
--order by 2,3
)
Select P.*,(TotalPeopleVaccinated/Population)*100
From PopvsVac P;



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.datetime, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Datetime) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.datetime = vac.datetime
where dea.continent is not null 




