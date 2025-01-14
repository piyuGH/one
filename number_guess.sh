#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME

# Check if user exists
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME';")
if [[ -z $USER_INFO ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Add user to the database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) 
                                      VALUES('$USERNAME');")
else
  # Extract user info
  IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#random number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
echo "Guess the secret number between 1 and 1000:"
GUESSES=0

while true; do
  read GUESS
  ((GUESSES++))

  #Validate input value
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  #guess the number
  if ((GUESS < SECRET_NUMBER)); then
    echo "It's higher than that, guess again:"
  elif ((GUESS > SECRET_NUMBER)); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    if [[ -z $USER_INFO ]]; then
      USER_ID=$($PSQL "SELECT user_id FROM users 
                        WHERE username='$USERNAME';")
    fi
    GAMES_PLAYED=$((GAMES_PLAYED + 1))
    if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]; then
      BEST_GAME=$GUESSES
    fi
    UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, 
                                        best_game=$BEST_GAME WHERE user_id=$USER_ID;")
    break
  fi
done
