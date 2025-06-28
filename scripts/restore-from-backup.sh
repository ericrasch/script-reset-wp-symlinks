#!/bin/bash
################################################################################
# Script Name: restore-from-backup.sh
#
# Description:
#   Utility script to restore directories from backups created by the enhanced
#   symlink script. Lists available backups and allows selective restoration.
#
# Author: Eric Rasch (Enhanced by Claude Code)
# Date Created: 2025-06-26
# Version: 1.0
#
# Usage:
#   ./restore-from-backup.sh [backup_name]
#
################################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
# PURPLE='\033[0;35m' # Reserved for future use
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Show help
show_help() {
    cat << EOF
Backup Restoration Utility v1.0

USAGE:
    $(basename "$0") [backup_name]

DESCRIPTION:
    This script helps restore directories from backups created by the enhanced
    WordPress symlink manager. If no backup name is provided, it will list
    all available backups for selection.

OPTIONS:
    backup_name     Name of the backup to restore (optional)
    --help, -h      Show this help message

EXAMPLES:
    $(basename "$0")                          # List all backups
    $(basename "$0") theme_20250626_143022    # Restore specific backup

EOF
}

# List available backups
list_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_warning "No backup directory found at: $BACKUP_DIR"
        return 1
    fi
    
    local backups
    mapfile -t backups < <(find "$BACKUP_DIR" -maxdepth 1 -type d -name "*_[0-9]*_[0-9]*" | sort -r)
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        log_warning "No backups found in: $BACKUP_DIR"
        return 1
    fi
    
    log_info "Available backups:"
    for i in "${!backups[@]}"; do
        local backup_path="${backups[$i]}"
        local backup_name
        backup_name=$(basename "$backup_path")
        local backup_date
        backup_date=$(echo "$backup_name" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
        local formatted_date
        formatted_date=$(echo "$backup_date" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
        local size
        size=$(du -sh "$backup_path" | cut -f1)
        
        echo -e "  $((i+1)). ${CYAN}$backup_name${NC}"
        echo -e "     Date: $formatted_date"
        echo -e "     Size: $size"
        echo -e "     Path: $backup_path"
        echo
    done
    
    return 0
}

# Interactive backup selection
select_backup() {
    if ! list_backups; then
        return 1
    fi
    
    local backups
    mapfile -t backups < <(find "$BACKUP_DIR" -maxdepth 1 -type d -name "*_[0-9]*_[0-9]*" | sort -r)
    
    echo -n "Select backup number (1-${#backups[@]}) or 0 to cancel: "
    read -r choice
    
    if [[ "$choice" == "0" ]]; then
        log_info "Restoration cancelled"
        return 1
    fi
    
    if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [[ "$choice" -le "${#backups[@]}" ]]; then
        local selected_backup="${backups[$((choice-1))]}"
        echo "$(basename "$selected_backup")"
        return 0
    else
        log_error "Invalid selection: $choice"
        return 1
    fi
}

# Restore specific backup
restore_backup() {
    local backup_name="$1"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [[ ! -d "$backup_path" ]]; then
        log_error "Backup not found: $backup_path"
        return 1
    fi
    
    log_info "Backup found: $backup_path"
    
    # Try to determine original location from backup name
    # Determine original location from backup name (currently unused)
    # local original_name
    # original_name=$(echo "$backup_name" | sed 's/_[0-9]\{8\}_[0-9]\{6\}$//')
    
    log_warning "IMPORTANT: You need to specify the destination path manually."
    log_info "Backup contents preview:"
    ls -la "$backup_path" | head -10
    
    echo
    echo -n "Enter the full destination path where this backup should be restored: "
    read -r destination
    
    if [[ -z "$destination" ]]; then
        log_error "No destination provided"
        return 1
    fi
    
    # Expand home directory
    destination="${destination/#\~/$HOME}"
    
    # Confirm restoration
    echo
    log_warning "This will restore:"
    log_info "  From: $backup_path"
    log_info "  To:   $destination"
    echo
    echo -n "Are you sure? (y/N): "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Restoration cancelled"
        return 1
    fi
    
    # Perform restoration
    log_info "Restoring backup..."
    
    # Create parent directory if needed
    local parent_dir
    parent_dir=$(dirname "$destination")
    if [[ ! -d "$parent_dir" ]]; then
        log_info "Creating parent directory: $parent_dir"
        mkdir -p "$parent_dir"
    fi
    
    # Remove existing destination if it exists
    if [[ -e "$destination" ]]; then
        log_warning "Removing existing destination: $destination"
        rm -rf "$destination"
    fi
    
    # Copy backup to destination
    if cp -R "$backup_path" "$destination"; then
        log_success "Backup restored successfully!"
        log_info "Restored to: $destination"
        return 0
    else
        log_error "Failed to restore backup"
        return 1
    fi
}

# Main function
main() {
    if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    log_info "Backup Restoration Utility v1.0"
    
    if [[ -n "${1:-}" ]]; then
        # Restore specific backup
        restore_backup "$1"
    else
        # Interactive mode
        local selected_backup
        if selected_backup=$(select_backup); then
            restore_backup "$selected_backup"
        fi
    fi
}

# Run main function
main "$@"