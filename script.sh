#!/usr/bin/env bash

# cli parsing

# check if the first argument is an existing file
check_if_file_exists() {
  if [ -f "$1" ]; then
    return 0
  else
    echo "File with the path '$1' does not exist"
    return 1
  fi
}

# check if the first argument is empty. if it is, prompt
# the user in the cli for the first arg
if [ -z "$1" ]; then
  read -p "Enter the path to the file you want to upload: " arg1
else
  arg1="$1"
fi

# checks if the second argument is also empty, and prompts
# the user for it
if [ -z "$2" ]; then
  read -p "Enter the blob container name you want to upload to: " arg2
else
  arg2="$2"
fi

# checks if the 2 variables have values in them, then throws an 
# error if a third argument was provided as a cli argument. if 
# only 2 arguments, run the file check
if [ "$arg1" ] && [ "$arg2" ]; then
  if [ "$3" ]; then
    echo "You can have only 2 arguments"
    exit 1
  fi

  check_if_file_exists "$arg1"

else
  echo "You must add two arguments to this command"
  exit 1
fi

# checks the return code of the last executed command
# 0 means success, non-zero means fail, usually
if [ $? -eq 0 ]; then
  az storage blob upload \
  --account-name elvisnipahstorage \
  --container-name "$arg2" \
  --name "$arg1" \
  --file "$arg1" \
  --auth-mode login \
  2> log.txt

  if [ $? -eq 0 ]; then
    echo "It worked"
  else
    echo "It did not work :<"
  fi
else
  echo "The function failed"
fi
