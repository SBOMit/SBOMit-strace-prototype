#!/bin/bash

# Initialize variables
projectsFolder=""
outputPath=""

# Parse options
while getopts "p:o:b:" opt; do
  case $opt in
    p) projectsFolder=$OPTARG ;;
    o) outputPath=$OPTARG ;;
    b) binaryOutputPath=$OPTARG ;;
    *) echo "Usage: $0 -p <projects_folder> -o <output_path>"; exit 1 ;;
  esac
done

# Check if required options were provided
if [ -z "$projectsFolder" ] || [ -z "$outputPath" ] || [ -z "$binaryOutputPath" ]; then
  echo "Missing required arguments"
  echo "Usage: $0 -p <projects_folder> -o <output_path> -b <binary_output_path>"
  exit 1
fi

# Ensure the output directory exists
mkdir -p "$outputPath"
mkdir -p "$binaryOutputPath"
absoluteOutputPath=$(realpath "$outputPath")
absoluteBinaryOutputPath=$(realpath "$binaryOutputPath")

# Navigate to the projects folder
cd "$projectsFolder" || { echo "Failed to navigate to directory: $projectsFolder"; exit 1; }

# Loop through each project directory
for projectDir in */ ; do
    projectName=$(basename "$projectDir")
    projectPath=$(realpath "$projectDir")
    projectBinaryOutputPath="$absoluteBinaryOutputPath/$projectName"

    mkdir -p "$projectBinaryOutputPath"

    echo "--- Processing root of $projectName ---"
    # Run strace -f at the project root and output to the unique file
    # cd "$projectPath" && strace -f -e openat cargo build --target-dir "$projectBinaryOutputPath" >> "$absoluteOutputPath/$projectName-strace.txt" 2>&1

    cd "$projectPath" && strace -f -e openat cargo build --target-dir "$projectBinaryOutputPath" > "$absoluteOutputPath/$projectName-strace.txt" 2>&1

    cd - > /dev/null  # Go back to the projects folder without printing the working directory

    outputFile="${projectName}-pkg.txt"  # Construct the output file name

    # Process the file and output the results
    grep '\.cargo/registry/cache/.*\.crate"' "$absoluteOutputPath/$projectName-strace.txt" | 
    sed -E 's|.*/([^/]+)\.crate".*|\1|' |
    sed 's/-\([0-9]\)/@\1/g' |
    sort | 
    uniq > "$absoluteOutputPath/$outputFile"

    echo "Output saved to $absoluteOutputPath/$outputFile"

    rm -f "$absoluteOutputPath/$projectName-strace.txt"

done

echo "*** All projects processed ***"
