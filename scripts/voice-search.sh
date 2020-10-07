#!/bin/sh

set -e

# Silence parallel
echo "will cite" | parallel --citation >/dev/null 2>&1 || true

source ./vars.sh

if [ -z "$COOKIES" ]; then
	echo "ERROR: See 'README.md' for instructions for adding your Google cookies"
	exit 1
fi

# Initialize result location
mkdir -p "$OUT_DIR" "$NUMBERS_DIR"

# Get area codes
printf "Getting list of area codes..."
if [ -e "$AREA_CODE_FILE" ]; then
	printf " Skipping..."
else
	# Fetch area codes
	AREA_CODES="$(curl -s --cookie "$COOKIES" "${BASE_URL}?ac=[201-999]&start=0&lite=1&country=US" | jq --slurp -r 'map(.JSON.vanity_info | keys) | flatten | map(.[2:5]) | unique | join("\n")')"

	# Only write to the file once the GET completed successfully
	echo "$AREA_CODES" > "$AREA_CODE_FILE"
fi

printf " Found %s\n" "$(cat "$AREA_CODE_FILE" | wc -l)"

# Get numbers for each area code in parallel
parallel -j 1  --halt soon,fail=1 -u ./get-numbers-for-area.sh < "$AREA_CODE_FILE"

mkdir -p "$INTERESTING_NUMBERS_DIR"

check_for_pattern() {
	local NAME="$1"
	local PATTERN="$2"
	local FILE="$INTERESTING_NUMBERS_DIR/$NAME"

	printf "Looking for $NAME..."
	grep "$PATTERN" "$ALL_NUMBERS_FILE" > "$FILE"
	printf " Found %s\n" "$(cat "$FILE" | wc -l)"
}

echo "Searching numbers list for interesting numbers..."
check_for_pattern pairs "\([0-9]\)\1.*\([0-9]\)\2.*\([0-9]\)\3"
check_for_pattern repetitions "\([0-9]\)\1\{3\}"
check_for_pattern palindromes "\([0-9]\)\([0-9]\)\([0-9]\)\([0-9]\).?\4\3\2\1"
check_for_pattern toggle1 "\([0-9]\)\([0-9]\)\1\2\1\2"
check_for_pattern toggle2 "\([0-9]\)\([0-9]\)\1\2.*\([0-9]\)\([0-9]\)\3\4\3"
check_for_pattern twodigits "\([0-9]\)\([0-9]\)\(\1|\2\)\{4\}"
check_for_pattern ABABACDCDC "\([0-9]\)\([0-9]\)\1\2\1.*\([0-9]\)\([0-9]\)\3\4\3"
check_for_pattern tripledouble "\([0-9]\)\1.*\([0-9]\)\2.*\([0-9]\)\3"
check_for_pattern binary "[0-9][0-9][0-9]\([01]\)\([01]\)\([01]\)\([01]\)\([01]\)\([01]\)\([01]\)"
check_for_pattern 1337 "[0-9]*1337[0-9]*"
check_for_pattern 1337_end "[0-9]*1337$"
