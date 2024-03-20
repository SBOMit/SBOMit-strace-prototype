#!/bin/bash

while getopts ":p:b:" opt; do
  case ${opt} in
    p ) # Process option for the output path
      outputPath=$OPTARG
      ;;
    b ) # Process option for the base path
      basePath=$OPTARG
      ;;
    \? ) echo "Usage: cmd [-p] output_folder [-b] base_folder"
      ;;
  esac
done

# Check if both -p and -b options were provided
if [ -z "$outputPath" ] || [ -z "$basePath" ]; then
    echo "Both -p (output folder) and -b (base folder) options are required."
    exit 1
fi

# Create the output directory if it does not exist
mkdir -p "$outputPath"

# Iterate over each folder in the base directory
for folder in "$basePath"/*/; do
    folderName=$(basename "$folder")
    outputFile="$outputPath/${folderName}-bins-pkg.txt"

    echo "--- Processing project: $folderName ---"

    # Ensure the output file is created even if the folder is empty
    touch "$outputFile"

    # Use find to locate all .a, .so files, and executables in the current project folder
    find "$folder" \( -type f \( -name "*.a" -o -name "*.so" \) -o -type f -executable \) -print0 | while IFS= read -r -d $'\0' item; do
        # Run strings on each file
        strings "$item" | grep "\.so\." >> "$outputFile"
    done

    # Optionally, you can sort and remove duplicates from "$outputFile" if needed
    sort -u "$outputFile" -o "$outputFile"
done

echo "*** Processing completed. Check the output files in $outputPath. ***"