#!/bin/bash

#script randomly generates a number that users have to guess

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#ask for name (max 22 chars)
echo Enter your username:
read USERNAME

#look for user in db
USER_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

#if user not in db
if [[ -z $USER_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  #games_played = total number of games
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_RESULT;")
  #best_game = fewest num of guesses a game was won with
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_RESULT")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#pick a random num for the game 1-1000
NUMBER=$((1 + RANDOM % 1000))
echo Guess the secret number between 1 and 1000:
read GUESS

GUESSES=1

#while GUESS is not correct number
while [[ $NUMBER != $GUESS ]]
do
  #if GUESS not int
  if [[ ! "$GUESS" =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  ((GUESSES++))
  read GUESS
done

#num was found
echo "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
#insert user into db if not in already
if [[ -z $USER_RESULT ]]
then
  USER_INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
fi
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
#insert game stats into db
GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES('$USER_ID', $GUESSES)")
