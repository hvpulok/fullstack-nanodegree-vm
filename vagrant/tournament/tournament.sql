-- code to create a tournament database
DROP DATABASE IF EXISTS tournament;

CREATE DATABASE tournament;
\c tournament;

-- create players table
CREATE TABLE players(                                                                                                                             
        playerid SERIAL PRIMARY KEY NOT NULL,                                                                                                             
        name TEXT NOT NULL);

-- create matches table
CREATE TABLE matches(                                                                                                                             
        matchID SERIAL PRIMARY KEY NOT NULL,                                                                                                             
        winner INT NOT NULL REFERENCES players(playerid),
        loser INT NOT NULL REFERENCES players(playerid));

-- -- sample players data
-- -- ==========================

-- INSERT INTO players (name) VALUES('Pulok');
-- INSERT INTO players (name) VALUES('Anika');
-- INSERT INTO players (name) VALUES('Akib');
-- INSERT INTO players (name) VALUES('Rajib');
-- INSERT INTO players (name) VALUES('Tony');
-- INSERT INTO players (name) VALUES('Mike');
-- INSERT INTO players (name) VALUES('Sara');
-- INSERT INTO players (name) VALUES('Jeny');


-- -- sample matches data
-- -- ==========================

-- INSERT INTO matches (winner, loser) VALUES(1, 2);
-- INSERT INTO matches (winner, loser) VALUES(3, 4);
-- INSERT INTO matches (winner, loser) VALUES(5, 6);
-- INSERT INTO matches (winner, loser) VALUES(7, 8);

-- -- 2nd round

-- INSERT INTO matches (winner, loser) VALUES(1, 3);
-- INSERT INTO matches (winner, loser) VALUES(5, 7);
-- INSERT INTO matches (winner, loser) VALUES(2, 4);
-- INSERT INTO matches (winner, loser) VALUES(6, 8);


-- SELECT * FROM players;
-- SELECT * FROM matches;

-- DELETE FROM players;
-- DELETE FROM matches;

    -- """Returns a list of the players and their win records, sorted by wins.

    -- The first entry in the list should be the player in first place, or a player
    -- tied for first place if there is currently a tie.

    -- Returns:
    --   A list of tuples, each of which contains (id, name, wins, matches):
    --     id: the player's unique id (assigned by the database)
    --     name: the player's full name (as registered)
    --     wins: the number of matches the player has won
    --     matches: the number of matches the player has played
    -- """
-- Code to get winner players id name and times won

-- SELECT * FROM players;
-- SELECT * FROM matches;


CREATE VIEW winnerTable AS 
    SELECT players.playerid, players.name, COUNT(players.playerid) AS number 
    FROM players, matches 
    WHERE players.playerid = matches.winner
    GROUP BY players.playerid, players.name 
    ORDER BY number DESC;

-- SELECT * FROM winnerTable;

-- Code to get loser players id name and times lost
CREATE VIEW loserTable AS 
    SELECT players.playerid, players.name, COUNT(players.playerid) AS number 
    FROM players, matches 
    WHERE players.playerid = matches.loser 
    GROUP BY players.playerid, players.name 
    ORDER BY number DESC;

-- SELECT * FROM loserTable;

-- Code to get total number of matches
-- combining winnerTable and loserTable
CREATE VIEW total_match_table AS 
    SELECT playerid, name, sum(number) AS total_matches 
    FROM (SELECT playerid, name, number FROM winnerTable 
            UNION ALL 
            SELECT playerid, name, number FROM loserTable) AS players
        GROUP BY playerid, name
        ORDER BY playerid;

-- SELECT * FROM total_match_table;

-- final code to get playerID | name | Win Count | Total Match count
-- by combining total_match_table and winnerTable

CREATE VIEW summury_table AS 
    SELECT total_match_table.playerid, total_match_table.name, total_match_table.total_matches, winnerTable.number AS win_count
        FROM total_match_table
        LEFT JOIN winnerTable
        ON total_match_table.playerid = winnerTable.playerid;


CREATE VIEW player_standings AS 
    SELECT players.playerid, players.name,
        CASE summury_table.win_count WHEN summury_table.win_count THEN summury_table.win_count
            ELSE 0
            END AS win_count,    
        CASE summury_table.total_matches WHEN summury_table.total_matches THEN summury_table.total_matches
            ELSE 0
            END AS total_matches
        FROM players
        LEFT JOIN summury_table
        ON players.playerid = summury_table.playerid;

-- code to create a player group based on their standings: odd number standings    
CREATE VIEW player_group_odd AS 
    SELECT ROW_NUMBER() OVER(ORDER BY win_count DESC) AS serial_no, id1, name1, win_count, standings FROM( 
    SELECT playerid AS id1, name as name1, win_count, ROW_NUMBER() OVER(ORDER BY win_count DESC) AS standings 
    FROM player_standings
    ) d where (standings % 2) = 1;

-- code to create a player group based on their standings: Even number standings    
CREATE VIEW player_group_even AS 
    SELECT ROW_NUMBER() OVER(ORDER BY win_count DESC) AS serial_no, id2, name2, win_count, standings FROM( 
    SELECT playerid AS id2, name as name2, win_count, ROW_NUMBER() OVER(ORDER BY win_count DESC) AS standings 
    FROM player_standings
    ) d where (standings % 2) = 0;

-- code to create pairs combining odd group and even group
CREATE VIEW swiss_pairs AS
    SELECT player_group_odd.id1, player_group_odd.name1, player_group_even.id2, player_group_even.name2
        FROM player_group_odd, player_group_even
        WHERE player_group_odd.serial_no = player_group_even.serial_no;


SELECT * FROM player_standings;
SELECT * FROM player_group_odd;
SELECT * FROM player_group_even;

-- code to retrieve swiss pairs
SELECT * FROM swiss_pairs;

-- DROP VIEW IF EXISTS swiss_pairs;
-- DROP VIEW IF EXISTS player_group_even;
-- DROP VIEW IF EXISTS player_group_odd;
-- DROP VIEW IF EXISTS player_standings;
-- DROP VIEW IF EXISTS summury_table;
-- DROP VIEW IF EXISTS total_match_table;
-- DROP VIEW IF EXISTS winnerTable;
-- DROP VIEW IF EXISTS loserTable;