#!/bin/sh

set -e

source ./vars.sh

AREA_CODE="$1"
PREFIX="$2"
if [ -z "$AREA_CODE" ] || [ -z "$PREFIX" ]; then
	echo "Usage: iterate-number.sh <area code> <prefix (including area code)>"
	exit 1
fi

curl -sS --fail-early --cookie "$COOKIES" "${BASE_URL}?ac=$AREA_CODE&q=$PREFIX[0-9]&start=0"
