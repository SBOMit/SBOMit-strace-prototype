#!/bin/bash

# Initialize variables
DEP_FILE=""
RUST_CARGO_FILE=""
OUTPUT_DIR=""

# Function to show usage
usage() {
    echo "Usage: $0 -d <dependency_file_path> -m <rust_cargo_file_path> -o <output_folder_path>"
    exit 1
}

# Parse command-line options
while getopts "d:m:o:" opt; do
  case ${opt} in
    d ) DEP_FILE=$OPTARG ;;
    m ) RUST_CARGO_FILE=$OPTARG ;;
    o ) OUTPUT_DIR=$OPTARG ;;
    \? ) usage ;;
  esac
done

# Validate required inputs
if [ -z "$DEP_FILE" ] || [ -z "$RUST_CARGO_FILE" ] || [ -z "$OUTPUT_DIR" ]; then
    usage
fi

# Ensure both files exist
if [ ! -f "$DEP_FILE" ] || [ ! -f "$RUST_CARGO_FILE" ]; then
    echo "Dependencies file or Cargo.toml file is missing."
    exit 1
fi

# Create the output directory if it doesn't exist
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Extract project name from OUTPUT_DIR
PROJECT_NAME=$(basename "$OUTPUT_DIR")

# Copy the original Cargo.toml file to the output directory
cp "$RUST_CARGO_FILE" "$OUTPUT_DIR/Cargo.toml"
CARGO_TOML_PATH="$OUTPUT_DIR/Cargo.toml"

# add the [SBOMit_dependencies] field
echo -e "\n[SBOMit_dependencies]" >> "$CARGO_TOML_PATH"

echo "Processing dependencies..."

while IFS= read -r line; do
    if [ -z "$line" ]; then
        continue
    fi

    PACKAGE=$(echo "$line" | awk -F "@" '{print $1}')
    VERSION=$(echo "$line" | awk -F "@" '{print $2}')

    # Append dependency to DEPS_TO_ADD
    echo "$PACKAGE = \"$VERSION\"" >> "$CARGO_TOML_PATH"

    echo "Added $PACKAGE $VERSION to the SBOMit IR file."
    
done < "$DEP_FILE"

# After appending all dependencies, rename [SBOMit_dependencies] to [dependencies]
sed -i 's/\[SBOMit_dependencies\]/\[dependencies\]/' "$CARGO_TOML_PATH"

echo "New Cargo.toml has been processed and saved to $OUTPUT_DIR."

cd "$OUTPUT_DIR"

cdxgen -t rust -o "${PROJECT_NAME}-sbom.json"

echo "SBOM has been generated and saved as ${PROJECT_NAME}-sbom.json."
