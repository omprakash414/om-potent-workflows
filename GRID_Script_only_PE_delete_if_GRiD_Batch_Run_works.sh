#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: bash GRID_Script.sh <input_file> [<num_threads>]"

    echo ""
    echo "Options:"
    echo "  <input_file>   Path to the input file containing sample information (required)"
    echo "  <num_threads>  Number of threads for GRID (optional, default: 16)"
    echo ""
    echo "Description:"
    echo "This script processes paired-end FASTQ files listed in the input file."
    echo "For each sample, it will create an output folder and run the 'GRID' command."
    echo ""
    echo "Input file format (tab-separated):"
    echo "Each line in the input file should have the following format:"
    echo "  <read_one> <tab> <read_two>"
    echo "Example:"
    echo "  ERR6634882_1.fastq.gz    ERR6634882_2.fastq.gz"
    echo "  ERR6634883_1.fastq.gz    ERR6634883_2.fastq.gz"
    echo ""
    echo "Example usage:"
    echo "  bash GRID_Script.sh samples.txt 20"
}

# Default values
num_threads=16
input_file=""

# Parse the input file and number of threads (if provided)
if [[ $# -lt 1 ]]; then
    echo "Error: Input file is required."
    show_help
    exit 1
fi

input_file="$1"

# Check if the number of threads is provided (optional)
if [[ $# -ge 2 ]]; then
    num_threads="$2"
fi


echo "Number of threads: $num_threads"  

# Check if input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' does not exist."
    exit 1
fi
echo "Input file: $input_file"
# Read the input file line by line
while IFS=$'\t' read -r read_one read_two; do
    # Extract the base name from the first file path (e.g., ERR6634882 from ERR6634882_1.fastq.gz)
    base_name=$(basename "$read_one" | cut -d'_' -f1)
    
    echo "Processing sample: $base_name"

    # Create a directory for this sample if it doesn't already exist
    output_dir="$base_name"
    mkdir -p "$output_dir"
    
    pigz -dc --fast -p "$num_threads" "$read_one" "$read_two" > "$base_name.fastq"
    echo "Decompressed sample: $base_name"

    # Run the grid command with the specified arguments
    grid multiplex -r . -e fastq -o "$output_dir" -d /home/omprakash/GRID_DB/test_GRID_DB/index/ -c 0.2 -p -n "$num_threads"
    rm *.fastq
    echo "Processed sample: $base_name"

done < "$input_file"