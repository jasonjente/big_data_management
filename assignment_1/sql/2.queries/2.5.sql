/* 2.5 */
/* Unfortunately on my initial design of the dimension I didn't take into consideration the need for the Year and Month.
As a result, I adjusted the dimension DIM_DATE by adding the months and year along with the date.
*/
ALTER TABLE DIM_DATE
ADD year AS YEAR(game_date),
    month AS MONTH(game_date);


-- verify that the table is okay and the new columns are filled in.

select * from DIM_DATE;

/* This script will aggregate the data in a cube format*/

SELECT
    cl.club_name AS 'Team',
    d.year AS 'Year',
    d.month AS 'Month',
    SUM(gs.goals) AS 'Total Goals'
FROM
    GAME_STATS gs
JOIN
    DIM_DATE d ON gs.date_key = d.date_key
JOIN
    DIM_COMPETITION c ON gs.competition_key = c.competition_id
JOIN
    DIM_CLUB cl ON gs.player_club_id = cl.club_id
WHERE
    c.competition_name = 'premier-league'
GROUP BY CUBE(
    cl.club_name,
    d.year,
    d.month)
ORDER BY
    cl.club_name, d.year, d.month;