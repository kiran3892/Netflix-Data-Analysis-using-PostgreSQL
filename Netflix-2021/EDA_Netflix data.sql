-- Exploratory Data analysis of Netflix table

-- 1. Counting the total available content
	select count(distinct show_id) as Available_content
	from netflix;

-- 2. Counting different types of contents
	select
		type,
		count(*)
	from netflix
	group by 1;

-- 3. Find the Most Common Rating for Movies and TV Shows

with ratingcount as(
	select 
		type,
		rating,
		count(*) as ratingcount
	from netflix
	group by 1,2
),
ratingcount_ranking as (
	select
		type,
		rating,
		ratingcount,
		rank() over (partition by type order by ratingcount desc) as ranking
	from ratingcount
)
select * 
from ratingcount_ranking
where ranking = 1;


-- List All Movies Released in a Specific Year (e.g., 2019)

	select * from netflix
	where release_year = 2019;


-- Find the Top 5 Countries with the Most Content on Netflix
	select
		unnest(string_to_array(country,',')) as countries,
		count(*) as content_per_country
	from netflix
	group by 1
	order by 2 desc;

-- Identify the Longest Movie

	select 
		type,
		title,
		release_year,
		coalesce(split_part(duration,' ',1)::int,0) as runtime
	from netflix
	where type = 'Movie'
	order by 4 desc;


-- Find Content Added in the Last 5 Years

	select
		type,
		title,
		date_added
	from netflix
	where date_added >= date_added - interval '5 years';


-- Find All Movies/TV Shows by Director 'Rajiv Chilaka'

	select
		type,
		title,
		director
	from netflix
	where director = 'Rajiv Chilaka';

-- List All TV Shows with More Than 5 Seasons

with seasons as(
	select
		type,
		title,
		split_part(duration,' ',1)::int as seasons
	from netflix
	where type = 'TV Show'
	order by 3 desc
	)
	select 
		type,
		title,
		seasons
	from seasons
	where seasons > 5;


-- Count the Number of Content Items in Each Genre

	select
		trim(unnest(string_to_array(listed_in,','))) as genre,
		count(*) as content_number
	from netflix
	group by genre
	order by 2 desc;

-- Find each year and the average numbers of content release in India on netflix.
--a. Each year total content
	select
		unnest(string_to_array(country,',')) as country,
		release_year,
		count(*) as content_per_year
	from netflix
	where country = 'India'
	group by 1,2
	order by 3 desc;

--a. Each year average of total content
	SELECT 
	    country,
	    release_year,
	    COUNT(*) AS total_content,
	    ROUND(COUNT(*)::numeric /
	        (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100, 2) AS avg_content_release
	FROM netflix
	WHERE country = 'India'
	GROUP BY 1, 2
	ORDER BY 4 DESC;


-- List All Movies that are Documentaries
--approach a
	with genre_list as (
		select
			type,
			title,
			trim(unnest(string_to_array(listed_in, ','))) as genre
		from netflix
		where type = 'Movie'
		order by 1
		)
		select
			type,
			title,
			genre
		from genre_list
		where genre = 'Documentaries';

-- approach B.
	select
		type,
		title,
		listed_in as genre
	from netflix
	where type='Movie' and listed_in like '%Documentaries';


-- Find All Content Without a Director
	select * from netflix
	where director is null;


-- Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
--appraoch a
	with casts as (
		select
			type,
			trim(unnest(string_to_array(casting,','))) as cast_name
		from netflix
		where type = 'Movie' and date_added >= date_added - interval '10 Years'
		)
		select
			type,
			cast_name,
			count(cast_name) as number_of_movies
		from casts
		where cast_name = 'Salman Khan'
		group by 1,2;

--appraoch b
	select count(*) from netflix
	where casting like '%Salman Khan%' and date_added >= date_added - interval '10 Years';


-- Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
	select
		trim(unnest(string_to_array(casting,','))) as cast_name,
		count(*)
	from netflix
	where type = 'Movie'
	group by 1
	order by 2 desc
	limit 10;


-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
	select
		category,
		count(*)
	from (select 
				case 
				when description ilike '%like%' or description ilike '%violence%' then 'Bad' 
				else 'Good' 
				end as category
				from netflix) as category_items
	group by 1;