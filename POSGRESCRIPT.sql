create table netflixtb
(
	show_id	varchar(10),
	type	varchar(10),
	title	varchar(105),
	director varchar(210), 
	casts	varchar(1000),
	country	varchar(150),
	date_added	varchar(50),
	release_year int,
	rating	varchar(10),
	duration varchar(15),
	listed_in	varchar(100),
	description varchar(300)
);	

select * from netflixtb;

------------------15 Business Problems----------------------------

--1.count number of Movies vs Tv Shows
select 
type,
count(type) as count
from netflixtb
group by type;

--2.Find the most common rating for Movies and TvShows
with cte as(select 
	type,
	rating,
	count(rating) as count,
	rank()over(partition by type order by count(rating) desc)as rnk
from netflixtb
group by type,rating)
select type,rating,count
from cte
where rnk =1;

--3.List all movies released in specific years
select *
from netflixtb
where type = 'Movie' and release_year = 2020;

--4.Find the top 5 countries with the most content on netflix.
select unnest(string_to_array(country,',')) as country,
count(show_id) as count 
from netflixtb
group by 1
order by 2 desc;

--5.Identify the longest movie.
select title, max(cast(regexp_replace(duration, '\D','','g')as INT)) as duration
from netflixtb
where type = 'Movie' and duration is not null
group by title
order by 2 desc
LIMIT 1

--6. Find content added in the last 5 years.

select * from netflixtb
where TO_DATE(date_added,'Month DD,YYYY') >= current_date - interval '5 years'

--7.Find all movie/tv shows by director 'rajiv chilalka'
select type,director
from netflixtb
where director like '%Rajiv Chilaka%'

--8.List all tv shows with more than 5 seasons.

select type,title,(cast(split_part(duration,' ',1)as INT)) as duration
from netflixtb
where type = 'TV Show' and (cast(split_part(duration,' ',1)as INT)) >5

--9. Count the number of Content items in each genre

select count(type),type,
unnest(string_to_array(listed_in,',')) as genre
from netflixtb
group by genre,type

--10.Find each year and the average number of content released by india on netflix, 
--  return top 5 year with highest average content release.
select * from netflixtb
select EXTRACT(YEAR FROM To_date(date_added,' MONTH DD YYYY')) AS dateadded,
count(show_id) as count,
round((count(show_id):: numeric/(SELECT COUNT(*)FROM netflixtb where country = 'India') ::numeric)*100) as avg
from netflixtb
where country = 'India'
group by 1
order by 3 desc
limit 5

--11.List all movie that are documentaries
with cte as(select show_id,type,title,
unnest(string_to_array(listed_in,',')) as genre
from netflixtb)
select show_id, type,title,genre
from cte
where  genre='Documentaries'

--12.Find all content without a director
select *
from netflixtb
where director is null

--13.Find how many movies actor 'Salman Khan' appeared in the last 10 years
select *
from netflixtb
where casts like '%Salman Khan%' 
and release_year > extract(year from current_date)-10

--14.Find the top 10 actors who have appeared in the highest number of movie produced in india

select count(type),unnest(string_to_array(casts, ',')) as actors
from netflixtb
where country like '%India' and type='Movie' 
group by actors
order by count(type) desc
limit 10

--15. Categorise the content based on the presence of the keywords 'kill' and 'voilence' in the 
--description field.Label content containing these keywords as 'bad' and all other keyword as 'good'.
-- Count how many items fall into each category.

with cte as(select *,
case when description ilike '%kill%' or description ilike '%violence%' then 'Bad' else 'Good' end as label
from netflixtb)
select label,count (*)
from cte 
group by label

















