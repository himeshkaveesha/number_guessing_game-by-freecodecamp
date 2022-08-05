#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(($RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME
PLAYER=$($PSQL "SELECT username, games_played, best_game FROM players WHERE username='$USERNAME'")
if [ -z "$PLAYER" ]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO players(username) VALUES('$USERNAME')" > /dev/null
else
  echo $PLAYER | {
    IFS=" | "
    read USERNAME GAMES_PLAYED BEST_GAME
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  }
fi

NUMBER_OF_GUESSES=1
echo "Guess the secret number between 1 and 1000:"
read GUESS

until [ "$GUESS" == "$SECRET_NUMBER" ]
do
  ((NUMBER_OF_GUESSES++))
  if [[ "$GUESS" =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS > $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS < $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
  read GUESS
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
$PSQL "UPDATE players SET games_played = games_played + 1, best_game = (SELECT MIN(x) FROM (VALUES (best_game), ($NUMBER_OF_GUESSES)) AS value(x)) WHERE username = '$USERNAME'" > /dev/null
