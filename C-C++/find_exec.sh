#!/bin/bash

# Initialize builds_dir with a default value (optional)
builds_dir=""

# Process command-line options
while getopts ":b:" opt; do
  case $opt in
    b) builds_dir="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Check if builds_dir is not empty
if [ -z "$builds_dir" ]; then
    echo "You must specify a build directory with -b option."
    exit 1
fi

# Loop through each subfolder in the build directory
for folder in "$builds_dir"/*; do
  if [ -d "$folder" ]; then
    # Check for files with .so, .a extensions, and executables
    so_files=$(find "$folder" -type f -name "*.so")
    a_files=$(find "$folder" -type f -name "*.a")
    executable_files=$(find "$folder" -type f -executable)

    # If no such files are found, print the folder name
    if [ -z "$so_files" ] && [ -z "$a_files" ] && [ -z "$executable_files" ]; then
      echo "No executables found in: $folder"
    fi
  fi
done
