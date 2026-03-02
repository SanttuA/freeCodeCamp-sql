#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#clear tables for testing
CLEAR_RESULT=$($PSQL "TRUNCATE TABLE games, teams")

# insert each team to teams table (24 rows), ignore first row!
#loop games, read winner and opponent
#cols = year,round,winner,opponent,winner_goals,opponent_goals
{
  read -r header # skip header
  while IFS=, read -r YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
    do
      GET_TEAM_RESULT=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
      if [[ -z $GET_TEAM_RESULT ]]
      then
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      fi
      GET_TEAM_RESULT=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
      if [[ -z $GET_TEAM_RESULT ]]
      then
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      fi
    done
} < "games.csv"


# insert each game to games table (32 rows), ignore first row!
{
  read -r header # skip header
  while IFS=, read -r YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
    do
      #get winner and opponent ids
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      #insert game
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$W_GOALS,$O_GOALS)")
    done
} < "games.csv"
