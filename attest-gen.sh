#!/bin/bash

while getopts "p:k:d:" opt; do
  case $opt in
    p) inputFile=$OPTARG ;;
    k) signingKey=$OPTARG ;;
    d) outputDir=$OPTARG ;;
    *) echo "Usage: $0 -p <input_file> -k <signing_key> -d <output_dir>"; exit 1 ;;
  esac
done

if [ -z "$inputFile" ] || [ -z "$signingKey" ] || [ -z "$outputDir" ]; then
  echo "Missing required arguments"
  echo "Usage: $0 -p <input_file> -k <signing_key> -d <output_dir>"
  exit 1
fi

while IFS= read -r filePath; do
    fullPath="$HOME$filePath"
    stepPerformed="validate$(echo "$filePath" | sed 's/\//-/g')"
    in-toto-run -m "$fullPath" -n "$stepPerformed" --signing-key "$signingKey" -d "$outputDir" -- cat "$fullPath"
done < "$inputFile"
