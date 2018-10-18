#!/bin/bash

###################################
# Setup

# Check if js-beautify is installed
js-beautify -v >/dev/null 2>&1 || { echo >&2 "Please install js-beautify: https://beautifier.io/"; exit 1; }

# Check if js-beautify is installed
colordiff -v >/dev/null 2>&1 || { echo >&2 "Please install colordiff: https://www.colordiff.org/"; exit 1; }
###################################

# Get input filename
FILE=("${@}")

# Check if the file actually exists
if [ ! -f $FILE ]; then
    echo "File not found!"
    exit 1
fi

# Create a temporary file
BEAUTIFUL_FILE="/tmp/$FILE-beautified"
touch $BEAUTIFUL_FILE

# Process input file
js-beautify $FILE > $BEAUTIFUL_FILE

# Compare with original file
colordiff $FILE $BEAUTIFUL_FILE

# Colordiff output doesn't always end in a new line so here's one:
echo ""

echo "accept beautified file? [y,n]"
read input

if [[ $input == "Y" || $input == "y" ]]; then
  echo "saving changes"
  cp $BEAUTIFUL_FILE $FILE
else
  echo "changes not accepted"
fi

# Clean up /tmp/ and remove temporary file
rm $BEAUTIFUL_FILE

exit 0