#!/bin/sh

OUT_DIR="out"
AREA_CODE_FILE="$OUT_DIR/area codes.txt"
NUMBERS_DIR="$OUT_DIR/numbers by area code"
INTERESTING_NUMBERS_DIR="$OUT_DIR/interesting numbers"
ALL_NUMBERS_FILE="$OUT_DIR/all numbers.txt"

BASE_URL="https://www.google.com/voice/setup/search/"

# Add your Google cookies here
COOKIES=""
