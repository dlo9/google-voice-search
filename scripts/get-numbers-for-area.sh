#!/bin/sh
# Gets the numbers for one area code

set -e

source ./vars.sh

AREA_CODE="$1"
if [ -z "$AREA_CODE" ]; then
	echo "Usage: get-numbers-for-area.sh <area code>"
	exit 1
fi

NUMBERS_FILE="$NUMBERS_DIR/$AREA_CODE.txt"
PARTIAL_NUMBERS_FILE="$NUMBERS_DIR/$AREA_CODE.txt.partial"

# Print an info message
printf "Getting numbers in area code $AREA_CODE..."

if [ -e "$NUMBERS_FILE" ] && [ ! -e "$PARTIAL_NUMBERS_FILE" ]; then
	# We're done if the output file exists and there are no more numbers to process
	printf " Skipping..."
else
	if [ ! -e "$PARTIAL_NUMBERS_FILE" ]; then
		# All queries must be 3+ digits, so start the initial list with 3 known digits (the area code)
		echo "$AREA_CODE" > "$PARTIAL_NUMBERS_FILE"
	fi

	while [ -s "$PARTIAL_NUMBERS_FILE" ]; do
		# Run the numbers search in parallel, and parse the output into terminal searches and non-terminal searches
		# TODO: pipefail
		RESULTS="$(parallel --halt soon,fail=1 ./iterate-number.sh "$AREA_CODE" < "$PARTIAL_NUMBERS_FILE" | jq --slurp -r 'map(.JSON | . + {isDone: (.num_matches == (.vanity_info | length | tostring))}) | { done: (map(select(.isDone) | .vanity_info | keys) | flatten), todo: (map(select(.isDone | not) | .translated_query))}')"

		echo "$RESULTS" | jq -r '.done | join("\n")' | sed '/^$/d' >> "$NUMBERS_FILE"
		echo "$RESULTS" | jq -r '.todo | join("\n")' | sed '/^$/d' > "$PARTIAL_NUMBERS_FILE"

		I=$((I+1))
	done

	# Append them to the "all numbers" file
	cat "$NUMBERS_FILE" >> "$ALL_NUMBERS_FILE"

	# Cleanup
	rm "$PARTIAL_NUMBERS_FILE"
fi

# Print the count
printf " Found %s\n" "$(cat "$NUMBERS_FILE" | wc -l)"
