#!/bin/bash

# beauty-diff Version 0.1
# Jared Ellison October 2018
# * Preview and accept the changes of a beautified file. *

###################################
# Setup

# Check if js-beautify is installed
js-beautify -v &>/dev/null || { echo >&2 "Please install js-beautify: https://beautifier.io/"; exit 1; }

# Check if js-beautify is installed
colordiff -v &>/dev/null || { echo >&2 "Please install colordiff: https://www.colordiff.org/"; exit 1; }
###################################

if [[ $# -eq 0 ]]; then
  echo "usage: $(basename "$0") file"
  exit 1
fi

# Get input filename
FILE_PATH="${*}"

# Check if the file actually exists
if [[ ! -f $FILE_PATH ]]; then
    echo "File not found!"
    exit 1
fi

# Strip the filename from the full path
FILE_NAME=$(basename "$FILE_PATH")

# Create a temporary file
BEAUTIFUL_FILE="/tmp/$FILE_NAME-beautified"
touch "$BEAUTIFUL_FILE"

# Process input file
js-beautify "$FILE_PATH" > "$BEAUTIFUL_FILE"

# Compare with original file
colordiff "$FILE_PATH" "$BEAUTIFUL_FILE"

# Colordiff output doesn't always end in a new line so here's one:
echo ""

read -r -p "Do you accept beautified file? [y,n] " input

if [[ $input == [Yy] ]]; then
  echo "Saving changes to $FILE"
  cp "$BEAUTIFUL_FILE" "$FILE_PATH"
else
  echo "Changes not accepted"
fi

# Clean up /tmp/ and remove temporary file
rm "$BEAUTIFUL_FILE"

exit 0
