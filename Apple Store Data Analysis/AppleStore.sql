/*
In this project, we explore the apps available on the Apple Store to provide data-driven insights for a stakeholder—an aspiring app developer. The goal is to help them make informed decisions, addressing questions such as:

What app categories are the most popular?
What price should be set?
How can user ratings be maximized?

We will first explore the data, discovering insights, and then make final decisions based on our findings.
*/

-- Combine all tables
CREATE TABLE appleStore_description_combined AS
    SELECT * FROM appleStore_description1
    UNION ALL 
    SELECT * FROM appleStore_description2
    UNION ALL 
    SELECT * FROM appleStore_description3
    UNION ALL 
    SELECT * FROM appleStore_description4;
    
    

**EXPLORATORY DATA ANALYSIS**

-- Check if the number of unique apps is matching in both tables

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore;
-- 7,197 App IDs

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined;
-- 7,197 App IDs



-- Check for any missing values in key fields in both tables.

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS NULL OR user_rating IS NULL OR prime_genre IS NULL;
-- 0 missing values

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc IS NULL;
-- 0 missing values



-- Find out the number of apps per genre and identify dominant genres

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC;
-- Games and Entertainment are the dominant genres.



-- Get an overview of the apps' ratings

SELECT 
    MIN(user_rating) AS MinRating,
    MAX(user_rating) AS MaxRating,
    AVG(user_rating) AS AvgRating
FROM AppleStore;
-- Minimum rating is 0, maximum rating is 5, and the average rating is around 3.5.



**DATA ANALYSIS**

-- Determine whether paid apps have higher ratings than free apps

SELECT 
    CASE WHEN price > 0 THEN 'Paid' ELSE 'Free' END AS App_Type,
    AVG(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type;
-- The average rating of free apps is around 3.38, and the average rating of paid apps is around 3.72.



-- Check if apps with more supported languages have higher ratings

SELECT 
    CASE
        WHEN lang_num < 10 THEN '<10 languages'
        WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
        ELSE '>30 languages'
    END AS language_bucket,
    AVG(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC;
-- Apps that support 10-30 languages have the highest average ratings.



-- Check genres with low ratings

SELECT 
    prime_genre,
    AVG(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10;
-- Genres with the lowest average ratings: Catalogs, Finance, and Book.



-- Check if there is a correlation between the length of the app description and the user rating

SELECT 
    CASE
        WHEN LENGTH(b.app_desc) < 500 THEN 'Short'
        WHEN LENGTH(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Long'
    END AS description_length_bucket,
    AVG(a.user_rating) AS average_rating
FROM AppleStore AS a
JOIN appleStore_description_combined AS b ON a.id = b.id
GROUP BY description_length_bucket
ORDER BY average_rating DESC;
-- Apps with long descriptions have an average rating of 3.86, medium description apps have 3.23, and short description apps have 2.53.



-- Check the top-rated apps for each genre for stakeholders to consider emulating.

SELECT 
    prime_genre,
    track_name,
    user_rating
FROM (
    SELECT 
        prime_genre,
        track_name,
        user_rating,
        RANK() OVER (PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
    FROM AppleStore
) AS a
WHERE a.rank = 1;



**INSIGHTS & RECOMMENDATIONS**

-- 1.Paid apps generally have better ratings: Consider charging certain amounts for apps that offer good quality.
-- 2.Apps supporting between 10 and 30 languages tend to have better ratings: Focus on the right languages.
-- 3.Finance and book apps have lower ratings on average: User needs are not fully met in these categories. This represents a market opportunity to create better apps that address user needs more effectively than the current offerings. There is potential for higher user ratings and market penetration.
-- 4.Apps with longer descriptions tend to have better ratings. Users tend to have a clear understanding of the app's features and capabilities before they download. A detailed, well-crafted app description can set clear expectations and eventually increase user satisfaction.
-- 5.The average rating of all apps is 3.5; therefore, aim for a rating higher than 3.5 on average.
-- 6.Games and entertainment genres have high competition. The market in these categories may be saturated. Developing apps in these markets may be challenging due to high competition.







