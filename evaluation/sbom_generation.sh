#!/bin/bash

# Initialize variables
projects_folder=""
output_path=""

# Parse options
while getopts "p:o:" opt; do
  case $opt in
    p)
      projects_folder=$OPTARG
      ;;
    o)
      output_path=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Check if required options were provided
if [ -z "$projects_folder" ] || [ -z "$output_path" ]; then
    echo "Usage: $0 -p /path/to/your/projects -o /path/to/output"
    exit 1
fi

# Ensure output directory exists
mkdir -p "$output_path"

# Navigate to the projects folder
cd "$projects_folder" || { echo "Failed to navigate to directory: $projects_folder"; exit 1; }

# Loop through each project directory
for project in */ ; do
    echo "Processing $project"
    cd "$project" || continue  # Enter the project directory

    # Define the output SBOM file path
    sbom_file="$output_path/${project%/}-sbom.json"

    # Run cdxgen and redirect stderr to stdout, then capture the output
    output=$(cdxgen -t go -o "$sbom_file" 2>&1)
    if echo "$output" | grep -q "go unexpectedly didn't return any output. Check if the correct version of golang is installed."; then
        echo "Error detected, deleting SBOM and $project, then skipping..."
        # Delete the SBOM file if it exists
        [ -f "$sbom_file" ] && rm -f "$sbom_file"
        cd ..
        rm -rf "$project"
        continue
    fi

    cd ..  # Go back to the projects folder
done

echo "All projects processed."
