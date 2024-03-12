#!/bin/bash

# Initialize counters
total_projects=0
condition_0=0
condition_1=0
condition_2=0
condition_3=0

# Initialize variables for folder paths
pkg_folder=""
bin_pkg_folder=""

# Parse command-line options
while getopts "p:b:" flag; do
    case "${flag}" in
        p) pkg_folder=${OPTARG};;
        b) bin_pkg_folder=${OPTARG};;
    esac
done

# Check if both folders are provided
if [ -z "$pkg_folder" ] || [ -z "$bin_pkg_folder" ]; then
    echo "Both package folder (-p) and binary package folder (-b) are required."
    exit 1
fi

# Find and sort package files
pkg_files=($(find "$pkg_folder" -type f -name "*.txt" -print | awk -F/ '{print $(NF), $0}' | sed 's/-pkg.txt//' | sort -k1,1 | cut -d' ' -f2-))

# Find and sort binary package files
bin_pkg_files=($(find "$bin_pkg_folder" -type f -name "*.txt" -print | awk -F/ '{print $(NF), $0}' | sed 's/-bins-pkg.txt//' | sort -k1,1 | cut -d' ' -f2-))

# Ensure the number of files in both directories is the same
if [ ${#pkg_files[@]} -ne ${#bin_pkg_files[@]} ]; then
    echo "Error: The number of package files and binary package files do not match."
    exit 1
fi

# Iterate over the indices of the arrays
for ((i = 0; i < ${#pkg_files[@]}; i++)); do
    # Extract project names from file names
    project_name_pkg=$(basename "${pkg_files[$i]}" "-pkg.txt")
    project_name_bin_pkg=$(basename "${bin_pkg_files[$i]}" "-bins-pkg.txt")

    # Check if project names match
    if [ "$project_name_pkg" != "$project_name_bin_pkg" ]; then
        echo "Error: Package file ${pkg_files[$i]} and binary package file ${bin_pkg_files[$i]} are for different projects."
        exit 1
    fi

    echo "----------------------------------------------------------------"
    echo "Processing project: $project_name_pkg"
    echo "Processing package file: ${pkg_files[$i]}"
    echo "Processing binary package file: ${bin_pkg_files[$i]}"
    
    # Execute the Python script and capture the output
    output=$(python3 compare_pkgs_analysis.py "${bin_pkg_files[$i]}" "${pkg_files[$i]}")
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
        3) ((condition_3++));;
    esac
done

# Print out the totals
echo "****************************************************************"
echo "Total projects processed: $total_projects"
echo "Total Condition 0 (Binary Package = SBOMit-strace-prototype): $condition_0"
echo "Total Condition 1 (Binary Package > SBOMit-strace-prototype): $condition_1"
echo "Total Condition 2 (Binary Package < SBOMit-strace-prototype): $condition_2"
echo "Total Condition 3 (Mismatched): $condition_3"