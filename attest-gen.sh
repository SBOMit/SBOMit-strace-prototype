#!/bin/bash

while getopts "i:k:d:p:" opt; do
  case $opt in
    i) inputFile=$OPTARG ;;
    k) signingKey=$OPTARG ;;
    d) outputDir=$OPTARG ;;
    p) productPath=$OPTARG ;;  # New option for product path
    *) echo "Usage: $0 -i <input_file> -k <signing_key> -d <output_dir> -p <product_path>"; exit 1 ;;
  esac
done

# Check for missing required arguments
if [ -z "$inputFile" ] || [ -z "$signingKey" ] || [ -z "$outputDir" ] || [ -z "$productPath" ]; then
  echo "Missing required arguments"
  echo "Usage: $0 -i <input_file> -k <signing_key> -d <output_dir> -p <product_path>"
  exit 1
fi

# Create the output directory if it does not exist
mkdir -p "$outputDir"

# Initialize an array to hold all file paths
declare -a filePaths

# Define additional path segments as variables
MOD_PATH_SEGMENT="/go/pkg/mod/"
GO_MOD_FILENAME="/go.mod"

while IFS= read -r filePath; do
    fullPath="${HOME}${MOD_PATH_SEGMENT}${filePath}"
    # Add the full path to the filePaths array
    filePaths+=("$fullPath")
done < "$inputFile"

# Convert the filePaths array to a space-separated string
materialPaths="${filePaths[*]}"

# echo "$materialPaths"

# Define the step name as "build"
stepPerformed="build"

# Run in-toto-run with all file paths, product path, and "go build" as the command
in-toto-run -m $materialPaths -n "$stepPerformed" --signing-key "$signingKey" -d "$outputDir" -p "$productPath" -- go build

