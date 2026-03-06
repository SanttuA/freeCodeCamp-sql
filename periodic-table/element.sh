#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

pretty_print(){
  #if no elem found print
  if [[ -z $1 ]]
  then
    echo I could not find that element in the database.
  else
    IFS='|' read -r -a fields <<< "$1"
    ATOMIC_NUMBER="${fields[1]}"
    SYMBOL="${fields[2]}"
    NAME="${fields[3]}"
    MASS="${fields[4]}"
    MELTING_POINT="${fields[5]}"
    BOILING_POINT="${fields[6]}"
    TYPE="${fields[7]}"

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
}

#if no arg
if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  #if arg is num, look for atomic num
  if [[ "$1" =~ ^[0-9]+$ ]]
  then
    ELEM_RESULT=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$1")
    pretty_print $ELEM_RESULT
  #elif 1-2 chars, look for symbol
  elif [[ "$1" =~ ^[A-Za-z]{1,2}$ ]]
  then
    ELEM_RESULT=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol='$1'")
    pretty_print $ELEM_RESULT
  #else look for name
  else
    ELEM_RESULT=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE name='$1'")
    pretty_print $ELEM_RESULT
  fi
fi
