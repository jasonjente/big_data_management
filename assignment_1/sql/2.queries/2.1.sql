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
