select * from covid_death
order by 3,4

select location , date, total_cases , new_cases , total_deaths , population
from covid_death
order by 1,2
-- totalcases v/s totaldeath
select location , date , total_cases , total_deaths , IsNull((total_deaths/total_cases)*100,0) as DeathPercentage
from covid_death
where location like 'Cape%'
order by 1,2
 -- Totalcases vs population
select location , date, total_cases , population ,ISNULL((total_cases/population)*100,0) as PercentagePopulationInfected
from covid_death
--where location like 'cape%'
order by 1,2

-- countries with max cases
select location , population,MAX(total_cases) as HigestCases ,ISNULL(MAX((total_cases/population))*100,0) as PercentagePopulationInfected
from covid_death
group by location,population
--where location like 'cape%'
order by PercentagePopulationInfected desc

-- maximum deaths for location
select location , MAX(total_deaths) as TotalDeathCount
from covid_death
where continent is not null
group by location
order by TotalDeathcount desc

-- maximum deaths in continent
select continent , MAX(total_deaths) as TotalDeathCount
from covid_death
where continent is not null
group by continent
order by TotalDeathcount desc

select location , date , total_cases , total_deaths , IsNull((total_deaths/total_cases)*100,0) as DeathPercentage
from covid_death
--where location like 'Cape%'
where continent is not null 
order by 1,2


-- newdeaths vs newcases
select 
  --new_cases 
--, new_deaths,
  sum(new_cases) as total_cases 
, sum(new_deaths) as total_deaths 
, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from covid_death
where continent is not null
order by 1,2

-- find total vaccinated people , people left from vaccination and vaccination percentage location wise
select 
cd.continent, 
cd.location, 
cd.population as TotalPopulation , 
Sum(cast(cv.new_vaccinations as float))  as TotalVaccinated
, cd.population - Sum(cast(cv.new_vaccinations as float)) as PeopleLeftFromVaccination
,(Sum(cast(cv.new_vaccinations as float))/cd.population)*100 as VaccinationPercentage
--sum(cast(cv.new_vaccinations as float)) over (Partition by cd.location) as VaccinationByLocation
from covid_vaccination as cv
join covid_death as cd
on cv.location = cd.location and cv.date = cd.date
where cd.continent is not null 
group by cd.location , cd.continent , cd.population --, cv.new_vaccinations
order by 2

--select continent,location from covid_death
--where continent is null

-- find american continents
select 
cd.continent, 
--cd.location,
Sum(cd.population) as TotalPopulation , 
Sum(cast(cv.new_vaccinations as float))  as TotalVaccinated
, Sum(cd.population) - Sum(cast(cv.new_vaccinations as float)) as PeopleLeftFromVaccination
,(Sum(cast(cv.new_vaccinations as float))/Sum(cd.population))*100 as VaccinationPercentage
--sum(cast(cv.new_vaccinations as float)) over (Partition by cd.location) as VaccinationByLocation
from covid_vaccination as cv
join covid_death as cd
on cv.location = cd.location and cv.date = cd.date
where cd.continent is not null and cd.continent like '%america'
group by cd.continent --, cd.population --, cv.new_vaccinations
order by 1,2

-- find top 2 continents where highest numbers of people are without vaccination 
select top 2
cd.continent,
--cd.location,
Sum(cd.population) as TotalPopulation , 
Sum(cast(cv.new_vaccinations as float))  as TotalVaccinated
, Sum(cd.population) - Sum(cast(cv.new_vaccinations as float)) as PeopleLeftFromVaccination
,(Sum(cast(cv.new_vaccinations as float))/Sum(cd.population))*100 as VaccinationPercentage
--sum(cast(cv.new_vaccinations as float)) over (Partition by cd.location) as VaccinationByLocation
from covid_vaccination as cv
join covid_death as cd
on cv.location = cd.location and cv.date = cd.date
where cd.continent is not null
group by cd.continent
order by 4 desc


-- temp table
Drop table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
Date numeric,
NewVaccinations numeric , 
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations
, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location ,cd.date) 
as RollingPeopleVaccinated
from covid_death as cd
Join covid_vaccination as cv
on cd.location = cv.location
and cd.date = cv.date

select* , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- creating a view to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations
, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location ,cd.date) 
as RollingPeopleVaccinated
from covid_death as cd
Join covid_vaccination as cv
on cd.location = cv.location
and cd.date = cv.date




