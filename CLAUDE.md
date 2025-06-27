# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modern WordPress symlink management tool for LocalWP development environments. It provides intelligent auto-detection of LocalWP sites and GitHub repositories, with automatic configuration generation and comprehensive backup management.

## Current Architecture (v2.1+)

### Main Entry Point
- **`wp-symlinks`** - Interactive menu system that guides users through all operations
- Single command interface for setup, configuration, execution, and management

### Core Scripts (in `/scripts` directory)
- **`generate-wp-symlinks.sh`** - Main symlink generation engine with auto-detection
- **`generate-config.sh`** - Auto-configuration generator using LocalWP's sites.json
- **`restore-from-backup.sh`** - Interactive backup restoration utility
- **`setup-workspace.sh`** - Workspace creation and setup

### Configuration System
- **Auto-generated config** via LocalWP sites.json parsing and GitHub repo scanning
- **Smart matching** between LocalWP sites and GitHub repositories  
- **Optional JSON config** (`symlink-config.json`) for custom overrides
- **Backup management** with timestamped directory preservation
- **Include/Exclude Plugins**: Fine-grained control with `include_plugins` and `exclude_plugins` settings

## Key Technical Components

### Auto-Detection Engine
- **LocalWP Integration**: Parses `~/Library/Application Support/Local/sites.json`
- **GitHub Repository Scanning**: Finds WordPress projects in `~/Sites/github/wp-*`
- **Smart Matching Algorithm**: Normalizes names to match sites with repositories
- **Content Discovery**: Auto-detects themes, plugins, and custom directories

### Symlink Management
- **Validation Layer**: Checks LocalWP site existence and source directory validity
- **Backup Creation**: Automatic timestamped backups before replacing directories
- **Path Handling**: Robust support for custom directories (`app_resources`, `lib`, etc.)
- **Error Recovery**: Comprehensive error handling with rollback capabilities

### User Experience
- **Interactive Menu**: Clear workflow guidance with colored output
- **Dry-Run Mode**: Safe preview of all operations before execution
- **Status Display**: Real-time feedback on operations and configurations
- **Help System**: Built-in documentation and workflow guidance

## Development Commands

### Interactive Usage (Recommended)
```bash
# Main interface
./wp-symlinks

# No-color version for compatibility
./wp-symlinks-nocolor
```

### Direct Script Access
```bash
# Auto-detection with dry-run
./scripts/generate-wp-symlinks.sh --dry-run

# Generate configuration
./scripts/generate-config.sh

# Interactive matching
./scripts/generate-wp-symlinks.sh --interactive

# Backup restoration
./scripts/restore-from-backup.sh

# Workspace setup
./scripts/setup-workspace.sh ~/path/to/workspace
```

### Testing Commands
```bash
# Test configuration generation
./scripts/generate-config.sh /tmp/test-config.json

# Test with specific config
./scripts/generate-wp-symlinks.sh --config /path/to/config.json --dry-run

# Test backup functionality
./scripts/restore-from-backup.sh
```

## Configuration Architecture

### Auto-Generated Configuration
```json
{
  "settings": {
    "github_base": "$HOME/Sites/github",
    "localwp_base": "$HOME/Local Sites",
    "auto_detect": true,
    "interactive_fallback": true
  },
  "mappings": [
    {
      "localwp_site": "ExampleSite.com",
      "github_repo": "wp-example-com",
      "paths": [
        "wp-content/themes/custom-theme",
        "wp-content/plugins/custom-plugin"
      ]
    }
  ],
  "global_excludes": {
    "themes": ["twentytwentyone", "twentytwentytwo"],
    "plugins": ["akismet", "hello-dolly", "wordpress-importer"]
  }
}
```

### Workspace Structure
```
~/Sites/scripts/wp-symlinks/
├── wp-symlinks                      # Main menu (copied from repo)
├── generate-wp-symlinks.sh          # Core symlink generation engine
├── generate-config.sh               # Config generator  
├── restore-from-backup.sh           # Backup utility
├── symlink-config.json              # Auto-generated config
├── backups/                         # Timestamped backups
└── documentation files
```

## Dependencies

- **jq** - JSON processor for parsing LocalWP configuration and generating configs
- **bash 4.0+** - For associative arrays and modern shell features
- **find/grep** - Standard UNIX utilities for file discovery

## Error Handling Patterns

- **Validation First**: All paths and configurations validated before execution
- **Graceful Degradation**: Falls back to manual configuration if auto-detection fails
- **Comprehensive Logging**: Color-coded status messages with clear error descriptions
- **Automatic Backup**: Every directory replacement creates timestamped backup
- **Interactive Recovery**: Backup restoration with file browser and confirmation

## Development Notes

- **No Legacy Support**: Version 2.0+ is a complete rewrite with no backward compatibility
- **Terminal Compatibility**: Dual versions (color/no-color) for different terminal environments
- **Workspace Isolation**: User data completely separated from repository
- **Auto-Update Safe**: Repository updates don't affect user workspaces
- **Public Repository Safe**: No sensitive information stored in repository files

## Version History

- **v2.1**: Renamed main script to `generate-wp-symlinks.sh`, added `include_plugins` setting, fixed JSON generation
- **v2.0**: Complete rewrite with auto-detection and interactive menu
- **v1.x**: Deprecated manual array-based configuration (removed from repository)

This architecture provides zero-configuration operation while maintaining full customization capabilities for advanced users.