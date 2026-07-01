#!/bin/bash

# Function to display the help message
show_help() {
    echo "════════════════════════════════════════════════════════════"
    echo "   Conda Access Setup Script - Created by Omprakash"
    echo "════════════════════════════════════════════════════════════"
    echo
    echo "Usage: sudo $0 <conda_owner> <target_user>"
    echo
    echo "This script gives shared access to a Conda installation for another user."
    echo "It will:"
    echo " 1. Add the target user to a shared Conda group"
    echo " 2. Only set directory permissions ONCE when the group is first created"
    echo " 3. Modify the target user's .bashrc to enable Conda"
    echo
    echo "Example usage:"
    echo "  sudo $0 sakshi user2"
    exit 0
}

echo "════════════════════════════════════════════════════════════"
echo "   Welcome to the Conda Access Setup Script!"
echo "      Script by Omprakash"
echo "════════════════════════════════════════════════════════════"
echo

# Show help if requested
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

# Check if run as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root. Try: sudo $0 <conda_owner> <target_user>"
    exit 1
fi

# Parse arguments
CONDA_OWNER="$1"
USERX="$2"

if [ -z "$CONDA_OWNER" ] || [ -z "$USERX" ]; then
    echo "❌ Usage: sudo $0 <conda_owner> <target_user>"
    exit 1
fi

# Step 1: Detect Conda directory
CONDA_DIRS=( "/home/$CONDA_OWNER/miniconda3" "/home/$CONDA_OWNER/miniconda" "/home/$CONDA_OWNER/.conda" )
CONDA_DIR=""

for DIR in "${CONDA_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        CONDA_DIR="$DIR"
        break
    fi
done

if [ -z "$CONDA_DIR" ]; then
    echo "❌ Could not find Conda directory for $CONDA_OWNER"
    exit 1
fi

echo "✅ Found Conda directory: $CONDA_DIR"

# Step 2: Group setup
CONDA_GROUP="condaread"
GROUP_CREATED=0

echo "🔄 Checking if group '$CONDA_GROUP' exists..."
if getent group "$CONDA_GROUP" > /dev/null; then
    echo "✅ Group '$CONDA_GROUP' already exists."
else
    echo "🆕 Creating group '$CONDA_GROUP'..."
    groupadd "$CONDA_GROUP"
    GROUP_CREATED=1
    echo "✅ Group '$CONDA_GROUP' created!"
fi

# Step 3: Add target user to the group
echo "🔄 Adding user '$USERX' to group '$CONDA_GROUP'..."
usermod -aG "$CONDA_GROUP" "$USERX"
echo "✅ User '$USERX' added to group '$CONDA_GROUP'!"

# Step 4: Only set permissions if group was newly created
if [ "$GROUP_CREATED" -eq 1 ]; then
    echo "🔐 Setting permissions for '$CONDA_DIR'..."

    chown -R "$CONDA_OWNER:$CONDA_GROUP" "$CONDA_DIR"
    find "$CONDA_DIR" -type d -exec chmod 770 {} \;
    find "$CONDA_DIR" -type f -exec chmod 660 {} \;

    # Ensure executables in bin/ are accessible
    chmod g+rx "$CONDA_DIR"
    chmod g+rx "$CONDA_DIR/bin"
    chmod g+rx "$CONDA_DIR/bin/conda"
    find "$CONDA_DIR/bin" -type f -exec chmod g+rx {} \;

    echo "✅ Permissions configured to: drwxrwx--- and executable access ensured!"
else
    echo "🔁 Skipping permission setup (already configured)."
fi

# Step 5: Modify .bashrc to include Conda path
echo "🔄 Updating '$USERX''s .bashrc to include Conda path..."

sudo -u "$USERX" bash -c "
    BASHRC=\$HOME/.bashrc
    CONDA_PATH_LINE='export PATH=\"$CONDA_DIR/bin:\$PATH\"'

    if ! grep -Fxq \"\$CONDA_PATH_LINE\" \"\$BASHRC\"; then
        echo \"\$CONDA_PATH_LINE\" >> \"\$BASHRC\"
        echo '✅ Conda path added to .bashrc'
    else
        echo 'ℹ️ Conda path already in .bashrc'
    fi
"

echo "⚠️ Skipping 'conda init bash' for now due to permission issues during non-login shell."

echo "👉 Please ask '$USERX' to run the following manually after login:"
echo "   source ~/.bashrc"
echo "   conda init bash"

# Final message
echo "════════════════════════════════════════════════════════════"
echo "🎉 Conda access successfully set up for '$USERX'."
echo "👉 Ask them to run: source ~/.bashrc or log out and back in."
echo "🖋️ Script by Omprakash"
echo "════════════════════════════════════════════════════════════"
