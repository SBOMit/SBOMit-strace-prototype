#!/bin/bash

# Initialize variables for folder paths
sbom_folder=""
pkg_folder=""
bin_pkg_folder=""
output_folder=""

# Parse command-line options
while getopts "s:p:b:o:" flag; do
    case "${flag}" in
        s) sbom_folder=${OPTARG};;
        p) pkg_folder=${OPTARG};;
        b) bin_pkg_folder=${OPTARG};;
        o) output_folder=${OPTARG};;
    esac
done

# Check if SBOM folder and output folder are provided
if [ -z "$sbom_folder" ] || [ -z "$output_folder" ]; then
    echo "SBOM folder and output folder are required. Usage: $0 -s <path_to_sbom_folder> [-p <path_to_pkg_folder> | -b <path_to_bin_pkg_folder>] -o <path_to_output_folder>"
    exit 1
fi

# Ensure only one of -p or -b is provided
if [ ! -z "$pkg_folder" ] && [ ! -z "$bin_pkg_folder" ]; then
    echo "Only one of -p or -b should be provided, not both."
    exit 1
fi

# Find SBOM files
sbom_files=($(find "$sbom_folder" -type f -name "*.json" -print))

# Decide which find command to use based on provided options
if [ ! -z "$pkg_folder" ]; then
    echo "Using -p option"
    pkg_files=($(find "$pkg_folder" -type f -name "*.txt" -print))
elif [ ! -z "$bin_pkg_folder" ]; then
    echo "Using -b option"
    pkg_files=($(find "$bin_pkg_folder" -type f -name "*.txt" -print))
else
    echo "Either a package folder (-p) or a binary package folder (-b) is required."
    exit 1
fi

# Check if output folder exists, if not create it
if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

# Iterate over SBOM files
for sbom_file in "${sbom_files[@]}"; do
    # Extract project name from SBOM file name
    project_name=$(basename "$sbom_file" "-sbom.json")
    projectPkgsOutputPath="$output_folder/$projectName"

    mkdir -p "$projectPkgsOutputPath"

    # Find the corresponding package file
    pkg_file=""
    for file in "${pkg_files[@]}"; do
        if [[ "$file" == *"$project_name"* ]]; then
            pkg_file="$file"
            break
        fi
    done

    # Skip if no matching package file is found
    if [ -z "$pkg_file" ]; then
        echo "No matching package file found for $project_name, skipping."
        continue
    fi

    echo "----------------------------------------------------------------"
    echo "Processing project: $project_name"
    echo "SBOM file: $sbom_file"
    echo "Package file: $pkg_file"
    
    # Define the output file path
    output_file="$output_folder/${project_name}-analysis.txt"

    # Execute the Python script
    python3 compare_analysis.py "$sbom_file" "$pkg_file" "$bin_pkg_folder" > "$projectPkgsOutputPath"
    echo "Output saved to $output_file"

    # Here you should implement the logic to update condition counters based on the Python script output
    # This part is left as an exercise, assuming the Python script outputs condition information

done

# Print out the totals
# Update this section accordingly based on the new logic for condition counters
echo "****************************************************************"
echo "Total projects processed: $total_projects"
# Add more echo statements for condition counters if necessary
