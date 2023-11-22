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

CREATE TABLE DIM_GAME (
	game_id INT PRIMARY KEY,
	winner int
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


INSERT INTO DIM_GAME (game_id, winner)
SELECT DISTINCT game_id, winner FROM GAME_DATA;