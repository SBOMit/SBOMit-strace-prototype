#!/bin/bash

# Initialize variables for file paths
DEP_FILE=""
GO_MOD_FILE=""

# Function to show usage
usage() {
    echo "Usage: $0 -d <dependency_file_path> -m <go_mod_file_path>"
    exit 1
}

# Parse command-line options
while getopts "d:m:" opt; do
  case ${opt} in
    d )
      DEP_FILE=$OPTARG
      ;;
    m )
      GO_MOD_FILE=$OPTARG
      ;;
    \? )
      usage
      ;;
  esac
done

# Check if the file paths are not empty
if [ -z "$DEP_FILE" ] || [ -z "$GO_MOD_FILE" ]; then
    usage
fi

# Ensure both files exist
if [ ! -f "$DEP_FILE" ] || [ ! -f "$GO_MOD_FILE" ]; then
    echo "Dependencies file or go.mod file is missing."
    exit 1
fi

# Backup the original go.mod file
cp "$GO_MOD_FILE" "${GO_MOD_FILE}.bak"

# Add a new require block at the end of the go.mod file
echo -e "\nrequire (" >> "$GO_MOD_FILE"
echo ")" >> "$GO_MOD_FILE"

# Record the position to insert dependencies before the closing parenthesis
INSERT_POINT=$(wc -l < "$GO_MOD_FILE")

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

    # Check if the package is already in the go.mod file
    if grep -q "$PACKAGE" "$GO_MOD_FILE"; then
        echo "$PACKAGE is already in go.mod, skipping..."
    else
        # Directly append the new dependency before the last line of the go.mod file
        sed -i "${INSERT_POINT}i\    $PACKAGE $VERSION" "$GO_MOD_FILE"
        echo "Added $PACKAGE $VERSION to the new require block."
        # Increment INSERT_POINT for next insertion
        ((INSERT_POINT++))
    fi
done < "$DEP_FILE"

echo "Dependencies have been processed."

