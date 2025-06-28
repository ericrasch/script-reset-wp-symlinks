# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2025-06-27

### Changed

- **Renamed main script** - `generate-wp-symlinks.sh` → `generate-wp-symlinks.sh` for clarity
- **Reorganized repository structure** - Moved core scripts to `/scripts` subdirectory
- **Single entry point** - `wp-symlinks` is now the only executable in root directory
- **Cleaner architecture** - Professional CLI tool organization pattern
- **Fixed terminal compatibility** - Improved color code handling with `printf`

### Added

- **Include/Exclude plugin control** - New `include_plugins` setting to force inclusion of specific plugins
- **Interactive menu system** (`wp-symlinks`) - Guided workflows for all operations
- **Repository structure documentation** (`REPOSITORY-STRUCTURE.md`)

### Fixed

- **JSON generation** - Fixed ANSI color codes leaking into generated configuration files
- **Plugin detection** - Improved handling of plugins that should always be included

### Removed

- **Legacy script** (`reset_wp_symlinks.sh`) - Superseded by enhanced auto-detection
- **Manual array configuration** - Replaced with intelligent auto-generation

## [2.0.0] - 2025-06-26

### Added

- **Enhanced auto-detection script** (`generate-wp-symlinks.sh`) with smart LocalWP and GitHub repository discovery
- **Automatic backup functionality** - Creates timestamped backups before replacing directories
- **Backup restoration tool** (`restore-from-backup.sh`) with interactive selection and preview
- **Configuration file support** - Optional JSON configuration for custom mappings and overrides
- **Interactive mode** - Prompts for ambiguous site-to-repository matches
- **Dry-run mode** - Preview all changes before execution with `--dry-run` flag
- **Smart plugin detection** - Auto-discovers custom plugins while excluding common WordPress plugins
- **LocalWP integration** - Reads LocalWP's `sites.json` for active site discovery
- **Flexible symlink discovery** - Automatically detects themes, plugins, and custom directories
- **Comprehensive logging** - Color-coded output with detailed status messages
- **Command-line options** - Support for `--interactive`, `--config`, `--no-backup`, `--verbose`
- **Dependency checking** - Validates required tools (jq) are installed
- **Migration guide** (`MIGRATION.md`) - Detailed guide for upgrading from legacy script

### Enhanced

- **Improved .gitignore** - Added comprehensive patterns including `.history/`, backup directories, and sensitive configuration files
- **Security improvements** - Removed all sensitive site information from public repository files
- **Documentation updates** - Updated `CLAUDE.md` with enhanced script architecture and usage
- **Error handling** - Comprehensive validation for LocalWP sites, GitHub repositories, and symlink states

### Changed

- **Repository structure** - Organized files with clear separation between public templates and private configurations
- **Configuration approach** - Moved from hardcoded arrays to flexible auto-detection with optional overrides
- **Backup strategy** - Automatic backups replace manual backup recommendations

### Fixed

- **Markdown linting issues** - Corrected formatting in all documentation files
- **Path validation** - Enhanced validation for LocalWP site existence and GitHub repository structure

### Security

- **Sensitive data protection** - All real site names and paths moved to gitignored files
- **Public repository safety** - Repository now safe for public sharing with example configurations only

## [1.7.0] - 2025-03-07

### Added

- Validation for LocalWP site existence before symlink creation
- Enhanced error handling and status messages
- Support for custom directory structures (`app_resources`, `lib`)

### Changed

- Improved symlink validation logic
- Enhanced parent directory creation

### Fixed

- Issues with missing parent directories
- Symlink detection accuracy

## [1.6.2] - 2025-03-07

### Added

- Plugin symlink support mixed with theme symlinks
- Multiple site management in single script
- Array length validation for GITHUB_THEMES and LOCAL_THEMES

### Changed

- Expanded from theme-only to theme and plugin support
- Improved error messaging

## [1.0.0] - 2025-03-07

### Added

- Initial release of WordPress symlink management script
- Basic theme directory symlink creation
- LocalWP to GitHub repository linking
- Manual array-based configuration
- Symlink validation and replacement logic

---

## Migration Information

### Upgrading to v2.0.0

**For existing users:** The enhanced script (`generate-wp-symlinks.sh`) provides full backward compatibility while adding powerful auto-detection features. Your existing manual configuration in `active-reset_wp_symlinks.sh` will continue to work, but we recommend trying the enhanced script for easier maintenance.

**Key benefits of upgrading:**

- Zero manual configuration required
- Automatic discovery of new sites and repositories
- Built-in backup and restoration capabilities
- Interactive mode for ambiguous cases
- Dry-run mode for safe testing

See `MIGRATION.md` for detailed upgrade instructions.

### Version Compatibility

- **v2.0.0+**: Enhanced auto-detection with optional configuration files
- **v1.x**: Manual array-based configuration (legacy, still supported)

### Dependencies

- **v2.0.0+**: Requires `jq` for JSON parsing (`brew install jq`)
- **v1.x**: No external dependencies

---

## Contributing

When contributing to this project, please:

1. Follow [Semantic Versioning](https://semver.org/) for version numbers
2. Update this changelog with your changes
3. Test both legacy and enhanced scripts
4. Ensure no sensitive information is committed
5. Update documentation as needed

## Support

For questions about specific versions or upgrade paths, please check:

- `MIGRATION.md` for upgrade guidance
- `README.md` for current usage instructions
- `CLAUDE.md` for technical architecture details
