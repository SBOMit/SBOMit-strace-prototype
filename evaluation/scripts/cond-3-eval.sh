#!/bin/bash

# Initialize counters
total_projects=0
condition_0=0
condition_1=0
condition_2=0
condition_3=0

# Parse command-line options
while getopts s:p: flag
do
    case "${flag}" in
        s) sbom_folder=${OPTARG};;
        p) pkg_folder=${OPTARG};;
    esac
done

# Check if both folders are provided
if [ -z "$sbom_folder" ] || [ -z "$pkg_folder" ]; then
    echo "Usage: $0 -s <path_to_sbom_folder> -p <path_to_pkg_folder>"
    exit 1
fi

# Get sorted list of files in each folder
sbom_files=($(find "$sbom_folder" -type f -name "*.json" -print | awk -F/ '{print $(NF), $0}' | sed 's/-sbom.json//' | sort -k1,1 | cut -d' ' -f2-))
pkg_files=($(find "$pkg_folder" -type f -name "*.txt" -print | awk -F/ '{print $(NF), $0}' | sed 's/-pkg.txt//' | sort -k1,1 | cut -d' ' -f2-))

# Iterate over the indices of the arrays
for ((i = 0; i < ${#sbom_files[@]}; i++)); do
    # Extract project name from file names
    project_name_sbom=$(basename "${sbom_files[$i]}" "-sbom.json")
    project_name_pkg=$(basename "${pkg_files[$i]}" "-pkg.txt")

    # Check if project names match
    if [ "$project_name_sbom" != "$project_name_pkg" ]; then
        echo "Error: SBOM file ${sbom_files[$i]} and package file ${pkg_files[$i]} are for different projects."
        exit 1
    fi

    echo "----------------------------------------------------------------"
    echo "Processing project: $project_name_sbom"
    echo "Processing SBOM file: ${sbom_files[$i]}"
    echo "Processing package file: ${pkg_files[$i]}"
    
    # Execute the Python script and capture the output
    output=$(python3 cond-3-compare_analysis.py "${sbom_files[$i]}" "${pkg_files[$i]}")
    echo "$output"

    # Extract the condition from the output
    condition=$(echo "$output" | grep 'Condition:' | awk '{print $NF}')
    
    # Increment the total projects counter
    ((total_projects++))
    
    # Increment the appropriate condition counter
    case "$condition" in
        0) ((condition_0++));;
        1) ((condition_1++));;
        2) ((condition_2++));;
        3) 
            ((condition_3++))
            # If condition 3, print out the differences captured from the Python script
            # echo "$output" | grep 'Unique in'
            ;;
    esac

done

# Print out the totals
echo "****************************************************************"
echo "Total projects processed: $total_projects"
echo "Total Condition 0 (CDX tool = SBOMit-strace-prototype): $condition_0"
echo "Total Condition 1 (CDX tool > SBOMit-strace-prototype): $condition_1"
echo "Total Condition 2 (CDX tool < SBOMit-strace-prototype): $condition_2"
echo "Total Condition 3 (Mismatched): $condition_3"

