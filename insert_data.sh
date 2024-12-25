#!/bin/bash

# Use psql command for test or production databases
if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Read the games.csv file line by line
while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # Skip the header line
  if [[ "$year" != "year" ]]; then
    # Insert both winner and opponent into the teams table (ignore duplicates)
    $PSQL "INSERT INTO teams (name) VALUES ('$winner') ON CONFLICT (name) DO NOTHING"
    $PSQL "INSERT INTO teams (name) VALUES ('$opponent') ON CONFLICT (name) DO NOTHING"

    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', (SELECT team_id FROM teams WHERE name = '$winner'), (SELECT team_id FROM teams WHERE name = '$opponent'),$winner_goals, $opponent_goals)"
  fi
done < games.csv

echo "Teams have been inserted into the table from games.csv."
