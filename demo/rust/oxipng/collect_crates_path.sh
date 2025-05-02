#!/bin/bash

# This script reads a list of crate names and versions from deps.txt,
# then copies the corresponding source directories into crate-sources/.

set -e

INPUT_FILE="deps.txt"
OUTPUT_DIR="crate-sources"
OUTPUT_LIST="crate-sources.txt"

mkdir -p "$OUTPUT_DIR"
> "$OUTPUT_LIST"

while read -r name version; do
  path=$(find ~/.cargo/registry/src -type d -name "${name}-${version}" | head -n 1)
  if [ -n "$path" ]; then
    echo "Found: $path"
    echo "$path" >> "$OUTPUT_LIST"
    cp -r "$path" "$OUTPUT_DIR/"
  else
    echo "Warning: Crate ${name}-${version} not found"
  fi
done < "$INPUT_FILE"

echo "Done. Crate sources copied to: $OUTPUT_DIR/"

