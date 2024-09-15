#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME() {
  NUM=$((RANDOM % 1000 + 1))

  echo "Enter your username:"
  read USERNAME

  # Get user_id
  USERID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

  if [[ -z $USERID ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    
    # Insert new user
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USERID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  else
    # Retrieve games played and best guess
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USERID")
    BEST_GUESS=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USERID")

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  fi

  echo "Guess the secret number between 1 and 1000:"
  read GUESSED

  TRIES=1

  # Loop until the user guesses the correct number
  while [[ $GUESSED -ne $NUM ]]
  do
    if [[ ! $GUESSED =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      if [[ $GUESSED -lt $NUM ]]
      then
        echo "It's higher than that, guess again:"
      elif [[ $GUESSED -gt $NUM ]]
      then
        echo "It's lower than that, guess again:"
      fi
      TRIES=$((TRIES + 1))
    fi
    read GUESSED
  done

  echo "You guessed it in $TRIES tries. The secret number was $NUM. Nice job!"

  # Insert game result
  INSERT_GAME_RESULTS=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USERID, $TRIES)")
}

GAME
