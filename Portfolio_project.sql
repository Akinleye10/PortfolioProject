--SELECT *
--FROM Portfolio_Project..COVID_VACCINATION


select *
from Portfolio_Project..COVID_DEATH


--select data that we are going to  be using
select  location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..COVID_DEATH
order by 1,2

--looking at the total cases vs total deaths
select  location, date, total_cases, total_deaths, population, (total_deaths/ CONVERT(numeric,total_cases))*100 as death_rate_percentage
from Portfolio_Project..COVID_DEATH
where location = 'Nigeria'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of the population has got covid
select  location, date, total_cases, population, (total_cases/ population )*100 as pecent_Population
from Portfolio_Project..COVID_DEATH
where location = 'Nigeria'
order by 1,2


-- Looking at countries with highest infection rate compared to population 
select  location, max(cast(total_cases as int)) as highestInfectionCount, population, max(total_cases/ population )*100 as percent_Population_infected
from Portfolio_Project..COVID_DEATH
--where location = 'Nigeria'
where continent is not null
group by location,population
order by  percent_Population_infected desc


-- showing contries with highest death count per population
select  location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..COVID_DEATH
--where location = 'Nigeria'
where continent is not null
group by location,population
order by  TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT 

select  continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..COVID_DEATH
--where location = 'Nigeria'
--where LOCATION is not null
group by continent
order by  TotalDeathCount desc

-- global numbers

select  sum(new_cases) AS total_cases, sum(new_deaths) as tottal_deaths,   CASE
        WHEN SUM(new_cases) = 0 THEN NULL  -- Check for division by zero
        ELSE SUM(CAST(new_deaths AS INT)) / SUM(CAST(new_cases AS INT))*100
    END AS  Deathpercentage--,total_deaths, (total_cases/cast( total_deaths as int) )*100 as DeathPercentage
from Portfolio_Project..COVID_DEATH
--where location = 'Nigeria'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccination

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from Portfolio_Project..COVID_DEATH dea
join Portfolio_Project..COVID_VACCINATION vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
-- USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccination)
as(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from Portfolio_Project..COVID_DEATH dea
join Portfolio_Project..COVID_VACCINATION vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)

select *, (RollingPeopleVaccination/ population)*100 AS PercentageOfPopulationVaccinated
from PopvsVac

--temp table

drop table if exists #percentPopulationVaccinated

create table #percentPopulationVaccinated
(
continent nvarchar(255), location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric)


insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from Portfolio_Project..COVID_DEATH dea
join Portfolio_Project..COVID_VACCINATION vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 

select *, (RollingPeopleVaccination/ population)*100 AS PercentageOfPopulationVaccinated
from #percentPopulationVaccinated

-- creating view to store data for later visualization

create view percentPopulationVaccinated as 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from Portfolio_Project..COVID_DEATH dea
join Portfolio_Project..COVID_VACCINATION vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 
select *
 from percentPopulationVaccinated