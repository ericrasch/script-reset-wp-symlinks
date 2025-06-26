#!/bin/bash
################################################################################
# Script Name: generate-config.sh
#
# Description:
#   Auto-detects LocalWP sites and GitHub repositories to generate a
#   personalized symlink-config.json file. Analyzes your actual setup
#   and creates configuration with smart defaults.
#
# Author: Eric Rasch
# Date Created: 2025-06-26
# Version: 1.0
#
# Usage:
#   ./generate-config.sh [output_file]
#
################################################################################

set -euo pipefail

# Configuration
LOCALWP_CONFIG="$HOME/Library/Application Support/Local/sites.json"
GITHUB_BASE="$HOME/Sites/github"
LOCALWP_BASE="$HOME/Local Sites"
DEFAULT_OUTPUT="symlink-config.json"

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

show_help() {
    cat << EOF
Symlink Configuration Generator

USAGE:
    $(basename "$0") [output_file]

DESCRIPTION:
    Auto-detects your LocalWP sites and GitHub repositories to generate
    a personalized symlink-config.json file based on your actual setup.

OPTIONS:
    output_file     Output file path (default: symlink-config.json)
    --help, -h      Show this help message

EXAMPLES:
    $(basename "$0")                          # Create symlink-config.json
    $(basename "$0") my-config.json           # Custom filename
    $(basename "$0") ~/my-symlink-config.json # Custom path

EOF
}

# Check dependencies
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed"
        log_info "Install with: brew install jq"
        exit 1
    fi
}

# Get LocalWP sites
get_localwp_sites() {
    if [[ ! -f "$LOCALWP_CONFIG" ]]; then
        log_error "LocalWP configuration not found at: $LOCALWP_CONFIG"
        return 1
    fi
    
    log_info "Analyzing LocalWP sites..."
    jq -r 'to_entries[] | select(.value.path != null) | [.value.name, .value.path] | join("|")' "$LOCALWP_CONFIG" 2>/dev/null
}

# Find GitHub repositories
find_github_repos() {
    if [[ ! -d "$GITHUB_BASE" ]]; then
        log_error "GitHub directory not found: $GITHUB_BASE"
        return 1
    fi
    
    log_info "Scanning GitHub repositories..."
    find "$GITHUB_BASE" -maxdepth 1 -type d -name "wp-*" | while read -r repo_path; do
        repo_name=$(basename "$repo_path")
        if [[ -d "$repo_path/wp-content" ]]; then
            echo "$repo_name|$repo_path"
        fi
    done
}

# Smart matching between sites and repos
match_sites_to_repos() {
    # Read all sites and repos
    local localwp_sites=()
    local github_repos=()
    
    while IFS='|' read -r site_name site_path; do
        [[ -n "$site_name" ]] && localwp_sites+=("$site_name|$site_path")
    done < <(get_localwp_sites)
    
    while IFS='|' read -r repo_name repo_path; do
        [[ -n "$repo_name" ]] && github_repos+=("$repo_name|$repo_path")
    done < <(find_github_repos)
    
    log_info "Found ${#localwp_sites[@]} LocalWP sites and ${#github_repos[@]} GitHub repositories"
    
    # Direct matching approach
    for localwp_entry in "${localwp_sites[@]}"; do
        IFS='|' read -r site_name site_path <<< "$localwp_entry"
        local matched=false
        
        # Normalize site name for matching
        local normalized_site=$(echo "$site_name" | sed 's/[.-]//g' | tr '[:upper:]' '[:lower:]')
        
        for github_entry in "${github_repos[@]}"; do
            IFS='|' read -r repo_name repo_path <<< "$github_entry"
            local normalized_repo=$(echo "$repo_name" | sed 's/wp-//; s/[.-]//g' | tr '[:upper:]' '[:lower:]')
            
            if [[ "$normalized_site" == "$normalized_repo" ]]; then
                echo "$site_name|$repo_name|$repo_path|$site_path"
                matched=true
                log_success "Matched: $site_name ↔ $repo_name"
                break
            fi
        done
        
        if [[ "$matched" == "false" ]]; then
            log_warning "No match found for LocalWP site: $site_name"
        fi
    done
}

# Discover paths within a repository
discover_repo_paths() {
    local repo_path="$1"
    local paths=()
    
    # Find themes
    if [[ -d "$repo_path/wp-content/themes" ]]; then
        while IFS= read -r -d '' theme_dir; do
            local theme_name=$(basename "$theme_dir")
            # Skip default WordPress themes
            if [[ ! "$theme_name" =~ ^twenty(twenty)?(one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty|twentyone|twentytwo|twentythree|twentyfour)$ ]]; then
                paths+=("wp-content/themes/$theme_name")
            fi
        done < <(find "$repo_path/wp-content/themes" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    fi
    
    # Find custom plugins
    if [[ -d "$repo_path/wp-content/plugins" ]]; then
        while IFS= read -r -d '' plugin_dir; do
            local plugin_name=$(basename "$plugin_dir")
            # Skip common WordPress plugins
            if [[ ! "$plugin_name" =~ ^(akismet|hello-dolly|wordpress-importer|woocommerce)$ ]]; then
                paths+=("wp-content/plugins/$plugin_name")
            fi
        done < <(find "$repo_path/wp-content/plugins" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    fi
    
    # Find other common directories
    for dir in "app_resources" "lib"; do
        if [[ -d "$repo_path/$dir" ]]; then
            paths+=("$dir")
        fi
    done
    
    # Output as JSON array
    if [[ ${#paths[@]} -gt 0 ]]; then
        printf '%s\n' "${paths[@]}" | jq -R . | jq -s .
    else
        echo '[]'
    fi
}

# Generate configuration file
generate_config() {
    local output_file="$1"
    local temp_file=$(mktemp)
    
    log_info "Generating configuration..."
    
    # Start building JSON
    cat > "$temp_file" << 'EOF'
{
  "_description": "Auto-generated symlink configuration based on detected sites and repositories",
  "_generated": "",
  "_instructions": "This file was auto-generated. You can customize it as needed.",
  
  "settings": {
    "github_base": "$HOME/Sites/github",
    "localwp_base": "$HOME/Local Sites",
    "auto_detect": true,
    "interactive_fallback": true,
    "exclude_plugins": [
      "akismet",
      "hello-dolly",
      "wordpress-importer",
      "woocommerce"
    ]
  },
  
  "mappings": [],
  
  "global_excludes": {
    "themes": [
      "twentytwentyone",
      "twentytwentytwo", 
      "twentytwentythree",
      "twentytwentyfour"
    ],
    "plugins": [
      "akismet",
      "hello-dolly",
      "wordpress-importer"
    ]
  }
}
EOF
    
    # Add generation timestamp
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    jq --arg timestamp "$timestamp" '._generated = $timestamp' "$temp_file" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$temp_file"
    
    # Generate mappings from detected matches
    local mappings='[]'
    
    while IFS='|' read -r site_name repo_name repo_path site_path; do
        log_info "Processing: $site_name → $repo_name"
        
        # Discover paths in repository
        local paths
        paths=$(discover_repo_paths "$repo_path")
        
        # Create mapping entry
        local mapping
        mapping=$(jq -n \
            --arg site "$site_name" \
            --arg repo "$repo_name" \
            --argjson paths "$paths" \
            '{
                "_comment": ("Auto-detected mapping for " + $site),
                "localwp_site": $site,
                "github_repo": $repo,
                "paths": $paths
            }')
        
        # Add to mappings array
        mappings=$(echo "$mappings" | jq --argjson mapping "$mapping" '. + [$mapping]')
        
    done < <(match_sites_to_repos)
    
    # Update config with mappings
    jq --argjson mappings "$mappings" '.mappings = $mappings' "$temp_file" > "$output_file"
    
    rm "$temp_file"
    
    log_success "Configuration generated: $output_file"
}

# Show configuration summary
show_summary() {
    local config_file="$1"
    
    log_info "Configuration Summary:"
    
    local mapping_count
    mapping_count=$(jq '.mappings | length' "$config_file")
    echo "  📊 Total mappings: $mapping_count"
    
    echo "  🔗 Site mappings:"
    jq -r '.mappings[] | "    \(.localwp_site) ↔ \(.github_repo) (\(.paths | length) paths)"' "$config_file"
    
    echo
    log_info "Next steps:"
    echo "  1. Review the generated configuration: nano $config_file"
    echo "  2. Test with dry-run: ./enhanced-reset_wp_symlinks.sh --dry-run --config $config_file"
    echo "  3. Execute: ./enhanced-reset_wp_symlinks.sh --config $config_file"
}

# Interactive mode for unmatched sites
handle_unmatched_sites() {
    local config_file="$1"
    
    # This could be expanded to interactively handle unmatched sites
    # For now, we'll just note them in the config
    log_info "Future enhancement: Interactive matching for unmatched sites"
}

# Main function
main() {
    if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    local output_file="${1:-$DEFAULT_OUTPUT}"
    
    log_info "WordPress Symlink Configuration Generator"
    
    # Check dependencies
    check_dependencies
    
    # Check if output file exists
    if [[ -f "$output_file" ]]; then
        log_warning "Output file already exists: $output_file"
        echo -n "Overwrite? (y/N): "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Generation cancelled"
            exit 0
        fi
    fi
    
    # Generate configuration
    generate_config "$output_file"
    
    # Show summary
    show_summary "$output_file"
    
    # Handle any unmatched sites
    handle_unmatched_sites "$output_file"
}

# Run main function
main "$@"