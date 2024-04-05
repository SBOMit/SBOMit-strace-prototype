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

# Extract replacements into a temp file
TEMP_REPLACE=$(mktemp)
grep 'replace' "$GO_MOD_FILE" | cut -d'>' -f2 | cut -d' ' -f2- > "$TEMP_REPLACE"

# Add a new require block at the end of the copied go.mod file
echo -e "\nsbomit_require (" >> "$OUTPUT_DIR/go.mod"
echo ")" >> "$OUTPUT_DIR/go.mod"

echo "Processing dependencies..."

while IFS= read -r line; do
    if [ -z "$line" ]; then
        continue
    fi

    PACKAGE=$(echo "$line" | awk -F "@" '{print $1}')
    VERSION=$(echo "$line" | awk -F "@" '{print $2}')

    if [ -z "$VERSION" ]; then
        echo "Skipping $PACKAGE, no version specified."
        continue
    fi

    # Skip if PACKAGE is listed in the replacements temp file
    if grep -q -F "$PACKAGE" "$TEMP_REPLACE"; then
        echo "Skipping $PACKAGE as it is listed in a replace directive."
        continue
    fi

    sed -i "/^sbomit_require (/a \    $PACKAGE $VERSION" "$OUTPUT_DIR/go.mod"
    echo "Added $PACKAGE $VERSION to the SBOMit IR file."
    
done < "$DEP_FILE"

sed -i 's/sbomit_require/require/g' "$OUTPUT_DIR/go.mod"

echo "New go.mod has been processed and saved to $OUTPUT_DIR."

cd "$OUTPUT_DIR"

go mod download

cdxgen -t go.mod -o "${PROJECT_NAME}-sbom.json"

echo "SBOM has been generated and saved as ${PROJECT_NAME}-sbom.json."

# Cleanup the temp replacements file
rm "$TEMP_REPLACE"
