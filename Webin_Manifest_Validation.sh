#!/bin/bash

# Usage check
if [ $# -ne 2 ]; then
    echo "Usage: $0 <path/to/manifest_directory> <filename_pattern>"
    echo "Example: $0 /storage/omprakash/AIIMS_URO/Metagenomic_Reads_80 'ERS246885*.manifest'"
    exit 1
fi

MANIFEST_DIR="$1"
PATTERN="$2"

if [ ! -d "$MANIFEST_DIR" ]; then
    echo "ERROR: Directory not found: $MANIFEST_DIR"
    exit 1
fi

# Loop over all matching manifest files
for MANIFEST in "$MANIFEST_DIR"/$PATTERN; do
    if [ ! -f "$MANIFEST" ]; then
        echo "No files matching pattern $PATTERN found in $MANIFEST_DIR"
        continue
    fi

    echo "🔹 Validating: $MANIFEST"

    java -jar webin-cli-9.0.1.jar \
        -context reads \
        -manifest "$MANIFEST" \
        -inputDir "$MANIFEST_DIR" \
        -userName  vineet.aiims@gmail.com \
        -password 'IBD@AIIMS123' \
        -centerName 'AIIMSDelhi;IIITD' \
        -validate

    echo "✅ Done validating $MANIFEST"
    echo ""
done

# Omprakash ids:
# Webin-70170 
# 797780@Omprakash
echo "🎉 Validation completed for all matching manifest files."
