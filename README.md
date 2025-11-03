# macOS Cache Manager

A powerful command-line tool to scan, analyze, and clean cache folders on macOS. Free up disk space by safely removing unnecessary cache files from applications, development tools, system folders, and more.

## Features

- 🔍 **Smart Scanning** - Automatically detects cache folders across your system
- 📊 **Real-time Size Calculation** - Live updates as it calculates folder sizes
- 🎨 **Color-coded Categories** - Easy identification of cache types
- ⚡ **Fast & Accurate Modes** - Choose between speed and precision
- 🎯 **Selective Deletion** - Delete all, by category, or individual folders
- 🔒 **Safe Operations** - Confirmation prompts before any deletion
- ⏱️ **Performance Metrics** - Shows calculation time

## Cache Categories

The tool organizes caches into 5 color-coded categories:

- **🟢 USER** - Application caches (browsers, npm, pip, yarn, gem, etc.)
- **🔵 DEV** - Development tools (Xcode, Gradle, Docker, VS Code, Cargo, etc.)
- **🔴 SYSTEM** - macOS system caches (requires admin privileges)
- **🟡 TEMP** - Temporary files, logs, and miscellaneous data
- **🟣 ANDROID** - Android Studio build folders

## Installation

1. Clone or download the script:
```bash
git clone https://github.com/ali-moghadam/mac-cache-manager.git
cd mac-cache-manager
```

2. Make it executable:
```bash
chmod +x mac-cache-manager.sh
```

## Usage

### Basic Usage (Fast Mode)

Run with default fast mode for quick results:

```bash
bash mac-cache-manager.sh
```

or

```bash
./mac-cache-manager.sh
```

### Accurate Mode

For precise size calculations (slower but exact):

```bash
bash mac-cache-manager.sh --accurate
```

or

```bash
bash mac-cache-manager.sh -a
```

## How It Works

### 1. Scanning Phase
The tool quickly scans your system for known cache locations:
- User application caches
- Development tool caches
- System cache directories
- Android Studio build folders

### 2. Calculation Phase
Calculates the size of each detected folder:
- **Fast Mode**: Single `du -sk` call per folder (~2x faster)
- **Accurate Mode**: Uses system's `du -sh` formatting for precision
- Shows live loading indicators (⏳) that update to actual sizes
- Displays progress for Android build folder scanning

### 3. Summary Display
Shows:
- Complete list of cache folders with sizes
- Total cache size
- Calculation time
- Size breakdown by category

### 4. Deletion Menu
Interactive menu with options:
- **A** - Delete ALL caches
- **1-N** - Delete specific folder by number
- **U** - Delete all USER caches
- **D** - Delete all DEV caches
- **S** - Delete all SYSTEM caches
- **T** - Delete all TEMP caches
- **N** - Delete all ANDROID build folders
- **Q** - Quit without deleting
- **Enter** - Quick exit

## Examples

### Example Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        macOS Cache Manager
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This tool scans and helps you clean cache folders on your Mac.

📁 Cache Categories:
  ● USER    → Application caches (browsers, npm, pip, yarn, etc.)
  ● DEV     → Development tools (Xcode, Gradle, Docker, VS Code, etc.)
  ● SYSTEM  → macOS system caches (requires admin privileges)
  ● TEMP    → Temporary files and logs
  ● ANDROID → Android Studio build folders

⚡ Fast Mode: Quick size estimation (use --accurate flag for precise sizes)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Scanning for cache folders...

🔢 Calculating sizes of existing cache folders...
----------------------------
No. Folder                                                                           Type       Size      
--------------------------------------------------------------------------------
1   /Users/username/Library/Caches                                                   USER       4.4G      
2   /Users/username/.gradle/caches                                                   DEV        26G       
3   /Users/username/AndroidStudioProjects                                            ANDROID    8.8G      
...
----------------------------
💾 Total cache size: 76.52G
⏱️  Calculation time: 1m 15s
----------------------------

A) Delete ALL (76.5G)
1-28) Delete specific folder by number
U) Delete USER caches (21.6G)
D) Delete DEV caches (38.2G)
S) Delete SYSTEM caches (3.6G)
T) Delete TEMP caches (1.7G)
N) Delete ANDROID caches (8.8G)
Q) Quit

Choose an option (A/U/D/S/T/N/1-28/Q):
```

### Example Workflows

#### Clean All User Caches
```bash
bash mac-cache-manager.sh
# Choose: U
# Confirm: y
```

#### Delete Specific Folder
```bash
bash mac-cache-manager.sh
# Choose: 5 (folder number)
# Confirm: y
```

#### Clean Everything
```bash
bash mac-cache-manager.sh
# Choose: A
# Confirm: y
```

## Cached Locations

The tool scans the following locations:

### USER Caches
- `~/Library/Caches/*`
- `~/Library/Containers`
- `~/.cache`
- `~/.npm`
- `~/.gem`
- `~/.composer/cache`
- Browser caches (Chrome, Safari, Firefox)
- Homebrew cache

### DEV Caches
- `~/Library/Developer/Xcode/DerivedData`
- `~/Library/Developer/CoreSimulator`
- `~/.gradle/caches`
- `~/.m2/repository`
- `~/Library/Application Support/Code/Cache` (VS Code)
- `~/.cargo/registry` (Rust)
- Docker VM data
- CocoaPods cache

### SYSTEM Caches
- `/Library/Caches`
- `/System/Library/Caches`
- `/private/var/folders`
- `/private/var/log`

### TEMP Files
- `/tmp`
- `/private/var/tmp`
- `~/Library/Logs`
- `/Library/Updates`

### ANDROID Builds
- `~/AndroidStudioProjects/*/build`
- `~/StudioProjects/*/build`

## Safety Features

1. **Confirmation Prompts** - Always asks before deletion
2. **Type Safety** - Only deletes recognized cache types
3. **Sudo Protection** - Requires password for system caches
4. **Preview Before Delete** - See sizes before confirming
5. **Selective Deletion** - Choose exactly what to remove

## Performance

### Fast Mode (Default)
- Uses single `du -sk` call per folder
- ~2x faster than accurate mode
- Good enough for most use cases
- Calculation time: ~30s-2m depending on system

### Accurate Mode
- Uses system's `du -sh` for precise formatting
- Slightly slower but exact sizes
- Better for detailed analysis
- Calculation time: ~1m-3m depending on system

## Troubleshooting

### "Permission denied" errors
Some system folders require admin privileges. The script will:
- Show "N/A" for inaccessible folders
- Not count them in totals
- Ask for sudo password when deleting system caches

### Slow calculation
- Use fast mode (default) for quicker results
- Large Android projects can take time
- Consider deleting specific folders instead of scanning all

### Script not executable
```bash
chmod +x mac-cache-manager.sh
```

## Requirements

- macOS (tested on macOS 10.14+)
- Bash 3.2+ (pre-installed on macOS)
- Standard Unix tools: `du`, `find`, `awk`, `bc`

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new cache locations
- Improve performance
- Enhance documentation

## License

MIT License - feel free to use and modify

## Warnings

⚠️ **Important Notes:**
- Always review what you're deleting
- Some caches will rebuild automatically
- System caches may affect performance temporarily
- Backup important data before bulk deletions
- Don't delete caches of actively running applications

## FAQ

**Q: Is it safe to delete all caches?**  
A: Generally yes, but caches exist to improve performance. Applications will recreate them as needed.

**Q: Will this speed up my Mac?**  
A: It frees disk space but may temporarily slow apps until caches rebuild.

**Q: How often should I run this?**  
A: Monthly or when running low on disk space.

**Q: Can I automate this?**  
A: Yes, but be cautious with automated deletions. Better to review manually.

**Q: What's the difference between fast and accurate mode?**  
A: Fast mode calculates faster with negligible precision difference. Accurate mode uses system formatting.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Made with ❤️ for macOS users who love a clean system**
