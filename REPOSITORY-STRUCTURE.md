# Repository Structure

## Clean Architecture

```
script-reset-wp-symlinks/
├── wp-symlinks              # 🎯 MAIN ENTRY POINT (interactive menu)
├── scripts/                 # Core functionality scripts
│   ├── enhanced-reset_wp_symlinks.sh    # Main symlink engine
│   ├── generate-config.sh               # Auto-configuration generator
│   ├── restore-from-backup.sh           # Backup restoration
│   └── setup-workspace.sh               # Workspace installer
├── symlink-config.json.example          # Configuration template
├── reset_wp_symlinks.sh                 # Legacy script (v1.x)
├── active-reset_wp_symlinks.sh          # User's personal config (gitignored)
├── README.md                            # Main documentation
├── CHANGELOG.md                         # Version history
├── MIGRATION.md                         # Upgrade guide
├── CLAUDE.md                            # Technical architecture
├── LICENSE                              # MIT License
└── .gitignore                           # Excludes sensitive files
```

## Key Benefits of This Structure

1. **Clean Root Directory**
   - Only one executable: `wp-symlinks`
   - Documentation and configs at root level
   - Technical scripts organized in `/scripts`

2. **User-Friendly**
   - Single entry point for beginners
   - Clear separation of concerns
   - Advanced users can still access `/scripts` directly

3. **Professional Organization**
   - Follows common CLI tool patterns
   - Easy to navigate
   - Clear purpose for each file

## Usage Paths

### Beginner Path
```bash
./wp-symlinks  # Interactive menu handles everything
```

### Advanced Path
```bash
./scripts/enhanced-reset_wp_symlinks.sh --dry-run
./scripts/generate-config.sh
./scripts/restore-from-backup.sh
```

### Workspace Structure (After Setup)
```
~/Sites/scripts/wp-symlinks/
├── wp-symlinks              # Copied main menu
├── enhanced-reset_wp_symlinks.sh
├── generate-config.sh
├── restore-from-backup.sh
├── symlink-config.json      # Your personalized config
└── backups/                 # Automatic backups
```