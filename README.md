# **WordPress Symlink Manager for LocalWP**

## **Overview**

This project provides powerful tools for automating symbolic link management between WordPress themes/plugins in **LocalWP environments** and their corresponding **GitHub repositories**. When WP Engine syncs overwrite your symlinked directories, these scripts ensure your LocalWP sites always point to the correct development repositories.

## **Why Use This Tool?**

✅ **Prevents WP Engine sync from overriding symlinks**  
✅ **Auto-detects LocalWP sites and GitHub repositories**  
✅ **Supports themes, plugins, and custom directories**  
✅ **Creates automatic backups before making changes**  
✅ **Provides dry-run mode for safe testing**  
✅ **Eliminates manual array configuration**  

---

## **🚀 Quick Setup**

### **1️⃣ Install Dependencies**
```bash
brew install jq
```

### **2️⃣ Set Up Your Workspace**
```bash
# Clone or download this repository
cd script-reset-wp-symlinks

# Create your dedicated workspace (recommended: outside the repo)
./setup-workspace.sh

# Or specify custom location
./setup-workspace.sh ~/.wp-symlinks
./setup-workspace.sh ~/Documents/wp-tools
```

### **3️⃣ Configure Your Sites (Auto-Generated!)**
```bash
# Navigate to your workspace
cd ~/Sites/scripts/wp-symlinks

# Your configuration was auto-generated during setup!
# Review what was detected:
cat symlink-config.json

# Re-generate if you add new sites:
./generate-config.sh

# Manual editing (optional - auto-detection works great):
nano symlink-config.json
```

### **4️⃣ Test and Run**
```bash
# Preview what would be done (always run this first!)
./enhanced-reset_wp_symlinks.sh --dry-run

# Execute symlink creation
./enhanced-reset_wp_symlinks.sh

# Interactive mode for ambiguous matches
./enhanced-reset_wp_symlinks.sh --interactive
```

---

## **📁 What Gets Created**

Your workspace will contain:
```
~/Sites/scripts/wp-symlinks/
├── enhanced-reset_wp_symlinks.sh    # Main auto-detection script
├── restore-from-backup.sh           # Backup restoration utility
├── generate-config.sh               # Auto-generate configuration
├── symlink-config.json              # Your personalized configuration (auto-generated!)
├── backups/                         # Automatic backups directory
├── WORKSPACE-README.md              # Quick reference guide
├── setup-aliases.sh                 # Optional shell aliases
└── documentation files
```

## **Key Benefits of This Approach**

| Feature | Manual Setup | This Tool |
|---------|--------------|-----------|
| **Setup** | Edit script arrays for each site | **Auto-generated configuration** |
| **New Sites** | Manual array updates | **Automatic discovery & config generation** |
| **Plugin Support** | Manual path addition | **Auto-detects custom plugins** |
| **Safety** | No backup system | **Automatic timestamped backups** |
| **Testing** | No preview option | **Dry-run mode available** |
| **Maintenance** | High - update paths manually | **Zero - just re-run generator** |

---

## **🔄 How It Works**

### **Auto-Detection Process**
1. **Reads LocalWP configuration** from `~/Library/Application Support/Local/sites.json`
2. **Scans GitHub repositories** in `~/Sites/github/wp-*` directories
3. **Smart matching** between LocalWP sites and GitHub repos
4. **Generates personalized configuration** automatically during setup
5. **Discovers themes, plugins, and custom directories** automatically
6. **Creates backups** before replacing any directories
7. **Validates and creates symlinks** with comprehensive error checking

### **What Gets Symlinked**
- ✅ **Custom themes** (auto-detected in `wp-content/themes/`)
- ✅ **Custom plugins** (excludes common WordPress plugins)
- ✅ **Custom directories** (like `app_resources`, `lib`, etc.)
- ✅ **Per-site customization** via configuration overrides

---

## **💡 Advanced Usage**

### **Auto-Generated Configuration**
The setup automatically generates a personalized `symlink-config.json` based on your actual LocalWP sites and GitHub repositories. For special cases, you can customize it:
```json
{
  "overrides": {
    "specialsite": {
      "github_repo": "wp-special-site-repo", 
      "include_only": ["wp-content/themes/custom-theme"]
    }
  },
  "global_excludes": {
    "plugins": ["plugin-to-skip"]
  }
}
```

### **Command Line Options**
```bash
# Preview all changes without executing
./enhanced-reset_wp_symlinks.sh --dry-run

# Interactive mode for ambiguous site matches
./enhanced-reset_wp_symlinks.sh --interactive

# Use custom configuration file
./enhanced-reset_wp_symlinks.sh --config my-config.json

# Skip automatic backups
./enhanced-reset_wp_symlinks.sh --no-backup

# Enable verbose output
./enhanced-reset_wp_symlinks.sh --verbose
```

### **Configuration Management**
```bash
# Re-generate configuration (when you add new sites)
./generate-config.sh

# View current configuration
cat symlink-config.json
```

### **Backup Management**
```bash
# View and restore backups interactively
./restore-from-backup.sh

# Restore specific backup
./restore-from-backup.sh theme_20250626_143022
```

### **Convenient Aliases (Optional)**
```bash
# Add to your shell profile
./setup-aliases.sh >> ~/.bashrc
source ~/.bashrc

# Then use:
wp-symlinks     # Navigate to workspace
wp-sync-dry     # Dry run
wp-sync         # Execute
wp-restore      # Restore backups
```

---

## **🔒 Security & Privacy**

- **Private workspace** - Your real site configurations stay outside the repository
- **Automatic backups** - Every replaced directory is backed up with timestamps
- **Dry-run mode** - Preview all changes before execution
- **Safe for public repos** - No sensitive site information in the repository

---

## **📚 Documentation**

- **[CHANGELOG.md](CHANGELOG.md)** - Version history and feature changes
- **[MIGRATION.md](MIGRATION.md)** - Upgrade guide from manual arrays to auto-detection
- **[CLAUDE.md](CLAUDE.md)** - Technical architecture for development

---

## **🆘 Troubleshooting**

### **Sites Not Detected**
1. Ensure LocalWP sites exist in `~/Local Sites/`
2. Verify GitHub repos are in `~/Sites/github/` with `wp-content` directories
3. Use `--interactive` mode for manual selection
4. Create custom mappings in `symlink-config.json`

### **Missing Dependencies**
```bash
# Install jq for JSON parsing
brew install jq
```

### **Backup Recovery**
```bash
# List all available backups
./restore-from-backup.sh

# Follow interactive prompts to restore
```

---

## **🚀 Migration from Manual Scripts**

If you're upgrading from manual array-based scripts:

1. **Keep your existing script** - It continues to work
2. **Set up the enhanced workspace** - `./setup-workspace.sh`
3. **Test with dry-run** - `./enhanced-reset_wp_symlinks.sh --dry-run`
4. **Compare results** - Should match your manual configuration
5. **Switch when confident** - Enhanced script requires zero maintenance

See **[MIGRATION.md](MIGRATION.md)** for detailed upgrade instructions.

---

## **📄 License**

This project is licensed under the **MIT License**. You are free to use, modify, and distribute it as needed. See the [LICENSE](LICENSE) file for full details.

---

## **🎯 Ready to Get Started?**

1. **Install dependencies**: `brew install jq`
2. **Set up workspace**: `./setup-workspace.sh`
3. **Test safely**: `./enhanced-reset_wp_symlinks.sh --dry-run`
4. **Go live**: `./enhanced-reset_wp_symlinks.sh`

Transform your LocalWP workflow from manual maintenance to zero-configuration automation! 🚀