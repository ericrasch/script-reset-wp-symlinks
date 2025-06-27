# GitHub Actions Workflows

This directory contains automated workflows for the WordPress Symlink Manager repository.

## Workflows Overview

### 🔍 **ShellCheck** (`shellcheck.yml`)
- **Triggers**: Push/PR to main with shell script changes
- **Purpose**: Static analysis of shell scripts for common issues
- **Checks**: Syntax errors, potential bugs, style issues
- **Ignores**: User-specific config files (gitignored)

### 🧪 **Test Scripts** (`test-scripts.yml`)
- **Triggers**: Push/PR to main
- **Purpose**: Validate script functionality across environments
- **Tests**:
  - Bash compatibility (versions 4.4, 5.0, 5.1)
  - Syntax validation
  - JSON generation validity
  - Cross-platform compatibility (Ubuntu/macOS)

### 📚 **Documentation Check** (`docs-check.yml`)
- **Triggers**: Push/PR to main with documentation changes
- **Purpose**: Ensure documentation quality and consistency
- **Checks**:
  - Markdown link validation
  - Script reference consistency
  - Documentation sync with actual files

### 🔒 **Security Scan** (`security.yml`)
- **Triggers**: Push/PR to main, weekly schedule
- **Purpose**: Security and privacy protection
- **Scans**:
  - Secret detection (TruffleHog)
  - Sensitive pattern identification
  - File permission validation

### 🚀 **Release** (`release.yml`)
- **Triggers**: Git tags matching `v*`
- **Purpose**: Automated release creation
- **Features**:
  - Changelog extraction
  - Release notes generation
  - Installation instructions

## Configuration Files

- `markdown-link-check-config.json` - Link checker configuration
- `README.md` - This documentation file

## Adding New Workflows

When adding new workflows:

1. **Follow naming convention**: `verb-noun.yml`
2. **Add appropriate triggers**: Only run when necessary
3. **Include error handling**: Fail fast with clear messages
4. **Document purpose**: Add description in this README
5. **Test locally**: Use `act` or similar tools when possible

## Workflow Status

All workflows should pass before merging to main. Status badges will be available after first commit:

<!-- 
Status badges (uncomment after workflows are committed and run):
- [![ShellCheck](../../actions/workflows/shellcheck.yml/badge.svg)](../../actions/workflows/shellcheck.yml)
- [![Test Scripts](../../actions/workflows/test-scripts.yml/badge.svg)](../../actions/workflows/test-scripts.yml)
- [![Documentation Check](../../actions/workflows/docs-check.yml/badge.svg)](../../actions/workflows/docs-check.yml)
- [![Security Scan](../../actions/workflows/security.yml/badge.svg)](../../actions/workflows/security.yml)
-->

## Local Testing

To test workflows locally:

```bash
# Install act (GitHub Actions local runner)
brew install act

# Run specific workflow
act -j shellcheck

# Run all push triggers
act push
```

## Maintenance

- Review workflow efficiency monthly
- Update action versions quarterly
- Monitor for deprecated features
- Adjust triggers based on repository activity