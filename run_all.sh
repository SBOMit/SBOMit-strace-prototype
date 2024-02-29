#!/bin/bash

# Initialize variables
projectsFolder=""
outputPath=""

# Parse options
while getopts "p:o:" opt; do
  case $opt in
    p) projectsFolder=$OPTARG ;;
    o) outputPath=$OPTARG ;;
    *) echo "Usage: $0 -p <projects_folder> -o <output_path>"; exit 1 ;;
  esac
done

# Check if required options were provided
if [ -z "$projectsFolder" ] || [ -z "$outputPath" ]; then
  echo "Missing required arguments"
  echo "Usage: $0 -p <projects_folder> -o <output_path>"
  exit 1
fi

# Ensure the output directory exists
mkdir -p "$outputPath"
absoluteOutputPath=$(realpath "$outputPath")

# Navigate to the projects folder
cd "$projectsFolder" || { echo "Failed to navigate to directory: $projectsFolder"; exit 1; }

# Loop through each project directory
for projectDir in */ ; do
    projectName=$(basename "$projectDir")
    projectPath=$(realpath "$projectDir")

    echo "--- Processing root of $projectName ---"
    # Run strace -f go build at the project root and output to the unique file
    cd "$projectPath" && strace -f go build "$projectPath" >> "$absoluteOutputPath/$projectName-strace.txt" 2>&1
    
    cd - > /dev/null  # Go back to the projects folder without printing the working directory
    
    # Loop through each subdirectory within the project directory
    find "$projectPath" -mindepth 1 -type d \( -name .git -o -name .github \) -prune -o -type d -print | while read subDir; do
        subDirName=$(basename "$subDir")
        echo "- Processing subdirectory $subDirName"

        # Run strace -f go build in the subdirectory and output to the unique file
        cd "$subDir" && strace -f go build >> "$absoluteOutputPath/$projectName-strace.txt" 2>&1
        cd - > /dev/null  # Go back to the projects folder without printing the working directory
    done

    outputFile="${projectName}-pkg.txt"  # Construct the output file name

    # Process the file and output the results
    grep -e '/go/pkg/mod' -e 'openat' -e '@v' -e '.mod' "$absoluteOutputPath/$projectName-strace.txt" | 
    awk '/\/go\/pkg\/mod/ && /openat/ && /@v/ && /\.mod/' | 
    grep -oP '/go/pkg[^"]*' | 
    sed 's/.*\(\/go\/pkg[^"]*\).*/\1/' | 
    grep '\.mod$' | 
    sort | 
    uniq |
    sed 's/!/\\!/g' > "$absoluteOutputPath/$outputFile"

    echo "Output saved to $absoluteOutputPath/$outputFile"

    rm -f "$absoluteOutputPath/$projectName-strace.txt"

done

echo "--- All projects processed ---"
