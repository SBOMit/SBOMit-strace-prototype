#!/bin/bash

# Directory containing build folders
builds_dir="./eval-c-cpp-bins"

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

