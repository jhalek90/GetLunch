#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
NumberOfPlaces=$1
if [ ! -n $NumberOfPlaces ]; then
  echo -e "${YELLOW}./GetLunch <Number of places>"
  exit 1
fi

# Print logo and stuff.
clear && printf "${GREEN}$(cat logo.txt)\n${NC}\nChecking ${PURPLE}UberEats${NC} for avalible places...\n"

# Store the restaurant list locally.
Restaurants=$(jq -r '.restaurants' restaurants.json)
RestaurantCount=$(echo $Restaurants | jq -r 'length')

# Pick N random restaurants.
for i in $(seq 1 $NumberOfPlaces); do
  Result=""
  until [ "$Result" == "Avalible" ]; do
    RandIndex=$(($RANDOM % ${RestaurantCount}))
    Name=$(echo $Restaurants | jq -r ".[$RandIndex].name")
    Url=$(echo $Restaurants | jq -r ".[$RandIndex].url")
    if [[ "$Url" != "null" ]]; then
      # Check availability.
      Result="Avalible"
      HTML=$(w3m -r -s -dump -l 1 "$Url")
      if [[ $HTML == *"Opens"* ]] || [[ $HTML == *"Currently unavailable"* ]]; then
        Result="Closed"
      fi
    fi
  done

  echo -e "    - ${YELLOW}${Name}${NC}: ${GREEN}${Url}${NC}"
  # Nullify the selection, to prevent duplicates,
  # and maintain probability.
  Restaurants=$(echo $Restaurants | jq -r ".[$RandIndex].url|=null")
done

printf "\n${PURPLE}Control click links to open them in a new tab.\n"
