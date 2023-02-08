create database if not exists project;

use project;

select * from data1;
select * from data2;

-- numbers of row in dataset
select count(*) from data1;
select count(*) from data2;

-- data for Maharashtra and Gujarat

select *
from data1
where State in ("Maharashtra","Gujarat"); 

-- Total Population of India
select sum(Population) as Total_Population
from data2;

-- average growth of india
select concat(round(avg(Growth) * 100,2) ,"%") as average_growth
from data1;

-- District & State with maximum growth
select *
from data1 
where Growth = (select max(Growth)
from data1);

-- District & State with maximum Literacy
select *
from data1 
where Literacy = (select max(Literacy)
from data1);


-- District & State with maximum sex_ratio
select *
from data1 
where sex_ratio = (select max(sex_ratio)
from data1);

-- avg growth by state
select State,round(avg(Growth) * 100,2) as average_growth
from data1
group by State
order by average_growth desc;


-- avg Literacy by state
select State,concat(round(avg(Literacy),2),"%") as average_literacy
from data1
group by State
order by average_literacy desc;

-- avg Sex Ratio by state
select State,round(avg(Sex_Ratio),2) as avg_sex_ratio
from data1
group by State
order by avg_sex_ratio desc;

-- Top 3 state with highest avg growth ratio
select State,round(avg(Growth) * 100,2) as average_growth
from data1
group by State
order by average_growth desc
limit 3;

-- Top 3 state with highest avg Literacy 
select State,concat(round(avg(Literacy),2),"%") as average_literacy
from data1
group by State
order by average_literacy desc
limit 3;

-- Top 3 state with highest avg_sex_ratio
select State,round(avg(Sex_Ratio),2) as avg_sex_ratio
from data1
group by State
order by avg_sex_ratio desc
limit 3;

-- Bottom 3 state with lowest avg growth ratio
select State,round(avg(Growth) * 100,2) as average_growth
from data1
group by State
order by average_growth asc
limit 3;

-- Bottom 3 state with lowest avg Literacy 
select State,concat(round(avg(Literacy),2),"%") as average_literacy
from data1
group by State
order by average_literacy asc
limit 3;

-- Bottom 3 state with lowest avg_sex_ratio
select State,round(avg(Sex_Ratio),2) as avg_sex_ratio
from data1
group by State
order by avg_sex_ratio asc
limit 3;


-- top3 and bottom3 avg literacy state in one output with union operator
(
select State,round(avg(Literacy),2) as average_literacy
from data1
group by State
order by average_literacy desc
limit 3)
union
(select State,round(avg(Literacy),2) as average_literacy
from data1
group by State
order by average_literacy asc
limit 3);

-- state start with A letter
select distinct state
from data1
where State like "A%";

-- state end with A letter
select distinct state
from data1
where State like "%A";

-- state start with letter 'A' and end with letter 'h'
select distinct state
from data1
where lower(State) like "a%" and lower(State) like "%h";

-- joining both the table
-- male and female per district 
select c.District,c.state,round(c.population/(c.sex_ratio+1),0) as males, round((c.population* c.sex_ratio)/(c.sex_ratio+1),0) as females 	
from (select a.District,a.state,a.sex_ratio/1000 as sex_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District) c;

-- males and females per state
select d.State,sum(males),sum(females)
from (
select c.District,c.state,round(c.population/(c.sex_ratio+1),0) as males, round((c.population* c.sex_ratio)/(c.sex_ratio+1),0) as females 	
from (select a.District,a.state,a.sex_ratio/1000 as sex_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District) c) d
group by d.state;

-- state with max males 

with data3 as
(
select a.District,a.state,a.sex_ratio/1000 as sex_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District
),
district_data as 
(
select District,state,round(population/(sex_ratio+1),0) as males, round((population* sex_ratio)/(sex_ratio+1),0) as females
from data3
),
state_data as
(
select State,sum(males) as males,sum(females) as females
from district_data
group by State
)
select state,males 
from state_data 
where state_data.males = (select Max(males) from state_data);

-- state with max female
with data3 as
(
select a.District,a.state,a.sex_ratio/1000 as sex_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District
),
district_data as 
(
select District,state,round(population/(sex_ratio+1),0) as males, round((population* sex_ratio)/(sex_ratio+1),0) as females
from data3
),
state_data as
(
select State,sum(males) as males,sum(females) as females
from district_data
group by State
)
select state,females 
from state_data 
where state_data.females = (select Max(females) from state_data);

-- state with min males and females 
with data3 as
(
select a.District,a.state,a.sex_ratio/1000 as sex_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District
),
district_data as 
(
select District,state,round(population/(sex_ratio+1),0) as males, round((population* sex_ratio)/(sex_ratio+1),0) as females
from data3
),
state_data as
(
select State,sum(males) as males,sum(females) as females
from district_data
group by State
)
select state,males, females 
from state_data 
where state_data.males = (select min(males) from state_data) or state_data.females = (select min(females) from state_data);

-- caluclate literate and illiterate people by district
with data3 as
(
select a.District,a.state,a.Literacy/100 as Literacy_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District
)
select district,state,round(Literacy_ratio*Population,0) as literate_people , round((1-Literacy_ratio)*Population,0) as illiterate_people
from data3;



-- caluclate literate and illiterate people by state
with data3 as
(
select a.District,a.state,a.Literacy/100 as Literacy_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District
),
district_value as 
(
select District,state,round(Literacy_ratio*Population,0) as literate_people , round((1-Literacy_ratio)*Population,0) as illiterate_people
from data3
)
select state,sum(literate_people),sum(illiterate_people)
from district_value
group by state;

-- population in previous cencus by district

with data3 as
(
select a.District,a.state,a.Growth as growth_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District
)
select District,state,round(Population/growth_ratio,0) as previous_people, round(population,0) as population
from data3;

-- population in previous cencus by state

with data3 as
(
select a.District,a.state,a.Growth as growth_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District
),
district_data  as
(
select District,state,round(Population/(1+growth_ratio),0) as previous_people, round(population,0) as population
from data3
) 
select state,sum(previous_people) as previous_cencus, sum(population) as current_cencus from district_data group by state;

-- difference of population by current and previous cencus by state

with data3 as
(
select a.District,a.state,a.Growth as growth_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District
),
district_data  as
(
select District,state,round(Population/(1+growth_ratio),0) as previous_people, round(population,0) as population
from data3
) ,
state_data as
(
	select state,sum(previous_people) as previous_cencus, sum(population) as current_cencus from district_data group by state
)
select state, current_cencus - previous_cencus as population_difference
from state_data
order by population_difference desc;

-- state with max population increment and state with population decrease than previous year
with data3 as
(
select a.District,a.state,a.Growth as growth_ratio,b.Population
from data1 as a inner join data2 as b on a.District = b.District
),
district_data  as
(
select District,state,round(Population/(1+growth_ratio),0) as previous_people, round(population,0) as population
from data3
) ,
state_data as
(
	select state,sum(previous_people) as previous_cencus, sum(population) as current_cencus from district_data group by state
),
difference_data as 
(
select state, current_cencus - previous_cencus as population_difference
from state_data
)
select *
from difference_data
where population_difference = (select max(population_difference) from difference_data) or population_difference = (select min(population_difference) from difference_data);

-- population in 1 km2 
select *,round(population/Area_km2,0) as population_per_km2
from data2;

-- total area and total population per state
select state,sum(Area_km2) as total_area,round(sum(Population),0) as total_population
from data2
group by state;

-- state population percentage in compare to total country population
with indian_population as 
(
 select sum(Population) as indian_total_population
 from data2
),
state_population as (
	select state,sum(Population) as state_population
	from data2	
	group by State
)
select state,round((state_population/indian_total_population)*100,2) as percentage_of_total_population
from state_population,indian_population;

-- top3 state with highest population contribution to all over population
with indian_population as 
(
 select sum(Population) as indian_total_population
 from data2
),
state_population as (
	select state,sum(Population) as state_population
	from data2	
	group by State
)
select state,round((state_population/indian_total_population)*100,2) as percentage_of_total_population
from state_population,indian_population
order by percentage_of_total_population desc
limit 3;

-- bottom 3 state with lowest population contribution to all over population
with indian_population as 
(
 select sum(Population) as indian_total_population
 from data2
),
state_population as (
	select state,sum(Population) as state_population
	from data2	
	group by State
)
select state,round((state_population/indian_total_population)*100,2) as percentage_of_total_population
from state_population,indian_population
order by percentage_of_total_population asc
limit 3;

-- top 3 district that need to fit more peope in 1 km2 spaces then previous year
with data3 as
(
select a.District,a.state,a.Growth as growth_ratio,b.Area_km2,b.Population
from data1 as a inner join data2 as b on a.District = b.District
),
district_data as 
(
	select District,state,Area_km2,round(Population/(1+growth_ratio),0) as previous_people, round(population,0) as population
	from data3
)
select district,state, round((population - previous_people)/Area_km2,0) as per_km_difference_of_people
from district_data
order by per_km_difference_of_people desc
limit 3;



-- top 3 state that need to fit more peope  in 1 km2 spaces then previous year
with data3 as
(
select a.District,a.state,a.Growth as growth_ratio,b.Area_km2,b.Population
from data1 as a inner join data2 as b on a.District = b.District
),
district_data as 
(
	select District,state,Area_km2,round(Population/(1+growth_ratio),0) as previous_people, round(population,0) as population
	from data3
),
aggregated_data 
as
(
select state, sum(round(previous_people,0)) as previous_year_population , sum(round(population,0)) as population,sum(Area_km2) as total_are
	from district_data
	group by state
)
select state,round((population - previous_year_population)/total_are,0) as per_km2_population_difference
from aggregated_data
order by per_km2_population_difference desc
limit 3;


-- top 3 district from each state with higest literacy rate 
select * 
from (
select * , dense_rank() over(partition by State order by Literacy desc) as top_3
from data1
) m
where m.top_3 <= 3
order by State;




-- 

