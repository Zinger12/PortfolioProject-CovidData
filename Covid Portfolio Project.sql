SELECT * 
From [Portfolio projects]..Covid_deaths
where continent is not null
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio projects]..Covid_deaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if we get covid in india
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
From [Portfolio projects]..Covid_deaths
where location = 'India'
order by 1,2

-- Looking at total cases vs Population
-- Shows percentage of population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
From [Portfolio projects]..Covid_deaths
where location = 'India'
order by 1,2

--Looking at countries wit highest infection rate
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 AS InfectionRate
From [Portfolio projects]..Covid_deaths
where continent is not null
Group by location, population
order by InfectionRate desc

--Looking at countries wit highest Death count
Select Location, population, Max(cast(total_deaths as int)) as TotalDeathsCount
From [Portfolio projects]..Covid_deaths
where continent is not null
Group by location, population
order by TotalDeathsCount desc

--Let's work with the continent
--Let's look continent with highest death count per population 
Select continent, Max(cast(total_deaths as int)) as TotalDeathsCount
From [Portfolio projects]..Covid_deaths
where continent is not null
Group by continent
order by TotalDeathsCount desc

--Global numbers
Select continent, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, (sum(cast(new_deaths as int))/sum(new_cases)) as DeathPercentage
From [Portfolio projects]..Covid_deaths
where continent is not null and new_cases is not null
Group by continent
order by 1,3

-- Overall numbers
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, (sum(cast(new_deaths as int))/sum(new_cases)) as DeathPercentage
From [Portfolio projects]..Covid_deaths
where continent is not null and new_cases is not null
order by 1,2

-- Looking at total population vs vaccinated
-- Use of CTE
With PopvsVac(Continent, Location, Date, Population, new_vaccination, Vaccinated_thus_far)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_thus_far
From [Portfolio projects]..Covid_deaths as Dea 
join [Portfolio projects]..Covid_vaccinations as Vac
    On Dea.location = Vac.location and 
	Dea.date = Vac.date
where dea.continent is not null and Dea.population is not null
)
Select Location, Max(Population) as Population, Max(Vaccinated_thus_far) as Total_vaccinated, Max((Vaccinated_thus_far/Population)*100) as Vaccination_percent
from PopvsVac
group by Location


-- Creating view for later
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_thus_far
From [Portfolio projects]..Covid_deaths as Dea 
join [Portfolio projects]..Covid_vaccinations as Vac
    On Dea.location = Vac.location and 
	Dea.date = Vac.date
where dea.continent is not null and Dea.population is not null

Select *
from PercentPopulationVaccinated