# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a bash script utility for LocalWP WordPress development that automates the process of resetting symbolic links between WordPress theme directories and their corresponding GitHub repositories. The script handles cases where WP Engine syncs overwrite symlinks with actual folders.

## Core Architecture

- **Single Script**: `reset_wp_symlinks.sh` - Main executable that manages theme symlinks
- **Array-based Configuration**: Uses parallel `GITHUB_THEMES` and `LOCAL_THEMES` arrays to define source and destination paths
- **Validation Layer**: Includes checks for LocalWP site existence, array length matching, and path validation
- **Error Handling**: Comprehensive error reporting with emoji-prefixed status messages

## Key Functions

- `reset_symlink()`: Core function that handles symlink creation, validation, and replacement
- Array length validation to ensure GITHUB_THEMES and LOCAL_THEMES match
- Path expansion handling for tilde (~) notation
- Parent directory creation when missing

## Development Commands

Since this is a bash script project, testing involves:

```bash
# Make script executable
chmod +x reset_wp_symlinks.sh

# Run the script
./reset_wp_symlinks.sh

# Test with bash debug mode
bash -x reset_wp_symlinks.sh
```

## Customization Points

When modifying the script for different environments:

1. Update `GITHUB_THEMES` array with actual GitHub repository theme paths
2. Update `LOCAL_THEMES` array with actual LocalWP installation theme paths
3. Ensure arrays maintain matching indices for corresponding source/destination pairs

## Script Behavior

- Skips recreation if symlink already exists and points to correct location
- Removes and replaces incorrect symlinks
- Removes actual directories that should be symlinks (WP Engine overwrites)
- Creates missing parent directories automatically
- Validates LocalWP site existence before attempting symlink creation

## Version Information

Current version: 1.7 (as indicated in script header)