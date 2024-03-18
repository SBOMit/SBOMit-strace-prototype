#!/bin/bash

while getopts ":p:o:b:" opt; do
  case $opt in
    p) projects_folder="$OPTARG"
    ;;
    o) strace_output_folder="$OPTARG"
    ;;
    b) build_output_folder="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Check if the required tools are installed
if ! command -v strace &> /dev/null
then
    echo "strace could not be found, please install it."
    exit
fi

if ! command -v make &> /dev/null
then
    echo "make could not be found, please install it."
    exit
fi

if ! command -v cmake &> /dev/null
then
    echo "cmake could not be found, please install it."
    exit
fi

# Creating the output directories if they don't exist
mkdir -p "$strace_output_folder"
mkdir -p "$build_output_folder"

# Resolve absolute paths
projects_folder=$(readlink -f "$projects_folder")
strace_output_folder=$(readlink -f "$strace_output_folder")
build_output_folder=$(readlink -f "$build_output_folder")

# Loop through each project in the projects folder
for project_path in "$projects_folder"/*; do
  if [ -d "$project_path" ]; then
    project_name=$(basename "$project_path")
    echo "Processing project: $project_name"
    
    # Creating build directory inside the specified build output folder
    project_build_path="$build_output_folder/$project_name/build"
    mkdir -p "$project_build_path"

    strace_output_file="$strace_output_folder/$project_name-strace.log"
    
    # Decide whether to use cmake or make based on the presence of CMakeLists.txt
    build_command=""
    if [ -f "$project_path/CMakeLists.txt" ]; then
      echo "Using cmake to build $project_name"
      (cd "$project_build_path"; strace -f cmake "$project_path" >> "$strace_output_file" 2>&1 && strace -f make -j4 >> "$strace_output_file" 2>&1)
    else
      echo "Using make to build $project_name"
      (cd "$project_build_path"; strace -f make "$project_path" -j4 > "$strace_output_file" 2>&1)
    fi
  fi
done

echo "Processing completed."
