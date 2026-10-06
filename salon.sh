#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Obtener los servicios de la base de datos
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # Mostrar la lista de servicios formateada
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Leer el servicio seleccionado
  read SERVICE_ID_SELECTED

  # Verificar si el servicio existe
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    # Si no existe, volver a mostrar el menú
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Si existe, pedir teléfono
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Verificar si el cliente ya existe
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      # Si es cliente nuevo, pedir el nombre
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # Insertar nuevo cliente
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # Pedir el horario del turno
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Obtener el ID del cliente (sea nuevo o viejo)
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Insertar el turno en la tabla appointments
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Mensaje final exacto que pide el test
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Ejecutar el menú inicial
MAIN_MENU "Welcome to My Salon, how can I help you?\n"