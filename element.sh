#!/bin/bash

# Element database query script
# Queries a PostgreSQL periodic table database for element information

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Try to find element by atomic_number, symbol, or name
ELEMENT=$($PSQL "
  SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  JOIN types t ON p.type_id = t.type_id
  WHERE e.atomic_number::text = '$1' OR e.symbol = '$1' OR e.name = '$1'
")

# Check if element was found
if [[ -z $ELEMENT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse the result
IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME MASS MELTING BOILING TYPE <<< "$ELEMENT"

# Remove trailing zeros after decimal point
MASS=$(echo "$MASS" | sed 's/0\+$//' | sed 's/\.$//')

# Output the formatted result
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
