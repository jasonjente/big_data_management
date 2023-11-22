/* 2.2 */
/* This SQL script will return the aggregated total goals, yellow and red cards for all matches in 
each league. The results are grouped by the league name and the team name. Furthermore, I used the
sum of both away and home team to incorporate for a club being on either side and I used JOIN to with 
an OR clause ensuring that we get team names for both home and away clubs. 
*/

SELECT
    c.competition_name AS 'League Name',
    cl.club_name AS 'Team Name',
    SUM(gs.goals) AS 'Total Goals',
    SUM(gs.yellow_cards) AS 'Total Yellow Cards',
    SUM(gs.red_cards) AS 'Total Red Cards'
FROM
    GAME_STATS gs
JOIN
    DIM_COMPETITION c ON gs.competition_key = c.competition_id
JOIN
    DIM_CLUB cl ON gs.player_club_id = cl.club_id
GROUP BY
    c.competition_name, cl.club_name
ORDER BY
    c.competition_name, cl.club_name;