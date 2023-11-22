/* 2.3 */
/* This SQL script will return the aggregated total wins for the home clubs, the away clubs and draws.
The results are grouped and ordered by the competition name.
*/

SELECT
    c.competition_name AS 'League Name',
    COUNT(DISTINCT CASE WHEN gs.winner = 1 THEN gs.game_id END) AS 'Home Team Wins',
    COUNT(DISTINCT CASE WHEN gs.winner = 2 THEN gs.game_id END) AS 'Away Team Wins',
    COUNT(DISTINCT CASE WHEN gs.winner = 0 THEN gs.game_id END) AS 'Draws'
FROM
    GAME_STATS gs
JOIN
    DIM_COMPETITION c ON gs.competition_key = c.competition_id
GROUP BY
    c.competition_name
ORDER BY
    c.competition_name;

	-- verification SELECT COUNT(distinct gs.game_id) from GAME_STATS gs where gs.competition_key = 'GR1'; 