
-- Looking at Total Cases vs Total Deaths
Select location, total_cases, date, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths

--Looking at Total Cases vs Population 
Select location,total_cases, date, population, (total_cases/population)*100 as CasesPerPopulation
From CovidDeaths

--Looking at Countries with Highest Infection Rate 
Select location, Max(total_cases) as HighestNoOfCases, Max((total_cases/population))*100 as HighestInfectionRate
From CovidDeaths
Group By location
Order By HighestInfectionRate Desc

-- Countries showing highest death count per population 
Select location, Max (total_deaths) as HighestDeathCount , Max((total_deaths/population))*100 as DeathPercentagePerPopulation
From CovidDeaths
where continent is not null
Group By location
Order By HighestDeathCount Desc

-- Continents

Select location, Max(total_deaths) as TotalDeathCount
From CovidDeaths
where continent is null
Group By location
Order By TotalDeathCount desc

-- Global Numbers
Select date, SUM(new_cases) as TotalCases , Sum(new_deaths) as TotalDeaths, Sum(cast(new_deaths as float))/Sum(new_cases) *100 as DeathPercentage
From CovidDeaths
where continent is not null
Group By date
Order By 1,2

-- Looking for TotalPopulation Vs Vaccination 

-- USE CTE

With PopVsVacc(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order by dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
-- Order by 2,3 
)
Select *, (cast(RollingPeopleVaccinated as float)/Population)*100 as VaccinatedPercentage
From PopVsVacc


-- Temp Table
Drop Table if exists #PercentagePopulationVaccinated 
Create Table #PercentagePopulationVaccinated 
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric 
)
Insert Into #PercentagePopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order by dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
-- Order by 2,3 


Select *, (cast(RollingPeopleVaccinated as float)/Population)*100 as VaccinatedPercentage
From #PercentagePopulationVaccinated



-- Creating View to store data for later visualizations 

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) Over (Partition By dea.location Order by dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
-- Order by 2,3 

Select * 
From PercentagePopulationVaccinated

