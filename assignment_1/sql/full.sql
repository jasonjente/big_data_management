/* This snippet is responsible for the creation of the data warehouse database.*/
drop database if exists footballDW;
go
create database footballDW;
go
use footballDW
go

/* This snippet is responsible for the creation of the staging table that will hold the data from the dataset.*/
CREATE TABLE GAME_DATA (
    game_id INT,
    game_date DATE,
    home_club_id INT,
    home_club_name VARCHAR(100),
    home_club_goals INT,
    away_club_id INT,
    away_club_name VARCHAR(100),
    away_club_goals INT,
    winner INT,
    competition_id VARCHAR(10),
    competition_name VARCHAR(100),
    country_name VARCHAR(100),
    player_club_id INT,
    player_id INT,
    player_name VARCHAR(100),
    yellow_cards INT,
    red_cards INT,
    goals INT,
    assists INT,
    minutes_played INT,
    date_of_birth DATE,
    position VARCHAR(50)
);

/* This snippet is responsible for the bulk insert of data from the dataset to the GAME_DATA table.*/
BULK INSERT GAME_DATA
FROM 'C:\projects\Mathimata\metaptyxiako\Συστήματα Ανάλυσης & Διαχείρισης Μεγάλων Δεδομένων\assignments\assignment_1\sql\data\footballData.txt'
WITH (FIRSTROW = 2, FIELDTERMINATOR = '|', ROWTERMINATOR = '\n');

/* This snippet is responsible for the creation of date dimension.*/
CREATE TABLE DIM_DATE (
    date_key INT PRIMARY KEY IDENTITY(1,1),
    game_date DATE
);

/* This snippet is responsible for the creation of Club dimension.*/
CREATE TABLE DIM_CLUB (
    club_id INT PRIMARY KEY,
    club_name VARCHAR(100)
);

/* This snippet is responsible for the creation of Player dimension.*/
CREATE TABLE DIM_PLAYER (
    player_id INT PRIMARY KEY,
    player_name VARCHAR(100),
    date_of_birth DATE,
    position VARCHAR(50)
);

/* This snippet is responsible for the creation of Competition dimension.*/
CREATE TABLE DIM_COMPETITION (
    competition_id VARCHAR(10) PRIMARY KEY,
    competition_name VARCHAR(100),
    country_name VARCHAR(100)
);

/* This snippet is responsible for the insertion of the game dates into the date dimension from the GAME_DATA table.*/
INSERT INTO DIM_DATE (game_date)
SELECT DISTINCT game_date FROM GAME_DATA;

/* This snippet is responsible for the insertion of the clubs from the GAME_DATA table to the club dimension. 
It accounts for the fact that a club can be either the home club or the away club which is why I select the 
distinct identifiers and names from either side and then doing a union on the returned sets.
*/
INSERT INTO DIM_CLUB (club_id, club_name)
SELECT DISTINCT home_club_id, home_club_name FROM GAME_DATA
UNION
SELECT DISTINCT away_club_id, away_club_name FROM GAME_DATA;

/* This snippet is responsible for the insertion of the players from the GAME_DATA table into the player dimension. 
It accounts for the fact that multiple players might appear in multiple rows.
*/
INSERT INTO DIM_PLAYER (player_id, player_name, date_of_birth, position)
SELECT DISTINCT player_id, player_name, date_of_birth, position FROM GAME_DATA;

/* This snippet is responsible for the insertion of the competitions from the GAME_DATA table into the competition dimension. 
It accounts for the fact that multiple competitions might appear in multiple rows.
*/
INSERT INTO DIM_COMPETITION (competition_id, competition_name, country_name)
SELECT DISTINCT competition_id, competition_name, country_name FROM GAME_DATA;


/* This snippet is responsible for the creation of the fact table GAME_STATS. */
CREATE TABLE GAME_STATS (
    fact_id INT PRIMARY KEY IDENTITY(1,1),
    game_id INT,
    date_key INT,
    home_club_key INT,
    away_club_key INT,
    home_club_goals INT,
    away_club_goals INT,
    winner INT,
    competition_key VARCHAR(10),
    player_key INT,
    yellow_cards INT,
    red_cards INT,
    goals INT,
    assists INT,
    minutes_played INT,
    FOREIGN KEY (date_key) REFERENCES DIM_DATE(date_key),
    FOREIGN KEY (home_club_key) REFERENCES DIM_CLUB(club_id),
    FOREIGN KEY (away_club_key) REFERENCES DIM_CLUB(club_id),
    FOREIGN KEY (competition_key) REFERENCES DIM_COMPETITION(competition_id),
    FOREIGN KEY (player_key) REFERENCES DIM_PLAYER(player_id)
);


/* This snippet is responsible for the instantiation of the fact table.
The use of JOIN is essential to map the descriptive data from the GAME_DATA table to the appropriate keys in the dimension tables.

I used JOIN with DIM_DATE in order to get the date_key that corresponds to the actual game date. Same applies for the player and competition dimension.
I used JOIN with both home and away club in order to ensure that I retrieve the correct club keys.

*/
INSERT INTO GAME_STATS (
    game_id,
    date_key,
    home_club_key,
    away_club_key,
    home_club_goals,
    away_club_goals,
    winner,
    competition_key,
    player_key,
    yellow_cards,
    red_cards,
    goals,
    assists,
    minutes_played
) SELECT 
    gd.game_id, 
    d.date_key, 
    hc.club_id AS home_club_key, 
    ac.club_id AS away_club_key, 
    gd.home_club_goals, 
    gd.away_club_goals, 
    gd.winner, 
    c.competition_id AS competition_key, 
    p.player_id AS player_key, 
    gd.yellow_cards, 
    gd.red_cards, 
    gd.goals, 
    gd.assists, 
    gd.minutes_played
FROM 
    GAME_DATA gd
JOIN 
    DIM_DATE d ON gd.game_date = d.game_date
JOIN 
    DIM_CLUB hc ON gd.home_club_id = hc.club_id
JOIN 
    DIM_CLUB ac ON gd.away_club_id = ac.club_id
JOIN 
    DIM_COMPETITION c ON gd.competition_id = c.competition_id
JOIN 
    DIM_PLAYER p ON gd.player_id = p.player_id;

/* 2.1 */
/* This SQL script returns the results of all matches in the Greek League - super-league-1 using inner join clauses*/

SELECT 
    d.game_date, 
    hc.club_name AS Home_Team, 
    ac.club_name AS Away_Team, 
    gs.home_club_goals, 
    gs.away_club_goals
FROM 
    GAME_STATS gs
INNER JOIN 
    DIM_DATE d ON gs.date_key = d.date_key
INNER JOIN 
    DIM_CLUB hc ON gs.home_club_key = hc.club_id
INNER JOIN 
    DIM_CLUB ac ON gs.away_club_key = ac.club_id
INNER JOIN 
    DIM_COMPETITION c ON gs.competition_key = c.competition_id
WHERE 
	c.competition_name  = 'super-league-1'
ORDER BY 
    d.game_date ASC;

-- equivalent SQL script but with where clauses for the join as discussed in the lectures.

/*
SELECT 
    d.game_date, 
    hc.club_name AS Home_Team, 
    ac.club_name AS Away_Team, 
    gs.home_club_goals, 
    gs.away_club_goals
FROM 
    GAME_STATS gs,
	DIM_DATE d,
	DIM_COMPETITION c,
	DIM_CLUB hc,
	DIM_CLUB ac
WHERE 
    gs.date_key = d.date_key AND
    gs.home_club_key = hc.club_id AND
    gs.away_club_key = ac.club_id AND
    gs.competition_key = c.competition_id AND 
    c.competition_name  = 'super-league-1'
ORDER BY 
    d.game_date ASC;
	
*/

/* 2.2 */
/* This SQL script will return the aggregated total goals, yellow and red cards for all matches in 
each league. The results are grouped by the league name and the team name. Furthermore, I used the
sum of both away and home team to incorporate for a club being on either side and I used JOIN to with 
an OR clause ensuring that we get team names for both home and away clubs. 
*/

SELECT
    c.competition_name AS 'League Name',
    cl.club_name AS 'Team Name',
    SUM(gs.home_club_goals) + SUM(gs.away_club_goals) AS 'Total Goals',
    SUM(gs.yellow_cards) AS 'Total Yellow Cards',
    SUM(gs.red_cards) AS 'Total Red Cards'
FROM
    GAME_STATS gs
JOIN
    DIM_COMPETITION c ON gs.competition_key = c.competition_id
JOIN
    DIM_CLUB cl ON gs.home_club_key = cl.club_id OR gs.away_club_key = cl.club_id
GROUP BY
    c.competition_name, cl.club_name
ORDER BY
    c.competition_name, cl.club_name;

	
/* 2.3 */
/* This SQL script will return the aggregated total wins for the home clubs, the away clubs and draws.
The results are grouped and ordered by the competition name.
*/

SELECT
    c.competition_name AS 'League Name',
    COUNT(CASE WHEN gs.winner = 1 THEN 1 END) AS 'Home Team Wins',
    COUNT(CASE WHEN gs.winner = 2 THEN 1 END) AS 'Away Team Wins',
    COUNT(CASE WHEN gs.winner = 0 THEN 1 END) AS 'Draws'
FROM
    GAME_STATS gs
JOIN
    DIM_COMPETITION c ON gs.competition_key = c.competition_id
GROUP BY
    c.competition_name
ORDER BY
    c.competition_name;

/* 2.4 */
/* This SQL script will create a View called TOP_SCORRERS_GR.
TOP_SCORRERS_GR will create a Common Table Expression called GOAL_SCORRERS.
This Common Table Expression aggregates the total goals scored by each player for each club.
The GOAL_SCORRERS performs JOINs on the GAME_STATS with the dimensions DIM_COMPETITION, DIM_CLUB
 and DIM_PLAYER, filtering for matches in the 'super-league-1' competition.
The SUM function calculates the total number of goals scored by each player.
The RANK function is applied over this sum, partitioned by club name. This ranks players within each
 club based on their total goals.
 
 */
 
CREATE VIEW TOP_SCORRERS_GR AS
	WITH GOAL_SCORRERS AS (
		SELECT
			p.player_name,
			cl.club_name,
			SUM(gs.goals) AS Total_Goals,
			RANK() OVER (PARTITION BY cl.club_name ORDER BY SUM(gs.goals) DESC) AS Rank
		FROM
			GAME_STATS gs
		JOIN
			DIM_COMPETITION c ON gs.competition_key = c.competition_id and
			c.competition_name = 'super-league-1'
		JOIN 
			DIM_CLUB cl ON gs.home_club_key = cl.club_id OR gs.away_club_key = cl.club_id
		JOIN 
			DIM_PLAYER p ON gs.player_key = p.player_id
		GROUP BY
			p.player_name, cl.club_name
	)
	SELECT
		g.club_name AS 'Team Name',
		g.player_name AS 'Top Scorer',
		g.Total_Goals
	FROM
		GOAL_SCORRERS g
	WHERE
		g.Rank = 1;


SELECT *
FROM 
	TOP_SCORRERS_GR
ORDER BY 
	Total_Goals DESC;

/* 2.5 */
/* Unfortunately on my initial design of the dimension I didn't wasn't taking into consideration the need for the Year and Month.
As a result, I adjusted the dimension DIM_DATE incorporating the months and year along with the date.
*/

ALTER TABLE DIM_DATE
ADD year AS YEAR(game_date),
    month AS MONTH(game_date);

-- verify that the table is okay and the new columns are filled in.

select * from DIM_DATE;

/* This script will aggregate the data in a cube format*/

SELECT
    c.competition_name AS 'League',
    cl.club_name AS 'Team',
    d.year AS 'Year',
    d.month AS 'Month',
    SUM(gs.home_club_goals + gs.away_club_goals) AS 'Total Goals'
FROM
    GAME_STATS gs
INNER JOIN
    DIM_DATE d ON gs.date_key = d.date_key
INNER JOIN
    DIM_COMPETITION c ON gs.competition_key = c.competition_id
INNER JOIN
    DIM_CLUB cl ON gs.home_club_key = cl.club_id OR gs.away_club_key = cl.club_id
WHERE
    c.competition_name = 'premier-league'
GROUP BY CUBE(
    c.competition_name,
    cl.club_name,
    d.year,
    d.month)
ORDER BY
    c.competition_name, cl.club_name, d.year, d.month;
