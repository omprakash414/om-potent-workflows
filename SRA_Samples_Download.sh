#!/bin/bash


# Exit on error
set -e

# Help message
print_help() {
    echo "Usage: $0 [OPTIONS] path/to/file.xlsx|.tsv"
    echo ""
    echo "This script reads an Excel (.xlsx) or TSV (.tsv) file containing"
    echo "SRA accession numbers under a column named 'Run', downloads the data"
    echo "using 'prefetch', and converts it to gzipped FASTQ files using 'fasterq-dump'."
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message and exit"
    echo ""
    echo "Requirements:"
    echo "  - Python 3 with pandas"
    echo "  - SRA Toolkit (prefetch, fasterq-dump)"
    echo "  - xargs"
    echo ""
    echo "Example:"
    echo "  $0 my_samples.xlsx"
    echo "  $0 my_samples.tsv"
    exit 0
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    print_help
fi

# Check dependencies
for cmd in xargs prefetch fasterq-dump; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: '$cmd' is not installed or not in PATH."
        exit 1
    fi
done

# Check Python and pandas for reading .xlsx
if ! python3 -c "import pandas" &> /dev/null; then
    echo "Error: Python3 with pandas is required to extract data."
    exit 1
fi

# Input file
INPUT_FILE="$1"

if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 path/to/file.xlsx|.tsv"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File not found: $INPUT_FILE"
    exit 1
fi

# Extract accession list to accessions.txt
echo "Extracting accessions from $INPUT_FILE..."

python3 <<EOF
import pandas as pd
import sys

file = "$INPUT_FILE"
if file.endswith(".xlsx"):
    df = pd.read_excel(file)
elif file.endswith(".tsv"):
    df = pd.read_csv(file, sep="\t")
else:
    print("Unsupported file type. Use .xlsx or .tsv", file=sys.stderr)
    sys.exit(1)

if "Run" not in df.columns:
    print("No 'Run' column found in the file", file=sys.stderr)
    sys.exit(1)

df["Run"].dropna().to_csv("accessions.txt", index=False, header=False)
EOF

echo "Saved accessions to accessions.txt"

# Download .sra files using prefetch
echo "Downloading SRA files..."
cat accessions.txt | xargs prefetch

# Convert to FASTQ files
# Convert to FASTQ files
echo "Converting to FASTQ with fasterq-dump..."
for acc in $(cat accessions.txt); do
    echo "Downloading $acc..."
    prefetch "$acc"

    echo "Converting $acc to FASTQ..."
    fasterq-dump --split-files --threads 30 "$acc"

    echo "Compressing FASTQ files for $acc..."
    gzip "${acc}"_*.fastq

    # Remove the directory created by prefetch
    echo "Removing directory for $acc..."
    rm -r "${acc}"

    echo "Done with $acc"
done

echo "Done: All FASTQ files are ready."
