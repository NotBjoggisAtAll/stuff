#!/bin/bash

# This script automates the creation of a new user on Fedora,
# installs the Fish shell, adds the user to the 'wheel' group,
# sets Fish as their default shell, and copies authorized_keys
# from the root user to the new user.

# --- Configuration ---
FISH_SHELL_PATH="/usr/bin/fish" # Common path for Fish shell on Fedora
WHEEL_GROUP="wheel"             # Group for sudo privileges on Fedora
ROOT_AUTHORIZED_KEYS="/root/.ssh/authorized_keys" # Path to root's authorized_keys

# --- Functions ---

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Fish shell
install_fish() {
    echo "Attempting to install Fish shell..."
    if command_exists dnf; then
        sudo dnf install -y fish
        if [ $? -eq 0 ]; then
            echo "Fish shell installed successfully."
        else
            echo "Error: Failed to install Fish shell. Please install it manually and try again."
            exit 1
        fi
    else
        echo "Error: 'dnf' command not found. This script is intended for Fedora/RHEL-based systems."
        exit 1
    fi
}

# --- Main Script ---

echo "--- Fedora User Creation Script ---"

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges. Please run with 'sudo'."
    exit 1
fi

# Prompt for the new username
read -p "Enter the desired new username: " NEW_USERNAME

# Validate username (basic check)
if [[ -z "$NEW_USERNAME" ]]; then
    echo "Error: Username cannot be empty."
    exit 1
fi

# Check if user already exists
if id "$NEW_USERNAME" &>/dev/null; then
    echo "Error: User '$NEW_USERNAME' already exists. Please choose a different username."
    exit 1
fi

# 1. Install Fish shell
install_fish

# Verify Fish shell path exists after installation
if [ ! -f "$FISH_SHELL_PATH" ]; then
    echo "Error: Fish shell not found at '$FISH_SHELL_PATH' after installation."
    echo "Please verify the Fish shell installation and its path."
    exit 1
fi

# 2. Create the new user, add to wheel group, and set Fish as default shell
echo "Creating user '$NEW_USERNAME', adding to '$WHEEL_GROUP' group, and setting '$FISH_SHELL_PATH' as default shell..."
useradd -m -G "$WHEEL_GROUP" -s "$FISH_SHELL_PATH" "$NEW_USERNAME"

if [ $? -eq 0 ]; then
    echo "User '$NEW_USERNAME' created successfully."
else
    echo "Error: Failed to create user '$NEW_USERNAME'."
    exit 1
fi

# 3. Set a password for the new user
echo "Setting password for user '$NEW_USERNAME'..."
passwd "$NEW_USERNAME"

if [ $? -eq 0 ]; then
    echo "Password for '$NEW_USERNAME' set successfully."
else
    echo "Error: Failed to set password for '$NEW_USERNAME'."
    exit 1
fi

# 4. Copy authorized_keys from root to the new user
NEW_USER_HOME="/home/$NEW_USERNAME"
NEW_USER_SSH_DIR="$NEW_USER_HOME/.ssh"
NEW_USER_AUTHORIZED_KEYS="$NEW_USER_SSH_DIR/authorized_keys"

echo "Attempting to copy authorized_keys from root to '$NEW_USERNAME'..."

if [ -f "$ROOT_AUTHORIZED_KEYS" ]; then
    # Create .ssh directory for the new user
    mkdir -p "$NEW_USER_SSH_DIR"
    if [ $? -ne 0 ]; then
        echo "Warning: Could not create .ssh directory for '$NEW_USERNAME'."
    fi

    # Copy the authorized_keys file
    cp "$ROOT_AUTHORIZED_KEYS" "$NEW_USER_AUTHORIZED_KEYS"
    if [ $? -eq 0 ]; then
        echo "authorized_keys copied successfully to '$NEW_USER_AUTHORIZED_KEYS'."
        # Set correct ownership and permissions
        chown -R "$NEW_USERNAME":"$NEW_USERNAME" "$NEW_USER_SSH_DIR"
        chmod 700 "$NEW_USER_SSH_DIR"
        chmod 600 "$NEW_USER_AUTHORIZED_KEYS"
        echo "Permissions and ownership set for '$NEW_USER_SSH_DIR' and authorized_keys."
    else
        echo "Warning: Failed to copy authorized_keys to '$NEW_USER_AUTHORIZED_KEYS'."
    fi
else
    echo "Info: Root's authorized_keys file not found at '$ROOT_AUTHORIZED_KEYS'. Skipping copy."
fi

echo "--- Script Completed ---"
echo "User '$NEW_USERNAME' has been created, added to the '$WHEEL_GROUP' group, and their default shell is now Fish."
echo "If root's authorized_keys existed, it has been copied to the new user."
echo "You can now switch to the new user using: su - $NEW_USERNAME"
echo "\n"
echo "If you need tailscale installed please generate a install script at https://login.tailscale.com/admin/machines/new-linux"
