-- Football Match exercise
 
/*
The FootballMatch table shows the EPL matches played in 2024/25 season as of 16th March 2025
 
Important Columns
Date - Match Date (dd/mm/yy)
Time - Time of match kick off
HomeTeam- Home Team
AwayTeam - Away Team
FTHG -Full Time Home Team Goals
FTAG - Full Time Away Team Goals
FTR - Full Time Result (H=Home Win, D=Draw, A=Away Win)
 
Full details at https://zomalex.co.uk/datasets/football_match_dataset.html
*/
 
SELECT
    fm.Date
    , fm.HomeTeam
    , fm.AwayTeam
    , fm.FTHG
    , fm.FTAG
    , fm.FTR
FROM
    FootballMatch fm ;
 
/*
How many games have been played?.  
- In total
- By each team
- By month
*/
 
-- In total
SELECT
    count(*) AS NumberOfMatches
FROM
    FootballMatch fm ;

-- by team
--(1) -- sub query
SELECT 
     team,
     COUNT (*) AS gamesplayed
FROM
    (
    SELECT Hometeam AS team FROM FootballMatch fm
    UNION all
    SELECT AWAYTEAM AS team FROM FootballMatch fm 
    ) AS all_teams
GROUP BY team
order by gamesplayed desc ;

--(2) -- using CTE
with cte as (
SELECT Hometeam as team, 
    count(*) AS games 
    FROM FootballMatch fm
    group by HomeTeam

UNION all

SELECT AWAYTEAM as team,
    count(*) AS games 
    FROM FootballMatch fm 
    group by AwayTeam
) 
select team, sum(games) from cte
group by team ;





-- By Month

SELECT
    month(Date) AS month_date
    ,count(*) AS NumberOfGames
FROM
    FootballMatch fm
GROUP BY MONTH(Date)


-- get the month name use DATENAME() &  month number use DATENUMBER()
SELECT
    datename(year, Date) AS year_date 
    ,datename(month, Date) AS month_date   
    ,month(date) AS month_number
    ,count(*) AS NumberOfGames
FROM
    FootballMatch fm
GROUP BY  datename(year, Date), 
          datename(month, Date), 
          month(date)
ORDER by  datename(year, Date), month(date) ;


-- How many goals have been scored in total

-- (1) using subquery
SELECT
     sum(goals) as total_goals
FROM (
    select FTHG AS GOALS FROM FootballMatch fm
UNION ALL
    select FTAG AS GOALS FROM FootballMatch fm
) AS allgoals ;

--(2) using straight forward approach
SELECT SUM(FTHG) + SUM(FTAG) AS total_goals from FootballMatch ;



-- How many goals have been scored by each team?
--UNION --- Joins duplicates also
--UNION ALL - only takes in unique ns


--(1) USING SUBQUERY

SELECT
    team
    , sum(goals) as TotalGoals
FROM
    (
           SELECT
            HomeTeam AS team
            ,FTHG AS goals
        FROM
            FootballMatch fm
    UNION ALL
        SELECT
            AwayTeam AS team 
            ,FTAG AS goals
        FROM
            FootballMatch fm 
) AS Allgoals
GROUP BY team ;



--(2) USING CTE

with cte as (
SELECT
    Hometeam AS Team
    , sum(FTHG) AS total_goals
FROM
    FootballMatch
GROUP BY HomeTeam
UNION ALL
SELECT
    Awayteam AS Team 
    , sum(FTAG) AS total_goals
FROM
    FootballMatch
GROUP BY AwayTeam)
SELECT
    team
    ,sum(cte.total_goals)
FROM
    cte
GROUP BY Team;

--(3) TEMP TABLE

--(1)
DROP TABLE IF EXISTS #Leaguetable

SELECT
    count(*) AS Played 
    , Hometeam AS TEAM
    , sum(FTHG) AS GF
    , sum(FTAG) AS GA 
    , sum(CASE WHEN FTR = 'H' THEN 1 ELSE 0 END) AS WON
    , sum(CASE WHEN FTR = 'A' THEN 1 ELSE 0 END) AS LOST
INTO #Leaguetable  -- this is where you add the first query into temp table
FROM
    FootballMatch
GROUP BY HomeTeam
UNION ALL
SELECT
    count(*) as Played
    , Awayteam AS TEAM 
    , sum(FTAG) 
    , sum(FTHG)
    , sum(CASE WHEN FTR = 'A' THEN 1 ELSE 0 END) AS WON
    , sum (CASE WHEN FTR = 'H' THEN 1 ELSE 0 END) AS LOST
FROM
    FootballMatch 
GROUP BY AwayTeam ;

SELECT
     TEAM
    , sum(played) as PLAYED
    , sum(CASE WHEN FTR = 'A' THEN 1 ELSE 0 END) AS WON
    , sum (CASE WHEN FTR = 'H' THEN 1 ELSE 0 END) AS LOST
    , sum(WON) as WON
    , SUM(LOST) AS LOST
    , sum(GF) AS GOALS_FOR
    , SUM(GA) AS GOALS_AGAINST
   
FROM
    #Leaguetable
GROUP BY team
order by team;


-- (2)

DROP TABLE IF EXISTS #Leaguetable

SELECT
     Hometeam AS TEAM
    , CASE WHEN FTR = 'H' THEN 1 ELSE 0 END AS WON
    , CASE WHEN FTR = 'A' THEN 1 ELSE 0 END AS LOST
    , CASE WHEN FTR = 'D' THEN 1 ELSE 0 END AS DRAW
    , case when FTR ='H' THEN 3
          WHEN FTR = 'D' THEN 1 
                ELSE 0 
                END as points

    , FTHG AS GF
    , FTAG AS GA 
INTO #Leaguetable  -- this is where you add the first query into temp table
FROM
    FootballMatch

UNION ALL
SELECT
     Awayteam AS TEAM 
    , CASE WHEN FTR = 'A' THEN 1 ELSE 0 END AS WON
    , CASE WHEN FTR = 'H' THEN 1 ELSE 0 END AS LOST
    , CASE WHEN FTR = 'D' THEN 1 ELSE 0 END AS DRAW
    , case when FTR ='A' THEN 3
           WHEN FTR= 'D' THEN 1 
                ELSE 0 
                END as points
    , FTAG 
    , FTHG
FROM
    FootballMatch ;

--- view 
select * from #Leaguetable;
SELECT * FROM FootballMatch;

-- query view
SELECT
     TEAM
    , count(*) as PLAYED
    , sum(WON) AS WON
    , SUM(LOST) AS LOST
    , SUM(DRAW) AS DRAW
    , sum(GF) AS GOALS_FOR
    , SUM(GA) AS GOALS_AGAINST  
    , SUM(GA)- SUM(GF) AS GD
    , SUM(points) AS POINTS
FROM
    #Leaguetable
GROUP BY team
order by team;






