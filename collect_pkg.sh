#!/bin/bash

# Initialize variables
filePath=""
fileName=""
outputDir=""

# Process command-line options
while getopts "p:n:o:" opt; do
  case $opt in
    p) filePath=$OPTARG ;;
    n) fileName=$OPTARG ;;
    o) outputDir=$OPTARG ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

# Check if the required arguments are provided
if [ -z "$filePath" ]; then
  echo "Error: No file path provided. Please provide a file path with the -p option."
  exit 1
fi

if [ -z "$fileName" ]; then
  echo "Error: No file name provided. Please provide a file name with the -n option."
  exit 1
fi

# Check if the output directory exists
if [ ! -d "$outputDir" ]; then
  echo "Error: The specified output directory does not exist. Please provide a valid directory with the -o option."
  exit 1
fi

# Construct the output file name
outputFile="${fileName}-pkg.txt"

# Select lines, filter, and find unique ones ending with ".mod"
grep -e '/go/pkg/mod' -e 'openat' -e '@v' -e '.mod' "$filePath" | 
awk '/\/go\/pkg\/mod/ && /openat/ && /@v/ && /\.mod/' | 
grep -oP '/go/pkg[^"]*' | 
sed 's/.*\(\/go\/pkg[^"]*\).*/\1/' | 
grep '\.mod$' | 
sort | 
uniq |
sed 's/!/\\!/g'> "$outputDir/$outputFile"

echo "Output saved to $outputDir/$outputFile"