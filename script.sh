#!/usr/bin/env bash

# cli parsing
if [ $1 ] && [ $2 ]; then
  if [ $3 ]; then
    echo "You can have only 3 arguments"
    exit
  fi
  
  if [ -f $1 ]; then
    echo "This is a file"
  else
    echo "This is not a file"
  fi
else
  echo "You must add two arguments to this command"
  exit
fi
