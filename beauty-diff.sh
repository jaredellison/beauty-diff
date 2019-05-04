#!/bin/bash

# beauty-diff Version 0.1
# Jared Ellison October 2018
# * Preview and accept the changes of a beautified file. *

###################################
# Setup

# for cleaning up the tmp file
cleanup() {
  rm "$1"
  trap - EXIT HUP INT QUIT TERM
  exit
}

fatal() {
  echo >&2 "$1"
  exit 1
}

getBeautify() {
  choices=("abort")
  command -v npm &>/dev/null && choices+=("npm (node)")
  command -v pip &>/dev/null && choices+=("pip (python)")
  if [[ ${#choices[@]} -eq 1 ]]; then
      fatal "Please install js-beautify: https://beautifier.io/"
  fi
  cat <<EOF
$(basename "$0") requires js-beautify.
Select an available package manager or abort:
EOF
  select choice in "${choices[@]}"; do
    case $choice in
      "npm (node)") npmInstall;;
      "pip (python)") pip install jsbeautifier;;
      *) fatal "Please install js-beautify: https://beautifier.io/";;
    esac
    break
  done
}

getColordiff() {
  # TODO check if URL is valid and consider handling error if colordiff.org is down
  choices=("abort" "download and install colordiff (https://www.colordiff.org)")
  cat <<EOF
$(basename "$0") requires colordiff.
Install from www.colordiff.org or abort?
EOF
  select choice in "${choices[@]}"; do
    if [[ $choice = abort ]]; then
      fatal "Please install colordiff: https://www.colordiff.org/"
    else
      break
    fi
  done
  local version
  version="colordiff-1.0.18"
  curl "https://www.colordiff.org/$version.tar.gz" \
    | tar xz || fatal "Please install colordiff: https://www.colordiff.org/"
  cd "$version" || fatal "Please install colordiff: https://www.colordiff.org/"
  installDirs="$(awk 'BEGIN { FS="\=" } /_DIR\?/ { print $2 }' Makefile)"
  local needsRoot
  while read -r line; do
    if [[ $UID -ne $(stat -f "%u" "$line") ]]; then
      needsRoot="sudo"
    fi
  done <<<"$installDirs"
  if [[ $(uname) == "Darwin" ]]; then
      sed -i '/install -Dm/d' Makefile # -D is an illegal flag for BSD install
  fi
  "$needsRoot" make install || fatal "Please install colordiff: https://www.colordiff.org/"
  cd ..
  rm -rf $version
}

npmInstall() {
  local needsRoot
  if [[ $UID -ne $(stat -f "%u" "$(npm root -g)") ]]; then
    needsRoot="sudo"
  fi
  "$needsRoot" npm -g install js-beautify || fatal "Install failed. Try: sudo npm -g install js-beautify"
}

# Check if js-beautify is installed
js-beautify -v &>/dev/null || getBeautify

# Check if js-beautify is installed
colordiff -v &>/dev/null || getColordiff

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
trap 'cleanup $beautifulFile' EXIT HUP INT QUIT TERM

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
