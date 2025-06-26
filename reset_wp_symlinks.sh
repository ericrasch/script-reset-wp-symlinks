#!/bin/bash

################################################################################
# Script Name: reset_wp_symlinks.sh
#
# Description:
#   This script automates the process of resetting symbolic links for 
#   WordPress theme directories in a LocalWP environment. It removes any 
#   existing theme directories that were overwritten during a sync from WP Engine 
#   and re-creates symlinks pointing to the corresponding GitHub repository folders.
#
# Author: Eric Rasch
#   GitHub: https://github.com/ericrasch/reset-wp-symlinks
# Date Created: 2025-03-07
# Last Modified: 2025-03-07
# Version: 1.7
#
# Usage:
#   1. Place this script in your working folder (e.g., ~/scripts/).
#   2. Make it executable: chmod +x reset_wp_symlinks.sh
#   3. Run the script manually: ./reset_wp_symlinks.sh
#   4. (Optional) Automate execution using cron, fswatch, or a GitHub Action.
#
# Theme Paths:
#   - GitHub Repo (Source):
#       $HOME/path/to/github-repo/wp-content/themes/YOUR-THEME
#   - LocalWP (Destination):
#       $HOME/path/to/local-wp-site/app/public/wp-content/themes/YOUR-THEME
#
# Requirements:
#   - LocalWP must be installed and set up.
#   - The source theme directories should be version-controlled in GitHub.
#   - Ensure backups are taken before running this script.
#
# Output:
#   - Re-created symbolic links for WordPress themes.
#   - Echo confirmation messages on successful execution.
#
################################################################################

# Define theme paths (GitHub Source and Local Destination) using arrays
# IMPORTANT: Replace these example paths with your actual site paths
# Copy the example lines below and modify them for each of your sites
GITHUB_THEMES=(
    "$HOME/Sites/github/wp-example-com/wp-content/themes/example-theme"
    "$HOME/Sites/github/wp-mysite-com/wp-content/themes/custom-theme"
    "$HOME/Sites/github/wp-mysite-com/wp-content/plugins/custom-plugin"
    # Add more paths as needed - one line per theme/plugin/directory
)

LOCAL_THEMES=(
    "$HOME/Local Sites/examplecom/app/public/wp-content/themes/example-theme"
    "$HOME/Local Sites/mysitecom/app/public/wp-content/themes/custom-theme"
    "$HOME/Local Sites/mysitecom/app/public/wp-content/plugins/custom-plugin"
    # Add corresponding LocalWP paths - must match GITHUB_THEMES array order
)

# Ensure the arrays have matching lengths
if [ "${#GITHUB_THEMES[@]}" -ne "${#LOCAL_THEMES[@]}" ]; then
    echo "❌ Error: GITHUB_THEMES and LOCAL_THEMES arrays have mismatched lengths. Exiting."
    exit 1
fi

# Function to remove existing theme folder and create symlink
reset_symlink() {
    local src="$1"
    local dest="$2"

    # Ensure variables are correctly expanded
    src="${src/#\~/$HOME}"
    dest="${dest/#\~/$HOME}"

    # Check if source exists
    if [ ! -d "$src" ]; then
        echo "❌ Source directory does not exist: $src"
        return
    fi

    # Ensure LocalWP site exists before proceeding
    local localwp_root
    localwp_root=$(echo "$dest" | awk -F"/wp-content" '{print $1}')
    if [ ! -d "$localwp_root" ]; then
        echo "❌ LocalWP site not found at: $localwp_root. Skipping symlink creation."
        return
    fi

    # Ensure parent directory exists
    local parent_dir
    parent_dir=$(dirname "$dest")

    if [ ! -d "$parent_dir" ]; then
        echo "📁 Creating missing parent directory: \"$parent_dir\""
        mkdir -p "$parent_dir"
    fi

    # Ensure destination directory exists before checking/removing it
    if [ ! -e "$dest" ]; then
        echo "ℹ️  Destination path does not exist, proceeding with symlink creation: \"$dest\""
    fi

    # Check if destination is already a valid symlink
    if [ -L "$dest" ]; then
        current_target=$(readlink "$dest" 2>/dev/null)
        if [ "$current_target" == "$src" ]; then
            echo "✅ Symlink already correct, skipping: \"$dest\""
            return
        else
            echo "🔄 Symlink exists but points to the wrong location. Removing: \"$dest\""
            rm "$dest"
        fi
    elif [ -d "$dest" ]; then
        echo "⚠️  Existing directory found instead of symlink, removing: \"$dest\""
        rm -rf "$dest"
    fi

    # Create symlink
    echo "🔗 Creating symlink from \"$src\" to \"$dest\""
    ln -s "$src" "$dest"

    # Verify symlink creation
    if [ -L "$dest" ]; then
        echo "✅ Symlink created successfully: \"$dest\""
    else
        echo "❌ Failed to create symlink: \"$dest\""
    fi
}

# Loop through each theme and reset symlinks dynamically
for i in "${!GITHUB_THEMES[@]}"; do
    reset_symlink "${GITHUB_THEMES[$i]}" "${LOCAL_THEMES[$i]}"
done

echo "✅ All theme symlinks have been reset successfully."
