#!/bin/bash

# beauty-diff Version 0.1
# Jared Ellison October 2018
# * Preview and accept the changes of a beautified file. *

###################################
# Setup

fatal() {
  echo >&2 "$1"
  exit 1
}

# Check if js-beautify is installed
js-beautify -v &>/dev/null || fatal "Please install js-beautify: https://beautifier.io/"

# Check if js-beautify is installed
colordiff -v &>/dev/null || fatal "Please install colordiff: https://www.colordiff.org/"

###################################

if [[ $# -eq 0 ]]; then
  cat <<EOF
usage: $(basename "$0") file ...
Preview changes of js-beautify and compare with colordiff on file(s).
EOF
  exit 1
fi

# Create a temporary file
beautifulFile=$(mktemp) || fatal "could not make temporary file, exiting"
trap 'rm -f $beautifulFile' EXIT

for file do
  # Check if the file actually exists
  if [[ ! -f $file ]]; then
    echo "Skipping bad file name: \"$file\""
    continue
  fi

  # Process input file
  js-beautify "$file" > "$beautifulFile"

  # Compare with original file
  colordiff "$file" "$beautifulFile"

  # Colordiff output doesn't always end in a new line so here's one:
  echo ""

  read -r -p "Do you accept beautified file? [y,n] "

  if [[ $REPLY = [Yy] ]]; then
    echo "Saving changes to $file"
    cp "$beautifulFile" "$file"
  else
    echo "Changes not accepted"
  fi
done

exit 0
