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

### 📦 **Release Automation** (`release-automation.yml`)
- **Triggers**: Manual workflow dispatch
- **Purpose**: Prepare releases with changelog updates
- **Features**:
  - Creates release branch
  - Updates CHANGELOG.md template
  - Provides PR creation link and template
  - Shows instructions in workflow summary

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

## Release Process

### Creating a New Release

1. **Start the release process**:
   - Go to the Actions tab on GitHub
   - Click on "Release Automation" in the left sidebar
   - Click "Run workflow"
   - Enter the new version number (e.g., `2.1.2`)
   - Select the release type (patch/minor/major)
   - Choose changelog mode:
     - **check_existing**: Use existing changelog entry (if exists) or create template
     - **auto_generate**: Generate from git commits since last tag/base version
     - **manual_template**: Always create empty template to fill manually
   - Optionally specify base version for auto-generation (e.g., `v2.1.0`)
   - Click "Run workflow"

2. **Create the Pull Request**:
   - The workflow will push a branch with the CHANGELOG template
   - Click the link in the workflow summary to create the PR
   - Copy the PR template from the summary
   
3. **Update the changelog**:
   - Edit the CHANGELOG.md in the PR to fill in actual changes:
     - `### Added` - for new features
     - `### Changed` - for changes in existing functionality
     - `### Fixed` - for bug fixes
     - `### Removed` - for removed features
   - Remove any empty sections
   - Review and merge the PR

4. **Create and push the tag**:
   ```bash
   # After merging the PR, pull the latest changes
   git pull origin main
   
   # Create and push the tag (replace X.Y.Z with your version)
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   ```

5. **Automatic release creation**:
   - The `release.yml` workflow will automatically:
     - Extract the changelog for this version
     - Create a GitHub release with the changelog
     - Add installation instructions

### Quick Release (for patch versions)

For simple patch releases with just bug fixes:

```bash
# Make sure you're on main and up to date
git checkout main
git pull origin main

# Tag and push (the release will be created automatically)
git tag -a v2.1.2 -m "Fix: Brief description of fixes"
git push origin v2.1.2
```

**Note**: Remember to update CHANGELOG.md manually after the release if you use the quick method.

## Maintenance

- Review workflow efficiency monthly
- Update action versions quarterly
- Monitor for deprecated features
- Adjust triggers based on repository activity