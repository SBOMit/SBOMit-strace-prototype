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

    tempFile=$(mktemp)  # Create a temporary file

    # Use find to locate all executable files in the current project folder, then process each
    while IFS= read -r item; do
        # Run strings, filter with grep for 'index.crates.io', then use sed to extract crate name and version
        strings "$item" | grep 'index.crates.io' | sed -n 's|.*/index.crates.io-[^/]*/\([^/]*\).*$|\1|p' | sed 's/-\([0-9]\)/@\1/g' >> "$tempFile"
    done < <(find "$folder" -type f -executable -print)


    # Sort the contents of the temporary file, remove duplicates, and append to the final output file
    sort "$tempFile" | uniq >> "$outputFile"
    rm "$tempFile"  # Remove the temporary file
done

echo "*** Processing completed. Check the output files in $outputPath. ***"


