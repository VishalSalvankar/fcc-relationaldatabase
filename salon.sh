#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo "$1"
  else
    echo -e "Welcome to My Salon, how can I help you?"
  fi

  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_RESULT ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_RESULT")
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_ID=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      APPOINTMENT_ID_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID_RESULT, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      APPOINTMENT_ID_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU