#!/bin/bash

# Set default options
RECURSIVE=false
VERBOSE=false
CHANGE_CASE=""

# Function to print usage message
usage() {
    echo "Usage: $0 [-ULMRV] <path to file or directory>"
    echo "  -U      convert file and directory names to uppercase"
    echo "  -L      convert file and directory names to lowercase"
    echo "  -M      convert the first letter of each word in file and directory names to uppercase"
    echo "  -R      perform operation recursively for all nested files and directories"
    echo "  -V      output information about the actions being performed"
}

# Parse command line options
while getopts "ULMRV" opt; do
  case $opt in
    U)
      CHANGE_CASE="/usr/bin/tr '[:lower:]' '[:upper:]'"
      ;;
    L)
      CHANGE_CASE="/usr/bin/tr '[:upper:]' '[:lower:]'"
      ;;
    M)
      CHANGE_CASE="/usr/bin/tr '[:upper:]' '[:lower:]' | /bin/sed -r 's/(\b\w)/\U\1/g'"
      ;;
    R)
      RECURSIVE=true
      ;;
    V)
      VERBOSE=true
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# Function to check if the argument is a valid directory
is_directory() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if the argument is a valid file
is_file() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Get the PATH to the file or directory to rename
if [ $# -eq 0 ]; then
  /bin/echo "Please provide a PATH to the file or directory to rename." >&2
  exit 1
fi
PATH="$1"

# Define the function to perform the case conversion
function convert_case {
  local OLD_NAME="$1"
    if is_file "$f"; then
      local FILE_NAME=$(/usr/bin/basename "$1")
      local DIR_PATH=$(/usr/bin/dirname "$1")
      local FILE_EXT="${FILE_NAME##*.}"
      local FILE_NAME_NO_EXT="${FILE_NAME%.*}"
      local NEW_FILE_NAME_NO_EXT=$(/bin/echo "$FILE_NAME_NO_EXT" | eval "$CHANGE_CASE")
      local NEW_NAME=$(/bin/echo "$DIR_PATH/$NEW_FILE_NAME_NO_EXT.$FILE_EXT")
    else
      local BASE_NAME=$(/usr/bin/basename "$1")
      local DIR_PATH=$(/usr/bin/dirname "$1")
      local NEW_BASE_NAME=$(/bin/echo "$BASE_NAME" | eval "$CHANGE_CASE")
      local NEW_NAME=$(/bin/echo "$DIR_PATH/$NEW_BASE_NAME")
    fi
  if [ "$OLD_NAME" != "$NEW_NAME" ]; then
    if [ "$VERBOSE" == true ]; then
      /bin/echo "$OLD_NAME -> $NEW_NAME"
    fi
    /bin/mv -v "$OLD_NAME" "$NEW_NAME"
  fi
}

# Rename the file or directory
if [ -f "$PATH" ]; then
  convert_case "$PATH"
elif [ -d "$PATH" ]; then
  if [ "$RECURSIVE" == true ]; then
    for f in $(/usr/bin/find "$PATH" -depth | /usr/bin/awk '{print length($0), $0}' | /usr/bin/sort -rn | /usr/bin/awk '{ print $2 }'); do
      convert_case "$f"
    done
  else
    convert_case "$PATH"
  fi
else
  /bin/echo "$PATH is not a file or directory." >&2
  exit 1
fi
