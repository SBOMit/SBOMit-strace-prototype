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
if [ -z "$sbom_folder" ] || [ -z "$pkg_folder" ] || [ -z "$bin_pkg_folder" ] || [ -z "$output_folder" ]; then
    echo "SBOM folder and output folder are required. Usage: $0 -s <path_to_sbom_folder> [-p <path_to_pkg_folder> | -b <path_to_bin_pkg_folder>] -o <path_to_output_folder>"
    exit 1
fi

# Find and sort SBOM files
sbom_files=($(find "$sbom_folder" -type f -name "*.json" -print | awk -F/ '{print $(NF), $0}' | sed 's/-sbom.json//' | sort -k1,1 | cut -d' ' -f2-))

# Find and sort pkg files
pkg_files=($(find "$pkg_folder" -type f -name "*.txt" -print | awk -F/ '{print $(NF), $0}' | sed 's/-pkg.txt//' | sort -k1,1 | cut -d' ' -f2-))

# Find and sort bin-pkg files
bin_pkg_files=($(find "$bin_pkg_folder" -type f -name "*.txt" -print | awk -F/ '{print $(NF), $0}' | sed 's/-bins-pkg.txt//' | sort -k1,1 | cut -d' ' -f2-))

# Check if output folder exists, if not create it
if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

# Iterate over SBOM files
for ((i = 0; i < ${#sbom_files[@]}; i++)); do
    # Extract project name from SBOM file name
    project_name_sbom=$(basename "${sbom_files[$i]}" "-sbom.json")
    
    projectPkgsOutputPath="$output_folder/$project_name_sbom"
    mkdir -p "$projectPkgsOutputPath"

    project_name_bin_pkg=$(basename "${bin_pkg_files[$i]}" "-bins-pkg.txt")
    project_name_pkg=$(basename "${pkg_files[$i]}" "-pkg.txt")

    # Check if project names match
    if [[ -n "$project_name_pkg" && "$project_name_sbom" != "$project_name_pkg" ]] || 
    [[ -n "$project_name_bin_pkg" && "$project_name_sbom" != "$project_name_bin_pkg" ]]; then
        echo "Error: SBOM file ${sbom_files[$i]} does not match package file ${pkg_files[$i]} for project $project_name_sbom."
        exit 1
    fi

    sbom_file="${sbom_files[$i]}"
    pkg_file="${pkg_files[$i]}"
    bin_pkg_file="${bin_pkg_files[$i]}"

    echo "----------------------------------------------------------------"
    echo "Processing project: $project_name_sbom"
    echo "Processing SBOM file: $sbom_file"
    echo "Processing package file: $pkg_file"
    echo "Processing bin-package file: $bin_pkg_file"

    # Define the output file name and path correctly
    output_file="$projectPkgsOutputPath/${project_name_sbom}-combine-pkgs.txt"

    # Corrected the command to output the result to the specific output file
    python3 combine_pkgs.py "$sbom_file" "$pkg_file" "$bin_pkg_file" > "$output_file"
    echo "Output saved to $output_file"

done