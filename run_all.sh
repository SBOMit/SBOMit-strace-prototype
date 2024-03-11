#!/bin/bash

# Initialize variables
projectsFolder=""
outputPath=""

# Parse options
while getopts "p:o:b:" opt; do
  case $opt in
    p) projectsFolder=$OPTARG ;;
    o) outputPath=$OPTARG ;;
    b) binaryOutputPath=$OPTARG ;;
    *) echo "Usage: $0 -p <projects_folder> -o <output_path>"; exit 1 ;;
  esac
done

# Check if required options were provided
if [ -z "$projectsFolder" ] || [ -z "$outputPath" ] || [ -z "$binaryOutputPath" ]; then
  echo "Missing required arguments"
  echo "Usage: $0 -p <projects_folder> -o <output_path> -b <binary_output_path>"
  exit 1
fi

# Ensure the output directory exists
mkdir -p "$outputPath"
mkdir -p "$binaryOutputPath"
absoluteOutputPath=$(realpath "$outputPath")
absoluteBinaryOutputPath=$(realpath "$binaryOutputPath")

# Navigate to the projects folder
cd "$projectsFolder" || { echo "Failed to navigate to directory: $projectsFolder"; exit 1; }

# Loop through each project directory
for projectDir in */ ; do
    projectName=$(basename "$projectDir")
    projectPath=$(realpath "$projectDir")
    projectBinaryOutputPath="$absoluteBinaryOutputPath/$projectName"

    mkdir -p "$projectBinaryOutputPath"

    echo "--- Processing root of $projectName ---"
    # Run strace -f go get and go build at the project root and output to the unique file
    cd "$projectPath" && strace -f -e openat go mod tidy >> "$absoluteOutputPath/$projectName-strace.txt" 2>&1 ; strace -f -e openat go build -o "$projectBinaryOutputPath/$projectName-OutBinary" >> "$absoluteOutputPath/$projectName-strace.txt" 2>&1

    cd - > /dev/null  # Go back to the projects folder without printing the working directory
    
    # Loop through each subdirectory within the project directory
    find "$projectPath" -mindepth 1 -type d \( -name .git -o -name .github \) -prune -o -type d -print | while read subDir; do
        subDirName=$(basename "$subDir")

        # Skip subdirectories containing specific keywords
        if [[ "$subDirName" =~ example|test|examples|tests ]]; then
            echo "- Skipping subdirectory $subDirName"
            continue
        fi

        echo "- Processing $subDirName, collecting syscalls"
        # Change directory to the subdirectory and run the syscalls
        (
          cd "$subDir" && \
          strace -f -e openat go mod tidy >> "$absoluteOutputPath/$projectName-strace.txt" 2>&1 ; \
          strace -f -e openat go build -o "$projectBinaryOutputPath/$subDirName-OutBinary" >> "$absoluteOutputPath/$projectName-strace.txt" 2>&1 \
          # go clean
        )

        # The subshell ensures that the 'cd' doesn't affect the outer loop
    done

    outputFile="${projectName}-pkg.txt"  # Construct the output file name

    tmp_file="$(mktemp)"

    # Process the file and output the results
    grep -v '/cache/' "$absoluteOutputPath/$projectName-strace.txt" |
    # grep -e '/go/pkg/mod' -e 'openat' -e '@v' -e '.mod' "$absoluteOutputPath/$projectName-strace.txt" | 
    grep -e '/go/pkg/mod' -e 'openat' -e '@v' -e '.mod'| 
    awk '/\/go\/pkg\/mod/ && /openat/ && /@v/ && /\.mod/' | 
    grep -oP '/go/pkg[^"]*' | 
    sed 's/.*\(\/go\/pkg[^"]*\).*/\1/' |
    grep '\.mod$' | 
    # sed -e 's#/go/pkg/mod/cache/download/##' \
    sed -e 's#/go/pkg/mod/##' \
    -e 's#/@v/v\([^/]*\)\.mod#@v\1#' \
    -e 's#/go\.mod##' |
    sort | 
    uniq |
    sed 's/!/\\!/g' > "$tmp_file"

    # Check if the tmp_file is empty
    if [ ! -s "$tmp_file" ]; then
        # The tmp_file is empty, so just ensure outputFile is created
        touch "$absoluteOutputPath/$outputFile"
    else
        # Process each line since tmp_file is not empty
        while IFS= read -r line; do
            # Capitalize the letter following "\!" and remove "\!"
            modifiedLine=$(echo "$line" | sed -r 's/(\\!)([a-z])/\1\u\2/g' | \
            sed 's/\\!//g')

            # Append the modified line to the outputFile
            echo "$modifiedLine" >> "$absoluteOutputPath/$outputFile"

        done < "$tmp_file"
    fi

    rm -f $tmp_file

    echo "Output saved to $absoluteOutputPath/$outputFile"

    rm -f "$absoluteOutputPath/$projectName-strace.txt"

done

echo "*** All projects processed ***"
