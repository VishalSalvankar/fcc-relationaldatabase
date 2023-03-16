#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME
USER_RESULT=$($PSQL "SELECT user_id, name, number_of_games, best_game FROM users WHERE name='$USERNAME'")

if [[ -z $USER_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES ('$USERNAME')")
else
  echo $USER_RESULT | while IFS='|' read USER_ID NAME NO_OF_GAMES BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $NO_OF_GAMES games, and your best game took $BEST_GAME guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
RANDOM_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
TIMES=1
read NUMBER_INPUT
while [[ $NUMBER_INPUT != $RANDOM_NUMBER ]]
do
  if [[ ! $NUMBER_INPUT =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $NUMBER_INPUT -gt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
  ((TIMES=TIMES+1))
  read NUMBER_INPUT
done

echo "You guessed it in $TIMES tries. The secret number was $RANDOM_NUMBER. Nice job!"
NEW_COUNT=$($PSQL "SELECT number_of_games FROM users WHERE name='$USERNAME'")+1
if [[ -z $BEST_GAME ]]
then
  INSERT_RESULT=$($PSQL "UPDATE users SET number_of_games=$NEW_COUNT, best_game=$TIMES WHERE name='$USERNAME'")
elif [[ $TIMES -lt $BEST_GAME ]]
then
  INSERT_RESULT=$($PSQL "UPDATE users SET number_of_games=$NEW_COUNT, best_game=$TIMES WHERE name='$USERNAME'")
else
  INSERT_RESULT=$($PSQL "UPDATE users SET number_of_games=$NEW_COUNT WHERE name='$USERNAME'")
fi