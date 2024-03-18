#!/bin/bash

while getopts ":p:o:b:" opt; do
  case $opt in
    p) PROJECT_FOLDER="$OPTARG"
    ;;
    o) STRACE_OUTPUT_FOLDER="$OPTARG"
    ;;
    b) BUILD_OUTPUT_FOLDER="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Check if folders are set and exist
if [ -z "$PROJECT_FOLDER" ] || [ -z "$STRACE_OUTPUT_FOLDER" ] || [ -z "$BUILD_OUTPUT_FOLDER" ]; then
  echo "You must specify project folder (-p), strace output folder (-o), and build output folder (-b)."
  exit 1
fi

# Create output folders if they do not exist
mkdir -p "$STRACE_OUTPUT_FOLDER"
mkdir -p "$BUILD_OUTPUT_FOLDER"

# Iterate over each project in the project folder
for project_dir in "$PROJECT_FOLDER"/*; do
  if [ -d "$project_dir" ]; then
    project_name=$(basename "$project_dir")
    echo "Processing project: $project_name"

    # Prepare build directory for the current project
    project_build_dir="$BUILD_OUTPUT_FOLDER/$project_name/build"
    mkdir -p "$project_build_dir"

    # Navigate to project directory
    cd "$project_dir"

    # Run strace on the compile command, output to specified file in strace output folder
    strace_output_file="$STRACE_OUTPUT_FOLDER/$project_name-strace.txt"
    strace -o "$strace_output_file" make &> "$project_build_dir/compile_output.txt"

    echo "Strace output saved to $strace_output_file"
    echo "Build output saved to $project_build_dir/compile_output.txt"
  fi
done

echo "Processing complete."

