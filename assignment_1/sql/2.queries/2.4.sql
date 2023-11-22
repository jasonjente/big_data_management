/* 2.4 */
/* This SQL script will create a View called TOP_SCORRERS_GR.
TOP_SCORRERS_GR will create a Common Table Expression called GOAL_SCORRERS.
This Common Table Expression aggregates the total goals scored by each player for each club.
The GOAL_SCORRERS performs JOINs on the GAME_STATS with the dimensions DIM_COMPETITION, DIM_CLUB
 and DIM_PLAYER, filtering for matches in the 'super-league-1' competition.
The SUM function calculates the total number of goals scored by each player.
The RANK function is applied over this sum, partitioned by club name. This ranks players within each
 club based on their total goals.
 
 The ciew selects the club name
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
			DIM_CLUB cl ON gs.player_club_id = cl.club_id
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
	