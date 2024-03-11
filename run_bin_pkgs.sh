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
    outputFile="$outputPath/${folderName}-bin-pkg.txt"

    echo "--- Processing project: $folderName ---"

    # Ensure the output file is created even if the folder is empty
    touch "$outputFile"

    tempFile=$(mktemp)  # Create a temporary file

    # Iterate over each item in the folder
    for item in "$folder"/*; do
        if [ -f "$item" ]; then  # Ensure it is a file
            # Run strings, filter with grep, and use sed to modify the output, then append to the temporary file
            strings "$item" | grep '/go/pkg/mod/.*@v' | sed -E 's|.*/go/pkg/mod/||; s|(@v[^/]*)/.*|\1|; s|!([a-z])|\U\1|g' >> "$tempFile"
        fi
    done

    # Sort the contents of the temporary file, remove duplicates, and append to the final output file
    sort "$tempFile" | uniq >> "$outputFile"
    rm "$tempFile"  # Remove the temporary file
done

echo "*** Processing completed. Check the output files in $outputPath. ***"


