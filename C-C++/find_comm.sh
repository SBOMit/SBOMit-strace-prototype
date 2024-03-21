#!/bin/bash

# Initialize path variable
path=""

# Parse command-line options
while getopts 'p:' flag; do
  case "${flag}" in
    p) path="${OPTARG}" ;;
    *) echo "Usage: $0 -p path_to_folder" >&2
       exit 1 ;;
  esac
done

# Check if the path has been set
if [ -z "$path" ]; then
  echo "You must specify a path using the -p option." >&2
  exit 1
fi

# Navigate to the specified folder
cd "$path" || exit

# Count the number of txt files
num_files=$(ls -1 *.txt | wc -l)

# Check if there are any txt files
if [ "$num_files" -eq 0 ]; then
  echo "No .txt files found in the specified path." >&2
  exit 1
fi

# Concatenate, sort, and count unique lines. Then, filter lines that appear in all files.
cat *.txt | sort | uniq -c | awk -v num_files="$num_files" '{if ($1 == num_files) print substr($0, index($0,$2))}'