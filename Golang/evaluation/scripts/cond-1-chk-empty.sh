#!/bin/bash

# Initialize variable for directory
DIRECTORY=""

# Use getopts to parse the -p option for the path
while getopts ":p:" opt; do
  case ${opt} in
    p )
      DIRECTORY=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Check if DIRECTORY variable is set
if [ -z "$DIRECTORY" ]; then
    echo "Usage: $0 -p path_to_directory"
    exit 1
fi

# Counter for empty files and non-empty files
empty_count=0
non_empty_count=0

# Check if the specified directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "The specified directory does not exist."
    exit 1
fi

# Iterate over files ending with -pkg.txt in the specified directory
for file in "$DIRECTORY"/*-pkg.txt; do
    # Check if file exists to handle the case where no files match the pattern
    if [ -e "$file" ]; then
        if [ ! -s "$file" ]; then
            # File is empty
            echo "Empty file: $file"
            ((empty_count++))
        else
            # File contains something
            echo "Non-empty file: $file"
            ((non_empty_count++))
        fi
    fi
done

# Output the total number of empty and non-empty -pkg.txt files
echo "Total number of empty -pkg.txt files: $empty_count"
echo "Total number of non-empty -pkg.txt files: $non_empty_count"
