--SQL Spotify Project
--Create Table

Drop Table If Exists Spotify;
Create Table Spotify
(
	Artist varchar(255),
	Track varchar(255),
	Album varchar(255),
	Album_type varchar(50),
	Danceability float,
	Energy float,	
	Loudness float,	
	Speechiness float,	
	Acousticness float,	
	Instrumentalness float,	
	Liveness float,	
	Valence float,	
	Tempo float,	
	Duration_min float,
	Title varchar(255),
	Channel varchar(255),
	Views float,
	Likes bigint,
	Comments bigint,
	Licensed boolean,
	official_video boolean,
	Stream float,
	EnergyLiveness float,
	most_playedon varchar(50)
);
--change escape from single quote to double quote to import data
-- or replace single quote with space in excel

--EDA
Select * from Spotify;
Select count(*) from Spotify;
Select count(distinct album) from Spotify;
Select count(distinct artist) from Spotify;
Select distinct album_type from Spotify;
Select max(duration_min) from Spotify;
Select min(duration_min) from Spotify;

Select * from Spotify 
where duration_min = 0;

-- a song cannot have 0 duration so we hav to delete it
Delete from Spotify
where duration_min = 0;

Select distinct channel from Spotify;
Select distinct most_playedon from Spotify;

--Data Analysis easy category--
--Q1 Retrieve the names of all tracks that have more than 1 billion
--streams
Select track from Spotify
where stream > 1000000000;

--Q2 List all albums along with their respective artists 
Select distinct album, artist from Spotify
order by 1;

--Q3 Get the total number of comments for tracks where Licensed = TRUE
Select count(Comments) from Spotify
where Licensed = 'TRUE';

--Q4 Find all the tracks that belong to the album type single.
Select track,album_type from Spotify
where album_type = 'single';

--Q5 Count the total number of tracks by each artist.
Select artist,count(track) from Spotify
group by artist
order by 2 DESC;

--Medium category
--Q6 Find the average danceability of tracks in each album.
Select album,
avg(danceability) as avg_dance
from Spotify
group by 1
order by 2 DESC;

--Q7 Find the top 5 tracks with the highest energy values.
Select distinct track,max(energy) from Spotify
group by 1
order by 2 DESC
Limit 5;

--Q8 List all the tracks with their views and likes where official_video
-- = true
Select track,
sum(views) as tot_views,sum(likes) as tot_likes
from Spotify
where official_video= 'True'
group by 1
order by 2 DESC;

--Q9 For each album calculate the total views of all associated tracks.
Select album,track,sum(views) as tot_views
from Spotify
group by 1,2
order by 1;

--Q10 Retrieve the track names that have been streamed more on Spotify
-- than on youtube.
with t1 as
(Select track,
--most_playedon, 
Coalesce(SUM(CASE when most_playedon = 'Youtube' then stream End),0) as Streamed_on_yt,
Coalesce(SUM(CASE when most_playedon = 'Spotify' then stream End),0) as Streamed_on_st
From Spotify
Group by 1)

Select track,streamed_on_yt,streamed_on_st from t1
where streamed_on_yt <  streamed_on_st
and streamed_on_yt <> 0;

--Advanced level Questions--
--Q11 Find the top 3 most viewed tracks for each artist.
With t2 as
(
Select artist,track,sum(views) as sum_views,
dense_rank() over(partition by artist order by sum(views) DESC) as ranking
from Spotify
Group by artist,track
)
Select * from t2
where ranking <= 3;
--Order by 3 DESC--;
-- Two different tracks can have same number of views.

With t1 as
(
Select type,rating,count(*),
rank() over(partition by type order by count(*) DESC) as ranking
--max(rating) as no max is possible in text 
from Netflix
group by type,rating
)
--order by 1,3 desc
Select type,rating,ranking from t1
 where ranking =1;
 

--Q12 Write a query to find tracks where the liveness score is above
--the average.
Select track,artist,liveness from Spotify
where liveness > (Select avg(liveness) from Spotify);
--Select avg(liveness) from Spotify

--Q13 Use a WITH clause to calculate the difference between the highest
--and the lowest energy values for tracks in each album.
With t3 as
(
Select album,
Max(energy) as highest_energy,
Min(energy) as lowest_energy
from Spotify
Group by 1
)
Select album,
highest_energy-lowest_energy as energy_diff
from t3
order by 2 DESC;

--Q14 Find the tracks where energy to liveness ratio is greater than
1.2.


SELECT track, energy / liveness as ratio
FROM Spotify
WHERE liveness>0 --this is to correct error division by 0
and energy / liveness > 1.2;

--Q15 Calculate the cumulative sum of likes for tracks ordered by the number of 
--views ,using window function.
Select track,likes,views,
sum(likes) over(order by views DESC) as cum_sum
from Spotify;

