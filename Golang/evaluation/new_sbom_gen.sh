#!/bin/bash

# Initialize variables with default values
COMBINE_PKGS_DIR=""
GOLANG_PROJECTS_DIR=""
NEW_SBOMS_DIR=""

# Function to show usage
usage() {
    echo "Usage: $0 -c <combine_pkgs_directory> -g <golang_projects_directory> -n <new_sboms_directory>"
    exit 1
}

# Parse command-line options
while getopts "c:g:n:" opt; do
  case ${opt} in
    c ) COMBINE_PKGS_DIR=$OPTARG ;;
    g ) GOLANG_PROJECTS_DIR=$OPTARG ;;
    n ) NEW_SBOMS_DIR=$OPTARG ;;
    \? ) usage ;;
  esac
done

# Check if the directory paths are not empty
if [ -z "$COMBINE_PKGS_DIR" ] || [ -z "$GOLANG_PROJECTS_DIR" ] || [ -z "$NEW_SBOMS_DIR" ]; then
    usage
fi

# Check if the directories exist
if [ ! -d "$COMBINE_PKGS_DIR" ] || [ ! -d "$GOLANG_PROJECTS_DIR" ] || [ ! -d "$NEW_SBOMS_DIR" ]; then
    echo "One or more specified directories do not exist."
    exit 1
fi

# Path to your SBOM generation script
SBOM_GEN_SCRIPT="./golang-ir-sbom-gen.sh"

# Check if the SBOM generation script exists
if [ ! -f "$SBOM_GEN_SCRIPT" ]; then
    echo "SBOM generation script not found: $SBOM_GEN_SCRIPT"
    exit 1
fi

# Iterate over each project directory in eval-combine-pkgs
for PROJECT_DIR in "$COMBINE_PKGS_DIR"/*; do
    if [ -d "$PROJECT_DIR" ]; then
        # Extract the project name
        PROJECT_NAME=$(basename "$PROJECT_DIR")

        # Define file and directory paths for the current project
        DEP_FILE="$PROJECT_DIR/${PROJECT_NAME}-combine-pkgs.txt"
        GO_MOD_FILE="$GOLANG_PROJECTS_DIR/$PROJECT_NAME/go.mod"
        OUTPUT_DIR="$NEW_SBOMS_DIR/$PROJECT_NAME"

        # Check if the dependency file and go.mod file exist
        if [ ! -f "$DEP_FILE" ] || [ ! -f "$GO_MOD_FILE" ]; then
            echo "Dependencies file or go.mod file missing for project $PROJECT_NAME. Aborting..."
            exit 1
        fi

        # Run the SBOM generation script for the current project
        echo "Generating SBOM for project: $PROJECT_NAME"
        $SBOM_GEN_SCRIPT -d "$DEP_FILE" -m "$GO_MOD_FILE" -o "$OUTPUT_DIR"
        echo "SBOM generation completed for project: $PROJECT_NAME"
    fi
done