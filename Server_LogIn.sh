#!/bin/bash

# Function to prompt for input if not provided as arguments
prompt_for_input() {
    if [ -z "$username_input" ]; then
        read -p "Enter username (om/sakshi): " username_input
    fi
    if [ -z "$ip_suffix" ]; then
        read -p "Enter IP suffix (e.g., 16.203): " ip_suffix
    fi
}

# Check if arguments are provided
username_input="$1"
ip_suffix="$2"

# Prompt for input if not provided as arguments
prompt_for_input

# Set username based on input
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
        echo "Invalid username input"
        exit 1
        ;;
esac

# Set server_ip based on IP suffix
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
    *)
        echo "Invalid IP suffix"
        exit 1
        ;;
esac

# Connect to the server using SSH
sshpass -p "$password" ssh "$username"@"$server_ip"
