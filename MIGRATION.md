# Migration Guide: Legacy to Enhanced Script

This guide helps you migrate from the legacy array-based script to the new enhanced auto-detection script.

## Quick Start Migration

### 1. Install Dependencies
```bash
brew install jq
```

### 2. Test Enhanced Script
```bash
# Make executable
chmod +x generate-wp-symlinks.sh

# Run in dry-run mode first
./generate-wp-symlinks.sh --dry-run
```

### 3. Run Enhanced Script
```bash
# Auto-detection mode (recommended)
./generate-wp-symlinks.sh
```

## Key Advantages of Enhanced Script

| Feature | Legacy Script | Enhanced Script |
|---------|---------------|-----------------|
| **Setup** | Manual array configuration | Auto-detection |
| **Maintenance** | Update arrays for each change | Zero maintenance |
| **Plugin Support** | Manual plugin path addition | Auto-detection |
| **Site Discovery** | Hardcoded paths | Reads LocalWP config |
| **New Sites** | Manual array updates | Automatic discovery |
| **Preview Changes** | No | Dry-run mode |
| **Interactive Mode** | No | Yes |
| **Configuration** | Hardcoded in script | External JSON file |

## What the Enhanced Script Detects Automatically

### From your current manual configuration:
```bash
# Legacy - Manual arrays
GITHUB_THEMES=(
    "$HOME/Sites/github/wp-example-com/wp-content/themes/example-theme"
    "$HOME/Sites/github/wp-mysite-com/wp-content/plugins/custom-plugin"
    # ... multiple more entries
)
```

### Enhanced - Auto-detected:
- ✅ **LocalWP Sites**: Reads from `~/Library/Application Support/Local/sites.json`
- ✅ **GitHub Repos**: Scans `~/Sites/github/wp-*` directories
- ✅ **Themes**: Auto-discovers all custom themes
- ✅ **Plugins**: Auto-discovers custom plugins (excludes common WP plugins)
- ✅ **Custom Dirs**: Finds `app_resources`, `lib`, etc.

## Migration Verification

### 1. Compare Output
Run both scripts in comparison:

```bash
# Legacy script output
./active-reset_wp_symlinks.sh

# Enhanced script dry-run
./generate-wp-symlinks.sh --dry-run
```

### 2. Validate Detection
The enhanced script should detect all your current manual mappings:

**Detected Sites:**
- Example.com ↔ wp-example-com
- MyWebsite.com ↔ wp-mywebsite-com
- ClientSite.com ↔ wp-clientsite-com
- (and additional sites)

**Auto-discovered Paths:**
- Themes: `custom-theme`, `parent-theme`, `child-theme`, etc.
- Plugins: `custom-plugin`, `site-framework`, etc.
- Custom: `app_resources`, `lib`

## Handling Special Cases

### 1. Sites with Non-standard Matching
If auto-detection misses a site, create `symlink-config.json`:

```json
{
  "overrides": {
    "specialsite": {
      "github_repo": "wp-special-site-repo",
      "include_only": [
        "wp-content/themes/custom-theme"
      ]
    }
  }
}
```

### 2. Excluding Unwanted Plugins
```json
{
  "global_excludes": {
    "plugins": [
      "akismet",
      "woocommerce",
      "your-plugin-to-exclude"
    ]
  }
}
```

## Rollback Plan

If you need to rollback to the legacy script:

1. **Keep Legacy Script**: Your `active-reset_wp_symlinks.sh` remains functional
2. **No Changes Made**: Enhanced script only creates the same symlinks
3. **Safe Migration**: Both scripts create identical results

## Advanced Configuration

### Custom Configuration File
```bash
# Copy example config
cp symlink-config.json.example symlink-config.json

# Edit for your needs
nano symlink-config.json

# Use custom config
./generate-wp-symlinks.sh --config symlink-config.json
```

### Interactive Mode for New Sites
```bash
# Use interactive mode when adding new sites
./generate-wp-symlinks.sh --interactive
```

## Troubleshooting

### Missing jq Dependency
```bash
# Error: jq: command not found
brew install jq
```

### Sites Not Detected
1. Check LocalWP is running
2. Verify sites exist in `~/Local Sites/`
3. Use `--interactive` mode
4. Create manual override in config file

### GitHub Repos Not Found
1. Verify repos are in `~/Sites/github/`
2. Ensure repos have `wp-content` directory
3. Check repo naming follows `wp-*` pattern

## Benefits After Migration

1. **Zero Maintenance**: New sites auto-detected
2. **Plugin Support**: All custom plugins automatically included
3. **Error Prevention**: Can't forget to add new sites
4. **Flexibility**: Configuration overrides for special cases
5. **Safety**: Dry-run mode prevents accidents
6. **Visibility**: Clear output showing what's being processed

## Support

If you encounter issues during migration:
1. Run `./generate-wp-symlinks.sh --help`
2. Test with `--dry-run` mode first
3. Use `--interactive` for ambiguous cases
4. Check LocalWP sites.json exists and is readable