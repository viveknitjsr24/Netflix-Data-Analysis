DROP TABLE IF EXISTS NETFLIX;

CREATE TABLE NETFLIX
(
SHOW_ID VARCHAR(7),
TYPE VARCHAR(10),
TITLE VARCHAR(150),
DIRECTOR VARCHAR(210),
CASTS VARCHAR(800),
COUNTRY VARCHAR(150),
DATE_ADDED VARCHAR(50),
RELEASE_YEAR INT, RATING VARCHAR(10),
DURATION VARCHAR(15),
LISTED_IN VARCHAR(100),
DESCRIPTION VARCHAR(250)
);

SELECT * FROM NETFLIX;

-- Questions to extract key insights

--1. To count the number of Movies vs TV Shows
    
SELECT TYPE,
	COUNT(*)
FROM NETFLIX
GROUP BY TYPE;


--2.To find the most common rating for movies and TV shows

SELECT TYPE,
	RATING
FROM
	(SELECT TYPE,RATING,COUNT(*),
		RANK()OVER(PARTITION BY TYPE ORDER BY COUNT(*) DESC) AS RANKING
		FROM NETFLIX
		GROUP BY TYPE,RATING) AS X
WHERE RANKING = 1;


--3. To list all movies released in a specific year (e.g., 2020)

SELECT * from netflix where type='Movie' and release_year= '2020';

--4. To find the top 5 countries with the most content on Netflix

select unnest(STRING_TO_ARRAY(country,', ')) as new_country, 
count(show_id) as contents from netflix 
where country!='null' 
group by new_country 
order by contents desc limit 5;

--5. Identify the longest movie

SELECT * FROM NETFLIX WHERE type = 'Movie' 
AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) =
    (SELECT MAX(CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER))
FROM netflix WHERE TYPE='Movie');


--6. Find content added in the last 5 years

select * from netflix
WHERE TO_DATE(date_added,'Month FMDD,YYYY')>= CURRENT_DATE - INTERVAL '5 Years';

--7. To list all TV shows with more than 5 seasons

select * from netflix where type='TV Show' 
and cast(split_part(duration,' ',1) as INTEGER) >5;

--8. To count the number of content items in each genre

select unnest(STRING_TO_ARRAY(listed_in,', ')) as genre,
count(show_id) as contents 
from netflix group by genre;


--9. To find content added by India as a percentage of total content added in a particular year. 
--  and arrange the top 5 years with highest percentage contribution.

EXTRACT(Year From (TO_DATE(date_added,'Month FMDD,YYYY')))as Year,
	count(*) as content_added,
	ROUND(
		COUNT(show_id)::numeric/(SELECT COUNT(show_id) FROM netflix WHERE country ILIKE '%India%')::numeric * 100 
		,2)
		as percent_release
FROM netflix
WHERE country ILIKE '%India%' 
GROUP BY Year
Order by percent_release desc limit 5;


--10.  To list all movies that are documentaries

select * from netflix where listed_in ILIKE '%Documentaries%' and type='Movie';


--11. To find the top 10 actors who have appeared in the highest number of movies produced in India.

select unnest(STRING_TO_ARRAY(casts,', ')) as actor, 
count(show_id) as contents 
from netflix where country ILIKE '%India%' 
group by actor 
order by contents desc limit 10;


--12.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' 
--and all other content as 'Good'. Count how many items fall into each category.

select category,type, count(*) as contents from
(
	Select * ,
case	
 when description ILIKE '%kill%' or description ILIKE '%VIOLENCE%' THEN 'Bad'
 else 'Good'
End as category
	from netflix
) as category
group by 1, 2
order by 3 desc;


