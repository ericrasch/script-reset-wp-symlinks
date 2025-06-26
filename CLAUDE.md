# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a bash script utility for LocalWP WordPress development that automates the process of resetting symbolic links between WordPress theme/plugin directories and their corresponding GitHub repositories. The project includes both a legacy manual script and an enhanced auto-detection version.

## Core Architecture

### Enhanced Script (recommended): `enhanced-reset_wp_symlinks.sh`

- **Auto-Detection**: Reads LocalWP's `sites.json` to discover active sites
- **Smart Matching**: Automatically matches LocalWP sites to GitHub repositories
- **Flexible Symlink Discovery**: Auto-detects themes, plugins, and custom directories
- **Configuration Support**: Optional JSON config file for custom mappings and overrides
- **Interactive Mode**: Prompts for ambiguous matches when enabled
- **Dry-Run Mode**: Preview changes without executing them

### Legacy Script: `reset_wp_symlinks.sh` / `active-reset_wp_symlinks.sh`

- **Array-based Configuration**: Uses parallel `GITHUB_THEMES` and `LOCAL_THEMES` arrays
- **Manual Setup**: Requires hardcoded paths for each site
- **Single Function**: `reset_symlink()` handles symlink creation and validation

## Key Features

### Enhanced Script Functions

- `get_localwp_sites()`: Parses LocalWP's sites.json configuration
- `find_github_repos()`: Discovers WordPress repositories in GitHub directory
- `match_sites_to_repos()`: Smart matching with multiple strategies
- `discover_symlink_targets()`: Auto-detects themes, plugins, and custom directories
- `create_symlink()`: Handles symlink creation with comprehensive validation

### Configuration System

- JSON-based configuration file support (`symlink-config.json`)
- Global excludes for common WordPress themes/plugins
- Site-specific overrides for special cases
- Auto-detection settings and fallbacks

## Development Commands

### Enhanced Script Usage

```bash
# Make script executable
chmod +x enhanced-reset_wp_symlinks.sh

# Preview changes (recommended first run)
./enhanced-reset_wp_symlinks.sh --dry-run

# Run with auto-detection
./enhanced-reset_wp_symlinks.sh

# Interactive mode for ambiguous matches
./enhanced-reset_wp_symlinks.sh --interactive

# Use custom configuration
./enhanced-reset_wp_symlinks.sh --config custom-config.json

# Get help
./enhanced-reset_wp_symlinks.sh --help
```

### Legacy Script Usage

```bash
# Make script executable
chmod +x reset_wp_symlinks.sh

# Run the script
./reset_wp_symlinks.sh

# Test with bash debug mode
bash -x reset_wp_symlinks.sh
```

## Dependencies

The enhanced script requires:

- `jq` - JSON processor for parsing LocalWP configuration

  ```bash
  brew install jq
  ```

## Customization Points

### Enhanced Script

- **Configuration File**: Copy `symlink-config.json.example` to `symlink-config.json` and customize
- **Base Directories**: Modify `GITHUB_BASE` and `LOCALWP_BASE` variables in script
- **Exclusion Rules**: Add themes/plugins to avoid in configuration file
- **Matching Logic**: Customize site-to-repo matching strategies in `match_sites_to_repos()`

### Legacy Script

1. Update `GITHUB_THEMES` array with actual GitHub repository theme paths
2. Update `LOCAL_THEMES` array with actual LocalWP installation theme paths
3. Ensure arrays maintain matching indices for corresponding source/destination pairs

## Script Behavior

### Enhanced Script

- **Auto-Discovery**: Automatically finds LocalWP sites and GitHub repositories
- **Smart Matching**: Uses multiple strategies to match sites to repositories
- **Plugin Detection**: Automatically detects custom plugins while excluding common WordPress plugins
- **Validation**: Comprehensive checks for LocalWP site existence, source directories, and symlink states
- **Interactive Fallback**: Prompts user for ambiguous matches when enabled
- **Dry-Run Support**: Preview all changes before execution

### Legacy Script

- Skips recreation if symlink already exists and points to correct location
- Removes and replaces incorrect symlinks
- Removes actual directories that should be symlinks (WP Engine overwrites)
- Creates missing parent directories automatically
- Validates LocalWP site existence before attempting symlink creation

## LocalWP Integration

The enhanced script integrates with LocalWP by:

- Reading `/Users/[username]/Library/Application Support/Local/sites.json`
- Extracting active site information (name, path, domain)
- Validating site existence before creating symlinks
- Supporting LocalWP's directory structure conventions

## Version Information

- Enhanced Script: v2.0 (current recommended version)
- Legacy Script: v1.7 (maintained for backward compatibility)
