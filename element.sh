#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

#if value is string
WHERE_CLAUSE=" elements.symbol = '$1' OR elements.name = '$1';"

#if value is integer
if [[ $1 =~ ^[0-9]+$ ]]
then
  WHERE_CLAUSE=" elements.atomic_number = '$1';"
fi

QUERY_RESULT=$($PSQL "
SELECT elements.atomic_number, elements.name, elements.symbol, types.type, properties.atomic_mass, 
properties.melting_point_celsius, properties.boiling_point_celsius
FROM elements
JOIN properties ON elements.atomic_number = properties.atomic_number
JOIN types ON properties.type_id = types.type_id 
WHERE $WHERE_CLAUSE")

if [[ -z $QUERY_RESULT ]]; then
  echo "I could not find that element in the database."
else
  echo "$QUERY_RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING; do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi
