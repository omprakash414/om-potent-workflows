#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 <username> <ip_suffix> <source_path> [destination_path]"
    echo "Example: $0 om 16.203 /path/to/source /path/to/destination"
    echo "Note: If the destination path is not provided, it will default to /home/<username>"
    exit 1
}

# Check if at least three arguments are provided
if [ $# -lt 3 ]; then
    echo "Error: Missing arguments."
    usage
fi

# Assign arguments to variables
username_input="$1"
ip_suffix="$2"
source_path="$3"
destination_path="$4"

# Validate and set username and password based on input
case "$username_input" in
    om)
        username="omprakash"
        password="797780@Om"
        ;;
    sakshi)
        username="sakshi"
        password="836575@Sa"
        ;;
    *)
        echo "Error: Invalid username input"
        usage
        ;;
esac

# Validate and set server_ip based on IP suffix
case "$ip_suffix" in
    16.203)
        server_ip="192.168.16.203"
        ;;
    17.41)
        server_ip="192.168.17.41"
        ;;
    3.133)
        server_ip="192.168.3.133"
        ;;
    3.89)
        server_ip="192.168.3.89"
        ;;
    *)
        echo "Error: Invalid IP suffix"
        usage
        ;;
esac

# Set default destination path if not provided
if [ -z "$destination_path" ]; then
    destination_path="/home/$username"
fi

# Transfer file/folder using scp
sshpass -p "$password" scp -r "$source_path" "$username"@"$server_ip":"$destination_path"

# Exit with a success message
if [ $? -eq 0 ]; then
    echo "Transfer completed successfully."
else
    echo "Transfer failed."
    exit 1
fi
