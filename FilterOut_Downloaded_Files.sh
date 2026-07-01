#!/bin/bash

# Help section
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat << EOF
Usage: $0 <downloaded_file_list> <wget_script_file> > <output_file>

Description:
  This script filters out wget commands for files that have already been downloaded.
  It compares a list of already downloaded filenames against a script containing wget commands,
  and outputs only those commands for files that are not yet downloaded.

Arguments:
  downloaded_file_list     A file (e.g., downloaded.sh) with one downloaded filename per line.
  wget_script_file         A shell script file (e.g., PRJNA1234.sh) containing wget commands.

Output:
  The remaining wget commands (i.e., those whose files haven't been downloaded) are printed to stdout.
  You should redirect this output to a file using '>'.

Example:
  ./filter_missing_downloads.sh downloaded.sh PRJNA1234.sh > remaining_to_download.sh

EOF
    exit 0
fi

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Error: Invalid number of arguments." >&2
    echo "Use -h or --help for usage information." >&2
    exit 1
fi

downloaded_file="$1"
wget_script="$2"

# Main logic
awk '
FNR==NR { downloaded[$1]; next }
{
    split($NF, path_parts, "/");
    filename = path_parts[length(path_parts)];
    if (!(filename in downloaded)) print
}
' "$downloaded_file" "$wget_script"
