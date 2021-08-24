select * from [Portfolio Project]..CovidDeaths order by 3,4;


--select * from [Portfolio Project]..CovidVaccinations order by 3,4;

-- Looking at total_cases vs total_deaths
 
select location, date, total_cases, new_cases, total_deaths, population from [Portfolio Project]..CovidDeaths order by 1,2;

--shows the likelihood of dying if you contact covid in your country.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from [Portfolio Project]..CovidDeaths 
where location like '%India%'
order by 1,2;

--total_cases vs population(what % have got covid)
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected from [Portfolio Project]..CovidDeaths 
where location like '%India%'
order by 1,2;

--looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as PercentPopulationInfected 
from [Portfolio Project]..CovidDeaths 
group by location, population
order by PercentPopulationInfected desc;

--showing countries with highest percentage deaths
select location, population, MAX(cast(total_deaths as int)) as Highest_Death_Count
from [Portfolio Project]..CovidDeaths 
where continent is not null
group by location, population
order by Highest_Death_Count desc;

--Based on continent
select continent, MAX(cast(total_deaths as int)) as Highest_Death_Count
from [Portfolio Project]..CovidDeaths 
where continent is not null
group by continent
order by Highest_Death_Count desc;

-- global numbers
select date, sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from [Portfolio Project]..CovidDeaths 
--where location like '%India%'
where continent is not null
group by date
order by 1,2;

select sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from [Portfolio Project]..CovidDeaths 
--where location like '%India%'
where continent is not null
--group by date
order by 1,2;


select * from [Portfolio Project]..CovidVaccinations;

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
from [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--vaccination for total population vs vaccinations
--use cte
with PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated) as 
(select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
from [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac;


--temp table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
from [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated;


-- Creating view to store data for visualization
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
from [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated;