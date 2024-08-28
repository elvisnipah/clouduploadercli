#!/usr/bin/env bash

# cli parsing
if [ $1 ] && [ $2 ]; then
  if [ $3 ]; then
    echo "You can have only 3 arguments"
    exit
  fi
  echo "Arg 1 exists: $1"
  echo "Arg 2 exists: $2"
else
  echo "You must add two arguments to this command"
  exit
fi
