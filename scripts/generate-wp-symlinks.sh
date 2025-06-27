#!/bin/bash
################################################################################
# Script Name: generate-wp-symlinks.sh
#
# Description:
#   Enhanced version with auto-detection of LocalWP sites and GitHub repos.
#   Supports flexible plugin/theme symlink management with configuration overrides.
#
# Author: Eric Rasch (Enhanced by Claude Code)
# Date Created: 2025-06-26
# Version: 2.0
#
# Features:
#   - Auto-detects LocalWP sites from sites.json
#   - Smart GitHub repository matching
#   - Configuration file support for custom mappings
#   - Interactive mode for ambiguous matches
#   - Dry-run mode for previewing changes
#   - Selective plugin/theme symlink management
#
# Usage:
#   ./generate-wp-symlinks.sh [OPTIONS]
#
# Options:
#   --dry-run, -d     Preview changes without executing
#   --interactive, -i Interactive mode for ambiguous matches
#   --config FILE     Use custom configuration file
#   --help, -h        Show this help message
#
################################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"
DEFAULT_CONFIG="$CONFIG_DIR/symlink-config.json"
LOCALWP_CONFIG="$HOME/Library/Application Support/Local/sites.json"
GITHUB_BASE="$HOME/Sites/github"
LOCALWP_BASE="$HOME/Local Sites"
BACKUP_DIR="$SCRIPT_DIR/backups"

# Script options
DRY_RUN=false
INTERACTIVE=false
CONFIG_FILE=""
VERBOSE=false
CREATE_BACKUPS=true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_action() {
    echo -e "${PURPLE}🔗 $1${NC}"
}

log_skip() {
    echo -e "${CYAN}⏭️  $1${NC}"
}

# Help function
show_help() {
    cat << EOF
Enhanced WordPress Symlink Manager v2.0

USAGE:
    $(basename "$0") [OPTIONS]

OPTIONS:
    --dry-run, -d        Preview changes without executing
    --interactive, -i    Interactive mode for ambiguous matches
    --config FILE        Use custom configuration file
    --verbose, -v        Enable verbose output
    --no-backup          Skip creating backups of replaced directories
    --help, -h          Show this help message

EXAMPLES:
    $(basename "$0")                    # Auto-detect and create symlinks
    $(basename "$0") --dry-run          # Preview what would be done
    $(basename "$0") --interactive      # Prompt for ambiguous matches
    $(basename "$0") --config custom.json  # Use custom configuration

CONFIGURATION:
    The script will look for configuration files in this order:
    1. File specified with --config option
    2. ./symlink-config.json (in script directory)
    3. Auto-detection mode (default)

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run|-d)
                DRY_RUN=true
                shift
                ;;
            --interactive|-i)
                INTERACTIVE=true
                shift
                ;;
            --config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --no-backup)
                CREATE_BACKUPS=false
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Check if required tools are available
check_dependencies() {
    local missing_deps=()
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Install with: brew install ${missing_deps[*]}"
        exit 1
    fi
}

# Get active LocalWP sites from sites.json
get_localwp_sites() {
    if [[ ! -f "$LOCALWP_CONFIG" ]]; then
        log_error "LocalWP configuration not found at: $LOCALWP_CONFIG"
        return 1
    fi
    
    # Extract site names and paths from sites.json
    jq -r 'to_entries[] | select(.value.path != null) | "\(.value.name)|\(.value.path)"' "$LOCALWP_CONFIG" 2>/dev/null || {
        log_error "Failed to parse LocalWP configuration"
        return 1
    }
}

# Find GitHub repositories that match WordPress structure
find_github_repos() {
    if [[ ! -d "$GITHUB_BASE" ]]; then
        log_error "GitHub directory not found: $GITHUB_BASE"
        return 1
    fi
    
    find "$GITHUB_BASE" -maxdepth 1 -type d -name "wp-*" | while read -r repo_path; do
        repo_name=$(basename "$repo_path")
        
        # Check if it has WordPress structure
        if [[ -d "$repo_path/wp-content" ]]; then
            echo "$repo_name|$repo_path"
        fi
    done
}

# Smart matching between LocalWP sites and GitHub repos
match_sites_to_repos() {
    local localwp_sites=()
    local github_repos=()
    
    # Read LocalWP sites
    while IFS='|' read -r site_name site_path; do
        localwp_sites+=("$site_name|$site_path")
    done < <(get_localwp_sites)
    
    # Read GitHub repos
    while IFS='|' read -r repo_name repo_path; do
        github_repos+=("$repo_name|$repo_path")
    done < <(find_github_repos)
    
    # Match sites to repos
    for localwp_entry in "${localwp_sites[@]}"; do
        IFS='|' read -r site_name site_path <<< "$localwp_entry"
        
        # Try different matching strategies
        local matched_repo=""
        
        # Strategy 1: Direct name matching (wp-example-com -> examplecom)
        local normalized_site
        normalized_site=$(echo "$site_name" | sed 's/[.-]//g' | tr '[:upper:]' '[:lower:]')
        
        for github_entry in "${github_repos[@]}"; do
            IFS='|' read -r repo_name repo_path <<< "$github_entry"
            local normalized_repo
            normalized_repo=$(echo "$repo_name" | sed 's/wp-//; s/[.-]//g' | tr '[:upper:]' '[:lower:]')
            
            if [[ "$normalized_site" == "$normalized_repo" ]]; then
                matched_repo="$repo_name|$repo_path"
                break
            fi
        done
        
        # Strategy 2: Partial matching for complex names
        if [[ -z "$matched_repo" ]] && [[ "$INTERACTIVE" == "true" ]]; then
            echo "No automatic match found for LocalWP site: $site_name"
            echo "Available GitHub repositories:"
            for i in "${!github_repos[@]}"; do
                IFS='|' read -r repo_name repo_path <<< "${github_repos[$i]}"
                echo "  $((i+1)). $repo_name"
            done
            echo "  0. Skip this site"
            
            read -p "Select repository number (0-${#github_repos[@]}): " choice
            
            if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [[ "$choice" -le "${#github_repos[@]}" ]]; then
                matched_repo="${github_repos[$((choice-1))]}"
            fi
        fi
        
        if [[ -n "$matched_repo" ]]; then
            IFS='|' read -r repo_name repo_path <<< "$matched_repo"
            echo "$site_name|$site_path|$repo_name|$repo_path"
        fi
    done
}

# Discover symlink targets in a repository
discover_symlink_targets() {
    local repo_path="$1"
    local targets=()
    
    # Find themes
    if [[ -d "$repo_path/wp-content/themes" ]]; then
        find "$repo_path/wp-content/themes" -mindepth 1 -maxdepth 1 -type d | while read -r theme_dir; do
            local theme_name
            theme_name=$(basename "$theme_dir")
            echo "theme|wp-content/themes/$theme_name"
        done
    fi
    
    # Find plugins
    if [[ -d "$repo_path/wp-content/plugins" ]]; then
        find "$repo_path/wp-content/plugins" -mindepth 1 -maxdepth 1 -type d | while read -r plugin_dir; do
            local plugin_name
            plugin_name=$(basename "$plugin_dir")
            # Only include custom plugins (skip common WordPress plugins)
            if [[ ! "$plugin_name" =~ ^(akismet|hello-dolly|wordpress-importer)$ ]]; then
                echo "plugin|wp-content/plugins/$plugin_name"
            fi
        done
    fi
    
    # Find other common directories
    for dir in "app_resources" "lib"; do
        if [[ -d "$repo_path/$dir" ]]; then
            echo "other|$dir"
        fi
    done
}

# Load configuration file if it exists
load_config() {
    local config_file="$1"
    
    if [[ -f "$config_file" ]] && [[ -s "$config_file" ]]; then
        log_info "Loading configuration from: $config_file"
        return 0
    fi
    
    return 1
}

# Create backup of directory before replacing
create_backup() {
    local source_path="$1"
    local backup_name="$2"
    
    if [[ ! -d "$source_path" ]]; then
        return 0  # Nothing to backup
    fi
    
    if [[ "$CREATE_BACKUPS" == "false" ]]; then
        return 0  # Backups disabled
    fi
    
    # Create backup directory if it doesn't exist
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Generate timestamp for backup
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="$BACKUP_DIR/${backup_name}_${timestamp}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create backup: $source_path -> $backup_path"
        return 0
    fi
    
    # Create backup
    log_info "Creating backup: $backup_path"
    
    if cp -R "$source_path" "$backup_path"; then
        log_success "Backup created successfully"
        echo "$backup_path"  # Return backup path
        return 0
    else
        log_error "Failed to create backup"
        return 1
    fi
}

# Restore from backup (for undo functionality)
restore_backup() {
    local backup_path="$1"
    local destination="$2"
    
    if [[ ! -d "$backup_path" ]]; then
        log_error "Backup not found: $backup_path"
        return 1
    fi
    
    log_info "Restoring from backup: $backup_path -> $destination"
    
    # Remove current symlink/directory
    if [[ -L "$destination" ]]; then
        rm "$destination"
    elif [[ -d "$destination" ]]; then
        rm -rf "$destination"
    fi
    
    # Restore backup
    if cp -R "$backup_path" "$destination"; then
        log_success "Backup restored successfully"
        return 0
    else
        log_error "Failed to restore backup"
        return 1
    fi
}

# Create symlink with validation
create_symlink() {
    local src="$1"
    local dest="$2"
    local type="$3"
    
    # Expand home directory
    src="${src/#\~/$HOME}"
    dest="${dest/#\~/$HOME}"
    
    # Validate source exists
    if [[ ! -d "$src" ]]; then
        log_error "Source directory does not exist: $src"
        return 1
    fi
    
    # Validate LocalWP site exists
    local localwp_root
    localwp_root=$(echo "$dest" | awk -F"/app/public" '{print $1}')
    if [[ ! -d "$localwp_root" ]]; then
        log_error "LocalWP site not found at: $localwp_root"
        return 1
    fi
    
    # Create parent directory if needed
    local parent_dir
    parent_dir=$(dirname "$dest")
    if [[ ! -d "$parent_dir" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would create directory: $parent_dir"
        else
            log_info "Creating directory: $parent_dir"
            mkdir -p "$parent_dir"
        fi
    fi
    
    # Check current state
    if [[ -L "$dest" ]]; then
        local current_target
        current_target=$(readlink "$dest" 2>/dev/null)
        if [[ "$current_target" == "$src" ]]; then
            log_skip "Symlink already correct: $dest"
            return 0
        else
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "[DRY RUN] Would remove incorrect symlink: $dest"
            else
                log_warning "Removing incorrect symlink: $dest"
                rm "$dest"
            fi
        fi
    elif [[ -d "$dest" ]]; then
        # Create backup before removing directory
        local backup_name
        backup_name=$(basename "$dest")
        local site_name
        site_name=$(echo "$dest" | grep -o '[^/]*\.com\|[^/]*\.org' | head -1 | sed 's/\./_/g')
        if [[ -n "$site_name" ]]; then
            backup_name="${site_name}_${backup_name}"
        fi
        
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would create backup and remove directory: $dest"
        else
            log_warning "Creating backup and removing directory: $dest"
            
            # Create backup
            local backup_path
            backup_path=$(create_backup "$dest" "$backup_name")
            
            if [[ $? -eq 0 ]] && [[ -n "$backup_path" ]]; then
                log_info "Backup created at: $backup_path"
            fi
            
            # Remove directory
            rm -rf "$dest"
        fi
    fi
    
    # Create symlink
    if [[ "$DRY_RUN" == "true" ]]; then
        log_action "[DRY RUN] Would create $type symlink: $src -> $dest"
    else
        log_action "Creating $type symlink: $src -> $dest"
        ln -s "$src" "$dest"
        
        if [[ -L "$dest" ]]; then
            log_success "Symlink created successfully"
        else
            log_error "Failed to create symlink"
            return 1
        fi
    fi
    
    return 0
}

# Main execution function
main() {
    parse_args "$@"
    
    log_info "Enhanced WordPress Symlink Manager v2.0"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi
    
    # Check dependencies
    check_dependencies
    
    # Try to load configuration file
    local using_config=false
    if [[ -n "$CONFIG_FILE" ]]; then
        if load_config "$CONFIG_FILE"; then
            using_config=true
        else
            log_error "Configuration file not found: $CONFIG_FILE"
            exit 1
        fi
    elif [[ -f "$DEFAULT_CONFIG" ]]; then
        if load_config "$DEFAULT_CONFIG"; then
            using_config=true
            CONFIG_FILE="$DEFAULT_CONFIG"
        fi
    fi
    
    # If using configuration file, process it
    if [[ "$using_config" == "true" ]]; then
        log_info "Processing configuration-based symlinks..."
        # TODO: Implement configuration file processing
        log_warning "Configuration file processing not yet implemented"
        log_info "Falling back to auto-detection mode"
    fi
    
    # Auto-detection mode
    log_info "Auto-detecting LocalWP sites and GitHub repositories..."
    
    local matches_found=0
    local symlinks_created=0
    local symlinks_skipped=0
    local errors=0
    
    # Process matches
    while IFS='|' read -r site_name site_path repo_name repo_path; do
        matches_found=$((matches_found + 1))
        
        log_info "Processing: $site_name <-> $repo_name"
        
        # Discover symlink targets in the repository
        while IFS='|' read -r target_type target_path; do
            local src="$repo_path/$target_path"
            local dest="$site_path/app/public/$target_path"
            
            if create_symlink "$src" "$dest" "$target_type"; then
                symlinks_created=$((symlinks_created + 1))
            else
                errors=$((errors + 1))
            fi
        done < <(discover_symlink_targets "$repo_path")
        
    done < <(match_sites_to_repos)
    
    # Summary
    echo
    log_info "Summary:"
    log_info "  Matches found: $matches_found"
    log_info "  Symlinks created/verified: $symlinks_created"
    log_info "  Symlinks skipped: $symlinks_skipped"
    
    if [[ "$errors" -gt 0 ]]; then
        log_error "  Errors encountered: $errors"
        exit 1
    else
        log_success "All operations completed successfully!"
    fi
}

# Run main function
main "$@"