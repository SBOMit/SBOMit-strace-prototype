#!/bin/bash

while getopts "p:n:o:" opt; do
  case $opt in
    p) projectPath=$OPTARG ;;
    n) projectName=$OPTARG ;;
    o) outputPath=$OPTARG ;;
    *) echo "Usage: $0 -p <go_project_path> -n <project_name> -o <output_path>"; exit 1 ;;
  esac
done

if [ -z "$projectPath" ] || [ -z "$projectName" ] || [ -z "$outputPath" ]; then
  echo "Missing required arguments"
  echo "Usage: $0 -p <go_project_path> -n <project_name> -o <output_path>"
  exit 1
fi

mkdir -p "$outputPath"
absoluteOutputPath=$(realpath "$outputPath")
cd "$projectPath" && strace -f go build &> "$absoluteOutputPath/$projectName-strace.txt"


