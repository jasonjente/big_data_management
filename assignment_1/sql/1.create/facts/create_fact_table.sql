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
	player_club_id INT,
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
    minutes_played,
	player_club_id
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
    gd.minutes_played,
	gd.player_club_id
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


	select * from  GAME_STATS