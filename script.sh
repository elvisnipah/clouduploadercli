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

# function for calling the azure cli to upload the file
upload_file() {
  # localize and rename variables, create an array for
  # the arguments needed
  local args=()
  local container_name="$arg2"
  local file_name="$arg1"
  local overwrite="$1"
  
  # add the arguments for the command
  args+=(
    "--account-name" "elvisnipahstorage"
    "--container-name" "$container_name"
    "--name" "$file_name"
    "--file" "$file_name"
    "--auth-mode" "login"
    "--verbose"
  )

  # check if the overwrite variable is set to 0 (true)
  # and if true, add the '--overwrite' argument to the array
  (( "$overwrite" == 0 )) && args+=( "--overwrite" )

  # call the function with every member of the arguments
  # array
  az storage blob upload "${args[@]}"
}

# check if blob exists already
check_blob_exists() {
  local args=()
  local container_name="$arg2"
  local file_name="$arg1"
  
  # add the arguments for the command
  args+=(
    "--account-name" "elvisnipahstorage"
    "--container-name" "$container_name"
    "--name" "$file_name"
    "--auth-mode" "login"
  )

  az storage blob show "${args[@]}"
}

# variable to store user's file overwrite choice
overwrite_check=1

while : 
do
  # check if the first argument is empty. if it is, prompt
  # the user in the cli for it
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
    # check if the blob exists
    blob_exists=$((check_blob_exists) 2>&1)
    
    if echo "$blob_exists" | grep -q "ErrorCode:BlobNotFound" || [ $overwrite_check -eq 0 ]; then
      # store the output in the result variable
      result=$((upload_file $overwrite_check) 2>&1)

      # if the last command was successful, do thing
      # and exit the program
      if [ $? -eq 0 ]; then
        echo "File upload was successful."
        echo "$result" > log.txt
        echo -n "File link: "
        # -o means output only. match the 'https://' part of the string
        # "[^']" matches any characters that are not a ', since the string
        # ends with a '. 'head -n1' takes only the first line of output
        # in case there are multiple matches
        echo "$result" | grep -o "https://[^']*" | head -n1
        exit 0
      # check for wrong container name error
      elif echo "$result" | grep -q "ErrorCode:ContainerNotFound"; then
        echo "Oops, that seems to be a wrong container name. Please try again."
        exit 1
      else
        echo "$result"
        exit 1
      fi
    else
      echo "This file already exists in the container."
      read -p "Do you want to overwrite the file? (y/n): " check
      if [[ "$check" == "y" ]] || [[ "$check" == "Y" ]]; then
        overwrite_check=0
        continue
      else
        exit 1
      fi
        
        # exit the program and print the error from azure
        echo "It did not work :<"
        echo "$result"
        exit 1
    fi

  # exit the program as something failed before az (probably file check)
  else
    echo "The function failed"
    exit 1
  fi

done