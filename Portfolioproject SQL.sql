select *
from PortfolioProject..CovidDeaths
Where continent is not Null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Selecting Data that I will be Using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
Where location like '%Bangladesh%'
and continent is not Null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid


Select Location, date, population, total_cases, (total_cases/population)*100 as Percentage_of_Population_infected
from PortfolioProject..CovidDeaths
--Where location like '%Bangladesh%'
and continent is not Null
order by 1,2

--Looking at the Countries with highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as Percentage_of_Population_infected
from PortfolioProject..CovidDeaths
--Where location like '%Bangladesh%'
Group by location, population
order by Percentage_of_Population_infected Desc


--Showing Countries with highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
--Where location like '%Bangladesh%'
Where continent is not Null
Group by location
order by Total_Death_Count Desc

--Breaking Things Down by Contninent

Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
--Where location like '%Bangladesh%'
Where continent is Null
Group by location
order by Total_Death_Count Desc

--Showing Continents with the highest death per population


Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
--Where location like '%Bangladesh%'
Where continent is not Null
Group by continent
order by Total_Death_Count Desc

--GLOBAL NUMBERS

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--Where location like '%Bangladesh%'
where continent is not Null
--group by datey 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(Convert(int, vac.new_vaccinations)) over (Partition by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
Select *, (Rolling_People_Vaccinated/Population)*100 Percentage_of_people_Vaccinated
From PopvsVac



--TEMP TABLE


Drop Table if Exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentagePopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null

Select *, (Rolling_People_Vaccinated/Population)*100 
From #PercentagePopulationVaccinated



--Creating view to store data for later Visualizations


Create View PercentagePopulation_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(Convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentagePopulation_Vaccinated