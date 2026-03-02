#!/bin/bash

#psql --username=freecodecamp --dbname=salon -c "SQL QUERY HERE"

echo -e "\n---Welcome to Salon XYZ---\n"

#get services
get_services(){
  echo -e "What kind of service are you looking for?"
  psql --username=freecodecamp --dbname=salon -t -A -c "SELECT service_id, name FROM services;" | while IFS='|' read -r SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read_user
}

#read user input
read_user(){
  read SERVICE_ID_SELECTED
  #if not valid, ask again
  SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "Please select a valid option\n"
    get_services
  else
    #ask for phone
    echo -e "What is your phone number?"
    read CUSTOMER_PHONE
    #if does not exist in db, create new customer
    CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_NAME ]]
    then
      #ask for name
      echo -e "What is your name?"
      read CUSTOMER_NAME
      CUSTOMER_RESULT=$(psql --username=freecodecamp --dbname=salon -t -A -c "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #ask for time
    echo -e "What time do you want to come in?"
    read SERVICE_TIME
    APPOINTMENT_RESULT=$(psql --username=freecodecamp --dbname=salon -t -A -c "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
    #thank you and exit
    echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

get_services
