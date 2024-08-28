#!/usr/bin/env bash

# cli parsing

check_if_file_exists() {
  if [ -f "$1" ]; then
    echo "This is a file"
    return 0
  else
    echo "File with the path '$1' does not exist"
    return 1
  fi
}

if [ "$1" ] && [ "$2" ]; then
  if [ "$3" ]; then
    echo "You can have only 2 arguments"
    exit 1
  fi

  check_if_file_exists "$1"

else
  echo "You must add two arguments to this command"
  exit 1
fi
