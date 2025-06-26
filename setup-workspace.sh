#!/bin/bash
################################################################################
# Script Name: setup-workspace.sh
#
# Description:
#   Sets up a dedicated workspace for WordPress symlink management outside
#   the repository. Copies necessary scripts and creates configuration files.
#
# Author: Eric Rasch
# Date Created: 2025-06-26
# Version: 1.0
#
# Usage:
#   ./setup-workspace.sh [workspace_path]
#
################################################################################

set -euo pipefail

# Default workspace location
DEFAULT_WORKSPACE="$HOME/scripts/wp-symlinks"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

show_help() {
    cat << EOF
WordPress Symlink Workspace Setup

USAGE:
    $(basename "$0") [workspace_path]

DESCRIPTION:
    Creates a dedicated workspace for managing WordPress symlinks outside
    the repository. Copies scripts and sets up configuration files.

OPTIONS:
    workspace_path  Custom workspace location (default: ~/scripts/wp-symlinks)
    --help, -h      Show this help message

EXAMPLES:
    $(basename "$0")                                    # Use default location
    $(basename "$0") ~/my-symlink-tools                 # Custom location
    $(basename "$0") ~/.wp-symlinks                     # Hidden directory

EOF
}

main() {
    if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    local workspace="${1:-$DEFAULT_WORKSPACE}"
    
    log_info "Setting up WordPress symlink workspace..."
    log_info "Target location: $workspace"
    
    # Create workspace directory
    if [[ -d "$workspace" ]]; then
        log_warning "Workspace already exists: $workspace"
        echo -n "Continue and overwrite existing files? (y/N): "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled"
            exit 0
        fi
    else
        log_info "Creating workspace directory..."
        mkdir -p "$workspace"
    fi
    
    cd "$workspace"
    
    # Copy essential scripts
    log_info "Copying scripts..."
    
    local files_to_copy=(
        "enhanced-reset_wp_symlinks.sh"
        "restore-from-backup.sh"
    )
    
    for file in "${files_to_copy[@]}"; do
        if [[ -f "$SCRIPT_DIR/$file" ]]; then
            cp "$SCRIPT_DIR/$file" .
            chmod +x "$file"
            log_success "Copied: $file"
        else
            log_warning "Source file not found: $file"
        fi
    done
    
    # Copy and rename config template
    if [[ -f "$SCRIPT_DIR/symlink-config.json.example" ]]; then
        cp "$SCRIPT_DIR/symlink-config.json.example" "symlink-config.json"
        log_success "Created: symlink-config.json (from example)"
    fi
    
    # Copy documentation
    log_info "Copying documentation..."
    local docs_to_copy=(
        "README.md"
        "MIGRATION.md"
    )
    
    for doc in "${docs_to_copy[@]}"; do
        if [[ -f "$SCRIPT_DIR/$doc" ]]; then
            cp "$SCRIPT_DIR/$doc" .
            log_success "Copied: $doc"
        fi
    done
    
    # Create workspace-specific files
    log_info "Creating workspace files..."
    
    # Create a simple README for the workspace
    cat > "WORKSPACE-README.md" << 'EOF'
# WordPress Symlink Management Workspace

This directory contains your active WordPress symlink management tools.

## Quick Start

1. **Configure your sites**: Edit `symlink-config.json` with your actual site paths
2. **Test first**: Run `./enhanced-reset_wp_symlinks.sh --dry-run`
3. **Execute**: Run `./enhanced-reset_wp_symlinks.sh`

## Files in this workspace

- `enhanced-reset_wp_symlinks.sh` - Main symlink management script
- `restore-from-backup.sh` - Backup restoration utility
- `symlink-config.json` - Your site configuration (customize this!)
- `backups/` - Automatic backups (created when script runs)

## Common Commands

```bash
# Preview what would be done
./enhanced-reset_wp_symlinks.sh --dry-run

# Run with auto-detection
./enhanced-reset_wp_symlinks.sh

# Interactive mode for ambiguous matches
./enhanced-reset_wp_symlinks.sh --interactive

# Use custom config
./enhanced-reset_wp_symlinks.sh --config symlink-config.json

# Restore from backup
./restore-from-backup.sh
```

## Configuration

Edit `symlink-config.json` to customize:
- Site-to-repository mappings
- Global exclusion rules
- Auto-detection settings

See `MIGRATION.md` for detailed setup instructions.
EOF
    
    log_success "Created: WORKSPACE-README.md"
    
    # Create alias suggestions
    cat > "setup-aliases.sh" << EOF
#!/bin/bash
# Add these aliases to your shell profile (.bashrc, .zshrc, etc.)

# WordPress Symlink Management Aliases
alias wp-symlinks='cd "$workspace"'
alias wp-sync='$workspace/enhanced-reset_wp_symlinks.sh'
alias wp-sync-dry='$workspace/enhanced-reset_wp_symlinks.sh --dry-run'
alias wp-restore='$workspace/restore-from-backup.sh'

echo "WordPress symlink aliases added!"
echo "Run 'source ~/.bashrc' (or ~/.zshrc) to activate them."
EOF
    
    chmod +x "setup-aliases.sh"
    log_success "Created: setup-aliases.sh"
    
    # Final instructions
    echo
    log_success "Workspace setup complete!"
    echo
    log_info "Next steps:"
    echo -e "  1. ${CYAN}cd $workspace${NC}"
    echo -e "  2. ${CYAN}nano symlink-config.json${NC} (customize for your sites)"
    echo -e "  3. ${CYAN}./enhanced-reset_wp_symlinks.sh --dry-run${NC} (test first)"
    echo -e "  4. ${CYAN}./enhanced-reset_wp_symlinks.sh${NC} (run for real)"
    echo
    log_info "Optional: Add convenient aliases:"
    echo -e "  ${CYAN}./setup-aliases.sh >> ~/.bashrc${NC}"
    echo
    log_info "Workspace location: $workspace"
    log_info "Backups will be created in: $workspace/backups/"
}

main "$@"