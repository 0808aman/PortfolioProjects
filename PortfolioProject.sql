Select *
From PortfolioProject..coviddeaths$ 
order by 3,4


--Select *
--From PortfolioProject..covidvaccinations$ 
--order by 3,4


-- Select Data that we are going to be using


Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..coviddeaths$
order by 1,2


-- Looking at the total cases vs total deaths

Select location,date,total_cases,total_deaths, ( total_deaths/total_cases )*100 as Deathpercentage
From PortfolioProject..coviddeaths$
Where location like '%india%'
order by 1,2


--Looking at the total cases vs the population
--Shows what % of population have covid


Select location,date,total_cases,population, ( total_cases/population )*100 as CovidPercentage
From PortfolioProject..coviddeaths$
Where location like '%india%'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select location,population, MAX(total_cases) as HigestInfectionCount, MAX(( total_cases/population ))*100 as PercentInfection
From PortfolioProject..coviddeaths$
--Where location like '%india%'
Group by location,population
order by 4 DESC


--Showing the countries with the highest death count per population
--casting total_death to integer because it is mentioned as char in data

Select location, MAX(cast(total_deaths as int)) as TotalDeath
From PortfolioProject..coviddeaths$
Where continent is not null
Group by location
order by TotalDeath DESC


-- Lets break things down by continent
-- If used continent instead of location, it will show data of country in that continent

Select location, MAX(cast(total_deaths as int)) as TotalDeath
From PortfolioProject..coviddeaths$
Where continent is null
Group by location
order by TotalDeath DESC


--Showing the continents with the highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeath
From PortfolioProject..coviddeaths$
Where continent is null
Group by location
order by TotalDeath DESC


-- GLOBAL NUMBERS

Select date,SUM(new_cases) as NewCase, SUM(cast (new_deaths as int)) as NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) as Deathpercentage
From PortfolioProject..coviddeaths$
--Where location like '%india%'
Where continent is not null 
Group by date
order by 1,2


-- Total Death

Select SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) as Deathpercentage
From PortfolioProject..coviddeaths$
--Where location like '%india%'
Where continent is not null 
order by 1,2


--Looking at total population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location, dea.Date)  as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Use CTE

With  PopvsVac (Continent, location, date, Population, New_vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location, dea.Date)  as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination int,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location, dea.Date)  as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to Store Date for later visualisations

Create view PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location, dea.Date)  as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPeopleVaccinated