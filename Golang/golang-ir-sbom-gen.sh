#!/bin/bash

# Initialize variables
DEP_FILE=""
GO_MOD_FILE=""
OUTPUT_DIR=""

# Function to show usage
usage() {
    echo "Usage: $0 -d <dependency_file_path> -m <go_mod_file_path> -o <output_folder_path>"
    exit 1
}

# Parse command-line options
while getopts "d:m:o:" opt; do
  case ${opt} in
    d ) DEP_FILE=$OPTARG ;;
    m ) GO_MOD_FILE=$OPTARG ;;
    o ) OUTPUT_DIR=$OPTARG ;;
    \? ) usage ;;
  esac
done

# Validate required inputs
if [ -z "$DEP_FILE" ] || [ -z "$GO_MOD_FILE" ] || [ -z "$OUTPUT_DIR" ]; then
    usage
fi

# Ensure both files exist
if [ ! -f "$DEP_FILE" ] || [ ! -f "$GO_MOD_FILE" ]; then
    echo "Dependencies file or go.mod file is missing."
    exit 1
fi

# Create the output directory if it doesn't exist
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Extract project name from OUTPUT_DIR
PROJECT_NAME=$(basename "$OUTPUT_DIR")

# Copy the original go.mod file to the output directory
cp "$GO_MOD_FILE" "$OUTPUT_DIR/go.mod"

# Add a new require block at the end of the copied go.mod file
echo -e "\nsbomit_require (" >> "$OUTPUT_DIR/go.mod"
echo ")" >> "$OUTPUT_DIR/go.mod"

# Start processing the dependencies
echo "Processing dependencies..."

while IFS= read -r line; do
    # Skip empty lines and lines not containing github.com or golang.org
    if [[ -z "$line" ]]; then
        continue
    fi

    # Extract the package name and version
    PACKAGE=$(echo "$line" | awk -F "@" '{print $1}')
    VERSION=$(echo "$line" | awk -F "@" '{print $2}')

    # Skip if VERSION is empty
    if [ -z "$VERSION" ]; then
        echo "Skipping $PACKAGE, no version specified."
        continue
    fi

    # Insert the new dependency into the new require block, before the last closing parenthesis
    sed -i "/^sbomit_require (/a \    $PACKAGE $VERSION" "$OUTPUT_DIR/go.mod"
    echo "Added $PACKAGE $VERSION to the new require block."
    
done < "$DEP_FILE"

# Replace 'sbomit_require' with 'require' in the copied go.mod file
sed -i 's/sbomit_require/require/g' "$OUTPUT_DIR/go.mod"

echo "New go.mod has been processed and saved to $OUTPUT_DIR."

# Change to the output directory
cd "$OUTPUT_DIR"

# Run go mod download to fetch the modules
go mod download

# Generate SBOM using cdxgen
cdxgen -t go.mod -o "${PROJECT_NAME}-sbom.json"

echo "SBOM has been generated and saved as ${PROJECT_NAME}-sbom.json."