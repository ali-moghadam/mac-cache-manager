#!/bin/bash

# Show help message
show_help() {
    SCRIPT_NAME=$(basename "$0")
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "                          🧹 macOS Cache Manager"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    printf "📖 \033[1mUSAGE\033[0m\n"
    echo "   ./$SCRIPT_NAME [OPTIONS]"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "⚙️  \033[1mOPTIONS\033[0m\n"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    printf "  \033[1;36m-h, --help\033[0m\n"
    echo "     Show this help message"
    echo ""
    printf "  \033[1;36m-a, --accurate\033[0m\n"
    echo "     Use accurate mode for precise size calculation (slower)"
    echo ""
    printf "  \033[1;36m-s, --skip-calculation\033[0m\n"
    echo "     Skip size calculation and show delete menu immediately"
    echo ""
    printf "  \033[1;36m-i, --ignore\033[0m TYPE\n"
    echo "     Ignore specific cache type(s) from calculation"
    echo "     Can be specified multiple times or comma-separated"
    printf "     \033[2mValid types: USER, DEV, SYSTEM, TEMP, ANDROID\033[0m\n"
    echo ""
    printf "  \033[1;36m-d, --debug\033[0m\n"
    echo "     Enable debug mode (show detailed scanning and deletion output)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "📁 \033[1mCACHE CATEGORIES\033[0m\n"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    printf "  \033[0;32m●\033[0m \033[1mUSER\033[0m    → Application caches (browsers, npm, pip, yarn, etc.)\n"
    printf "  \033[0;34m●\033[0m \033[1mDEV\033[0m     → Development tools (Xcode, Gradle, Docker, VS Code, etc.)\n"
    printf "  \033[0;31m●\033[0m \033[1mSYSTEM\033[0m  → macOS system caches (requires admin privileges)\n"
    printf "  \033[0;33m●\033[0m \033[1mTEMP\033[0m    → Temporary files and logs\n"
    printf "  \033[0;35m●\033[0m \033[1mANDROID\033[0m → Android Studio build folders\n"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "💡 \033[1mEXAMPLES\033[0m\n"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    printf "  \033[2m# Run in fast mode (default)\033[0m\n"
    echo "  ./$SCRIPT_NAME"
    echo ""
    printf "  \033[2m# Run with precise size calculation\033[0m\n"
    echo "  ./$SCRIPT_NAME --accurate"
    echo ""
    printf "  \033[2m# Skip size calculation, show delete menu only\033[0m\n"
    echo "  ./$SCRIPT_NAME --skip-calculation"
    echo ""
    printf "  \033[2m# Skip calculation and ignore DEV caches\033[0m\n"
    echo "  ./$SCRIPT_NAME -s -i DEV"
    echo ""
    printf "  \033[2m# Ignore DEV caches from calculation\033[0m\n"
    echo "  ./$SCRIPT_NAME --ignore DEV"
    echo ""
    printf "  \033[2m# Ignore multiple cache types\033[0m\n"
    echo "  ./$SCRIPT_NAME -i DEV -i SYSTEM"
    echo "  ./$SCRIPT_NAME -i DEV,ANDROID"
    echo ""
    printf "  \033[2m# Accurate mode with ignored types\033[0m\n"
    echo "  ./$SCRIPT_NAME -a -i DEV"
    echo ""
    printf "  \033[2m# Debug mode\033[0m\n"
    echo "  ./$SCRIPT_NAME --debug"
    echo "  ./$SCRIPT_NAME -d -i ANDROID"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    exit 0
}

# Parse command line arguments
FAST_MODE=true
IGNORE_TYPES=()
DEBUG_MODE=false
SKIP_CALCULATION=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -a|--accurate)
            FAST_MODE=false
            shift
            ;;
        -s|--skip-calculation)
            SKIP_CALCULATION=true
            shift
            ;;
        -d|--debug)
            DEBUG_MODE=true
            shift
            ;;
        -i|--ignore)
            if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                # Split by comma and add to ignore array
                IFS=',' read -ra TYPES <<< "$2"
                for type in "${TYPES[@]}"; do
                    type=$(echo "$type" | tr '[:lower:]' '[:upper:]' | xargs)  # Convert to uppercase and trim
                    if [[ "$type" =~ ^(USER|DEV|SYSTEM|TEMP|ANDROID)$ ]]; then
                        IGNORE_TYPES+=("$type")
                    else
                        echo "Warning: Invalid cache type '$type' ignored. Valid types: USER, DEV, SYSTEM, TEMP, ANDROID"
                    fi
                done
                shift 2
            else
                echo "Error: --ignore requires a cache type argument"
                exit 1
            fi
            ;;
        *)
            echo "Error: Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# ANSI color codes
GREEN='\033[0;32m'   # User cache
BLUE='\033[0;34m'    # Developer/App cache
RED='\033[0;31m'     # System cache
YELLOW='\033[0;33m'  # Temp / misc
MAGENTA='\033[0;35m' # Android Studio build
NC='\033[0m'         # No Color

# Function to convert bytes to human-readable format
bytes_to_human() {
    local bytes=$1
    if [ $bytes -ge 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc)G"
    elif [ $bytes -ge 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc)M"
    elif [ $bytes -ge 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc)K"
    else
        echo "${bytes}B"
    fi
}

# Function to delete a folder/file with debug output
delete_with_status() {
    local target_path=$1
    local description=$2  # Optional: e.g., "build folder", "folder", etc.
    
    if [ "$DEBUG_MODE" = true ]; then
        if [ -n "$description" ]; then
            echo "[DEBUG]   Deleting $description: $target_path" >&2
        else
            echo "[DEBUG]   Deleting: $target_path" >&2
        fi
    fi
    
    if [ "$DEBUG_MODE" = true ]; then
        if sudo rm -rf "$target_path" 2>/dev/null; then
            echo "[DEBUG]   ✅ Successfully deleted" >&2
            return 0
        else
            echo "[DEBUG]   ❌ Failed to delete" >&2
            return 1
        fi
    else
        sudo rm -rf "$target_path"
        return $?
    fi
}

# Guide
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "                        macOS Cache Manager"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
printf "This tool scans and helps you clean cache folders on your Mac.\n\n"
printf "📁 Cache Categories:\n"
printf -- "  ${GREEN}●${NC} USER    → Application caches (browsers, npm, pip, yarn, etc.)\n"
printf -- "  ${BLUE}●${NC} DEV     → Development tools (Xcode, Gradle, Docker, VS Code, etc.)\n"
printf -- "  ${RED}●${NC} SYSTEM  → macOS system caches (requires admin privileges)\n"
printf -- "  ${YELLOW}●${NC} TEMP    → Temporary files and logs\n"
printf -- "  ${MAGENTA}●${NC} ANDROID → Android Studio build folders\n"
echo ""
if [ "$FAST_MODE" = true ]; then
    printf "⚡ Fast Mode: Quick size estimation (use ${GREEN}--accurate${NC} flag for precise sizes)\n"
else
    printf "🎯 Accurate Mode: Precise size calculation (slower but exact)\n"
fi

if [ ${#IGNORE_TYPES[@]} -gt 0 ]; then
    printf "🚫 Ignoring cache types: ${IGNORE_TYPES[*]}\n"
fi

if [ "$SKIP_CALCULATION" = true ]; then
    printf "⏭️  Skipping size calculation\n"
fi

if [ "$DEBUG_MODE" = true ]; then
    printf "🐛 Debug mode enabled\n"
fi
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔍 Scanning for cache folders..."

# Define all possible cache folders with type
# Note: The following are intentionally excluded as they contain settings/data, not just caches:
# - ~/Library/Containers (app data)
# - ~/Library/Group Containers (shared app data)
# - ~/Library/Application Support/JetBrains (IDE settings)
# - ~/Library/Application Support/Zed (editor settings)
# - ~/Library/Developer/Xcode/UserData (Xcode settings)
# - ~/.vscode/extensions, ~/.cursor/extensions (installed extensions)
# - ~/.gem (installed Ruby gems)
# - ~/.nvm (Node.js version manager)
# - ~/.pyenv (Python version manager)
# - ~/.conda, ~/anaconda3, ~/miniconda3 (Python environments)
# - ~/.swiftpm (Swift packages)
# - ~/.cocoapods/repos (CocoaPods specs)
# - ~/.yarn/global (global packages)
# - ~/.stack (Haskell Stack)
# - ~/.pub-cache (Dart/Flutter packages)
# - ~/.m2 (Maven dependencies)
# - ~/.config/uv, ~/.local/share/uv (UV package manager)
# - /System/Library/Caches (critical system caches)
# - /private/var/folders (system temp files)
# - /Users/Shared (shared user data)
CACHE_FOLDERS=(
    "$HOME/Library/Caches|USER"
    "$HOME/Library/Caches/Firefox|USER"
    "$HOME/Library/Caches/Google/Chrome|USER"
    "$HOME/Library/Caches/com.apple.Safari|USER"
    "$HOME/Library/Caches/Homebrew|USER"
    "$HOME/Library/Saved Application State|USER"
    "$HOME/Library/Application Support/CrashReporter|USER"
    "$HOME/.cache|USER"
    "$HOME/.npm|USER"
    "$HOME/.cache/yarn|USER"
    "$HOME/.cache/pip|USER"
    "$HOME/.composer/cache|USER"
    "$HOME/.node-gyp|USER"
    "$HOME/.thumbnails|USER"

    # Xcode
    "$HOME/Library/Developer/Xcode/DerivedData|DEV"
    "$HOME/Library/Developer/Xcode/Archives|DEV"
    "$HOME/Library/Developer/Xcode/DocumentationCache|DEV"
    "$HOME/Library/Developer/CoreSimulator/Devices|DEV"
    "$HOME/Library/Developer/DeveloperDiskImages|DEV"
    "$HOME/Library/Developer/Xcode/iOS DeviceSupport|DEV"
    "$HOME/Library/Developer/Xcode/tvOS DeviceSupport|DEV"
    "$HOME/Library/Developer/Xcode/watchOS DeviceSupport|DEV"
    "$HOME/Library/Developer/Xcode/macOS DeviceSupport|DEV"
    "$HOME/Library/Caches/com.apple.dt.xcodebuild|DEV"
    "$HOME/Library/Caches/com.apple.dt.Xcode.sourcecontrol.Git|DEV"

    # VS Code
    "$HOME/Library/Application Support/Code/Cache|DEV"
    "$HOME/Library/Application Support/Code/CachedData|DEV"
    "$HOME/Library/Application Support/Code/CachedExtensions|DEV"
    "$HOME/Library/Application Support/Code/CachedExtensionVSIXs|DEV"
    "$HOME/Library/Application Support/Code/CachedConfigurations|DEV"
    "$HOME/Library/Application Support/Code/CachedProfilesData|DEV"
    "$HOME/Library/Application Support/Code/GPUCache|DEV"
    "$HOME/Library/Application Support/Code/Code Cache|DEV"
    "$HOME/.vscode/cli|DEV"

    # Cursor
    "$HOME/Library/Application Support/Cursor/Cache|DEV"
    "$HOME/Library/Application Support/Cursor/CachedData|DEV"
    "$HOME/Library/Application Support/Cursor/CachedExtensions|DEV"
    "$HOME/Library/Application Support/Cursor/CachedExtensionVSIXs|DEV"
    "$HOME/Library/Application Support/Cursor/CachedConfigurations|DEV"
    "$HOME/Library/Application Support/Cursor/CachedProfilesData|DEV"
    "$HOME/Library/Application Support/Cursor/GPUCache|DEV"
    "$HOME/Library/Application Support/Cursor/Code Cache|DEV"

    # Zed
    "$HOME/Library/Caches/Zed|DEV"
    "$HOME/Library/Application Support/Zed/node/cache|DEV"

    # JetBrains IDEs (IntelliJ IDEA, Android Studio, etc.)
    "$HOME/Library/Caches/JetBrains|DEV"
    "$HOME/Library/Logs/JetBrains|DEV"

    # Android Studio
    "$HOME/.android/build-cache|DEV"
    "$HOME/Library/Android/sdk/.temp|DEV"
    "$HOME/Library/Logs/AndroidStudio|DEV"

    # Gradle
    "$HOME/.gradle/caches|DEV"
    "$HOME/.gradle/wrapper|DEV"

    # CocoaPods
    "$HOME/Library/Caches/CocoaPods|DEV"

    # Carthage
    "$HOME/Library/Caches/org.carthage.CarthageKit|DEV"

    # Rust/Cargo
    "$HOME/.cargo/registry|DEV"
    "$HOME/.cargo/git|DEV"

    # Go
    "$HOME/go/pkg/mod|DEV"

    # Python
    "$HOME/Library/Caches/pypoetry|DEV"
    "$HOME/.cache/uv|DEV"

    # Node.js/JavaScript
    "$HOME/Library/pnpm/store|DEV"
    "$HOME/.cache/yarn|DEV"
    "$HOME/.yarn-cache|DEV"

    # Composer (PHP)
    "$HOME/.composer/cache|DEV"

    # Deno
    "$HOME/Library/Caches/deno|DEV"

    # Nix
    "$HOME/.cache/nix|DEV"

    # Docker
    "$HOME/Library/Containers/com.docker.docker/Data/vms|DEV"

    "/Library/Caches|SYSTEM"
    "/private/var/log|SYSTEM"

    "/tmp|TEMP"
    "/private/var/tmp|TEMP"
    "/Library/Updates|TEMP"
    "$HOME/Library/Logs|TEMP"
    "$HOME/Downloads/*.dmg|TEMP"
)

# ---------------- Android Studio build folders ----------------
# Just add the directories if they exist, we'll check for build folders during size calculation
ANDROID_PROJECT_DIRS=(
    "$HOME/AndroidStudioProjects"
    "$HOME/StudioProjects"
)

for ANDROID_PROJECTS in "${ANDROID_PROJECT_DIRS[@]}"; do
    if [ -d "$ANDROID_PROJECTS" ]; then
        # Add entry, will check for build folders and calculate size later
        CACHE_FOLDERS+=("$ANDROID_PROJECTS|ANDROID")
    fi
done

# Collect existing folders
EXISTING_FOLDERS=()
EXISTING_TYPES=()
for item in "${CACHE_FOLDERS[@]}"; do
    folder="${item%%|*}"
    type="${item##*|}"
    folder="${folder/#\~/$HOME}"
    
    # Skip if this type is in the ignore list
    skip=false
    for ignore_type in "${IGNORE_TYPES[@]}"; do
        if [ "$type" = "$ignore_type" ]; then
            skip=true
            break
        fi
    done
    
    if [ "$skip" = false ] && [ -d "$folder" ]; then
        EXISTING_FOLDERS+=("$folder")
        EXISTING_TYPES+=("$type")
    fi
done

if [ ${#EXISTING_FOLDERS[@]} -eq 0 ]; then
    echo ""
    echo "No existing cache folders found."
    exit 0
fi

# Clear temp file
> /tmp/cache_list.txt

if [ "$SKIP_CALCULATION" = false ]; then
    echo ""
    echo "🔢 Calculating sizes of existing cache folders..."
    echo "----------------------------"
    # Print header
    printf "%-3s %-80s %-10s %-10s\n" "No." "Folder" "Type" "Size"
    echo "--------------------------------------------------------------------------------"

    # Start timer
    START_TIME=$(date +%s)
else
    echo ""
    echo "⏭️  Skipping size calculation - listing folders only..."
    echo "----------------------------"
    # Print header
    printf "%-3s %-80s %-10s\n" "No." "Folder" "Type"
    echo "--------------------------------------------------------------------------------"
fi

FOLDERS_WITH_SIZE=()
FOLDERS_SIZE_HR=()
TOTAL_BYTES=0
USER_BYTES=0
DEV_BYTES=0
SYSTEM_BYTES=0
TEMP_BYTES=0
ANDROID_BYTES=0
index=1

for i in "${!EXISTING_FOLDERS[@]}"; do
    folder="${EXISTING_FOLDERS[$i]}"
    type="${EXISTING_TYPES[$i]}"
    
    # Set color based on type
    case "$type" in
        USER) color="$GREEN" ;;
        DEV) color="$BLUE" ;;
        SYSTEM) color="$RED" ;;
        TEMP) color="$YELLOW" ;;
        ANDROID) color="$MAGENTA" ;;
        *) color="$NC" ;;
    esac
    
    if [ "$SKIP_CALCULATION" = true ]; then
        # Skip size calculation, just list folders
        printf "%-3s %-80s ${color}%-10s${NC}\n" "$index" "$folder" "$type"
        size_hr="N/A"
        size_bytes=0
    else
        # Normal size calculation
        # Print row with loading indicator on the same line (no newline)
        printf "%-3s %-80s ${color}%-10s${NC} %-10s\r" "$index" "$folder" "$type" "⏳⏳"

        if [ "$type" = "ANDROID" ]; then
            # Calculate total size of all build folders inside this Android project directory
            TOTAL_ANDROID_BYTES=0
            if [ "$DEBUG_MODE" = true ]; then
                echo "[DEBUG] Scanning Android project: $folder" >&2
            fi
            for build_dir in $(find "$folder" -type d -name build 2>/dev/null); do
                if [ "$DEBUG_MODE" = true ]; then
                    echo "[DEBUG]   Found build folder: $build_dir" >&2
                fi
                size_bytes=$(du -sk "$build_dir" 2>/dev/null | awk '{print $1*1024}')
                if [ "$DEBUG_MODE" = true ]; then
                    echo "[DEBUG]   Build folder size: $size_bytes bytes ($(bytes_to_human $size_bytes))" >&2
                fi
                TOTAL_ANDROID_BYTES=$((TOTAL_ANDROID_BYTES + size_bytes))
            done
            size_bytes=$TOTAL_ANDROID_BYTES
            if [ "$DEBUG_MODE" = true ]; then
                echo "[DEBUG] Total Android size: $TOTAL_ANDROID_BYTES bytes ($(bytes_to_human $TOTAL_ANDROID_BYTES))" >&2
            fi

            # Human-readable
            size_hr=$(bytes_to_human $TOTAL_ANDROID_BYTES)
        else
            # Normal folder
            if [ "$FAST_MODE" = true ]; then
                # Fast mode - single du call
                size_kb=$(du -sk "$folder" 2>/dev/null | awk '{print $1}')
                
                if [ -n "$size_kb" ]; then
                    size_bytes=$((size_kb * 1024))
                    
                    # Convert to human-readable
                    size_hr=$(bytes_to_human $size_bytes)
                else
                    size_hr="N/A"
                    size_bytes=0
                fi
            else
                # Accurate mode - use du -sh for system's formatting
                size_hr=$(du -sh "$folder" 2>/dev/null | awk '{print $1}')
                size_bytes=$(du -sk "$folder" 2>/dev/null | awk '{print $1*1024}')
                
                if [ -z "$size_hr" ] || [ -z "$size_bytes" ]; then
                    size_hr="N/A"
                    size_bytes=0
                fi
            fi
        fi
    fi

    TOTAL_BYTES=$((TOTAL_BYTES + size_bytes))
    
    # Accumulate sizes by type
    case "$type" in
        USER) USER_BYTES=$((USER_BYTES + size_bytes)) ;;
        DEV) DEV_BYTES=$((DEV_BYTES + size_bytes)) ;;
        SYSTEM) SYSTEM_BYTES=$((SYSTEM_BYTES + size_bytes)) ;;
        TEMP) TEMP_BYTES=$((TEMP_BYTES + size_bytes)) ;;
        ANDROID) ANDROID_BYTES=$((ANDROID_BYTES + size_bytes)) ;;
    esac

    FOLDERS_WITH_SIZE+=("$folder")
    FOLDERS_SIZE_HR+=("$size_hr")
    
    if [ "$SKIP_CALCULATION" = false ]; then
        # Clear entire line and print the final result with proper spacing
        if [ "$DEBUG_MODE" = true ] && [ -n "$size_bytes" ] && [ $size_bytes -gt 0 ]; then
            printf "\r%-3s %-80s ${color}%-10s${NC} %-10s (%s bytes)\n" "$index" "$folder" "$type" "$size_hr" "$size_bytes"
        else
            printf "\r%-3s %-80s ${color}%-10s${NC} %-10s\n" "$index" "$folder" "$type" "$size_hr"
        fi
    fi
    
    # Save to temp file for deletion menu
    echo "$folder|$type" >> /tmp/cache_list.txt
    
    index=$((index + 1))
done

echo "----------------------------"

if [ "$SKIP_CALCULATION" = false ]; then
    # Convert total bytes to human-readable
    TOTAL_HR=$(bytes_to_human $TOTAL_BYTES)
    echo "💾 Total cache size: $TOTAL_HR"

    # Calculate and display duration
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    if [ $DURATION -ge 60 ]; then
        MINUTES=$((DURATION / 60))
        SECONDS=$((DURATION % 60))
        echo "⏱️  Calculation time: ${MINUTES}m ${SECONDS}s"
    else
        echo "⏱️  Calculation time: ${DURATION}s"
    fi
    echo "----------------------------"
else
    echo "📋 Total folders found: ${#EXISTING_FOLDERS[@]}"
    echo "----------------------------"
fi
echo ""

# Convert type totals to human-readable (only if calculation was done)
if [ "$SKIP_CALCULATION" = false ]; then
    USER_HR=$(bytes_to_human $USER_BYTES)
    DEV_HR=$(bytes_to_human $DEV_BYTES)
    SYSTEM_HR=$(bytes_to_human $SYSTEM_BYTES)
    TEMP_HR=$(bytes_to_human $TEMP_BYTES)
    ANDROID_HR=$(bytes_to_human $ANDROID_BYTES)
    TOTAL_HR=$(bytes_to_human $TOTAL_BYTES)
else
    USER_HR="?"
    DEV_HR="?"
    SYSTEM_HR="?"
    TEMP_HR="?"
    ANDROID_HR="?"
    TOTAL_HR="?"
fi

# Helper function to check if a type is ignored
is_type_ignored() {
    local check_type=$1
    for ignored in "${IGNORE_TYPES[@]}"; do
        if [ "$check_type" = "$ignored" ]; then
            return 0  # true, type is ignored
        fi
    done
    return 1  # false, type is not ignored
}

# ─────────────── MENU ───────────────
echo "A) Delete ALL ($TOTAL_HR)"
if [ ${#EXISTING_FOLDERS[@]} -gt 0 ]; then
    echo "1-${#EXISTING_FOLDERS[@]}) Delete specific folder by number"
fi

# Only show menu options for non-ignored types
if ! is_type_ignored "USER"; then
    printf -- "\033[0;32mU) Delete USER caches ($USER_HR)\033[0m\n"
fi
if ! is_type_ignored "DEV"; then
    printf -- "\033[0;34mD) Delete DEV caches ($DEV_HR)\033[0m\n"
fi
if ! is_type_ignored "SYSTEM"; then
    printf -- "\033[0;31mS) Delete SYSTEM caches ($SYSTEM_HR)\033[0m\n"
fi
if ! is_type_ignored "TEMP"; then
    printf -- "\033[0;33mT) Delete TEMP caches ($TEMP_HR)\033[0m\n"
fi
if ! is_type_ignored "ANDROID"; then
    printf -- "\033[0;35mN) Delete ANDROID caches ($ANDROID_HR)\033[0m\n"
fi

echo "Q) Quit"
echo ""

# Build dynamic prompt based on available options
PROMPT_OPTIONS="A"
if [ ${#EXISTING_FOLDERS[@]} -gt 0 ]; then
    PROMPT_OPTIONS="$PROMPT_OPTIONS/1-${#EXISTING_FOLDERS[@]}"
fi
if ! is_type_ignored "USER"; then
    PROMPT_OPTIONS="$PROMPT_OPTIONS/U"
fi
if ! is_type_ignored "DEV"; then
    PROMPT_OPTIONS="$PROMPT_OPTIONS/D"
fi
if ! is_type_ignored "SYSTEM"; then
    PROMPT_OPTIONS="$PROMPT_OPTIONS/S"
fi
if ! is_type_ignored "TEMP"; then
    PROMPT_OPTIONS="$PROMPT_OPTIONS/T"
fi
if ! is_type_ignored "ANDROID"; then
    PROMPT_OPTIONS="$PROMPT_OPTIONS/N"
fi
PROMPT_OPTIONS="$PROMPT_OPTIONS/Q"

# ─────────────── CLEANUP CHOICE LOOP ───────────────
while true; do
    read -p "Choose an option ($PROMPT_OPTIONS): " choice

    # Handle empty input (just pressing Enter)
    if [ -z "$choice" ]; then
        echo "👋 Exiting without deleting anything."
        rm -f /tmp/cache_list.txt
        exit 0
    fi

    case "$choice" in
        [qQ])
            echo "👋 Exiting without deleting anything."
            rm -f /tmp/cache_list.txt
            exit 0
            ;;
        [aA])
            read -p "⚠️  Delete ALL listed cache folders? (y/N): " confirm_all
            if [ "$confirm_all" = "y" ] || [ "$confirm_all" = "Y" ]; then
                while IFS='|' read -r folder type; do
                    if [ "$DEBUG_MODE" = true ]; then
                        echo "[DEBUG] Deleting folder: $folder (type: $type)" >&2
                    fi
                    echo "Deleting $folder..."
                    delete_with_status "$folder"
                done < /tmp/cache_list.txt
                echo "✅ All cache folders deleted."
                echo ""
            else
                echo "❌ Cancelled."
                echo ""
            fi
            ;;
        [uU]|[dD]|[sS]|[tT]|[nN])
            case "$choice" in
                [uU]) target="USER"; color="$GREEN" ;;
                [dD]) target="DEV"; color="$BLUE" ;;
                [sS]) target="SYSTEM"; color="$RED" ;;
                [tT]) target="TEMP"; color="$YELLOW" ;;
                [nN]) target="ANDROID"; color="$MAGENTA" ;;
            esac
            
            # Check if this type is ignored
            if is_type_ignored "$target"; then
                echo "❌ Cannot delete $target caches - this type is being ignored."
                echo ""
                continue
            fi
            
            read -p "⚠️  Delete all $target caches? (y/N): " confirm_type
            if [ "$confirm_type" = "y" ] || [ "$confirm_type" = "Y" ]; then
                while IFS='|' read -r folder type; do
                    if [ "$type" = "$target" ]; then
                        case "$type" in
                            USER) color_code="\033[0;32m" ;;
                            DEV) color_code="\033[0;34m" ;;
                            SYSTEM) color_code="\033[0;31m" ;;
                            TEMP) color_code="\033[0;33m" ;;
                            ANDROID) color_code="\033[0;35m" ;;
                            *) color_code="" ;;
                        esac
                        if [ "$DEBUG_MODE" = true ]; then
                            echo "[DEBUG] Deleting $target cache: $folder" >&2
                        fi
                        printf -- "Deleting ${color_code}%s\033[0m...\n" "$folder"
                        if [ "$target" = "ANDROID" ]; then
                            # Delete all build folders in Android projects
                            for build_dir in $(find "$folder" -type d -name build 2>/dev/null); do
                                delete_with_status "$build_dir" "build folder"
                            done
                        else
                            delete_with_status "$folder"
                        fi
                    fi
                done < /tmp/cache_list.txt
                echo "✅ All $target caches deleted."
                echo ""
            else
                echo "❌ Cancelled."
                echo ""
            fi
            ;;
        [0-9]*)
            # Handle numeric input for deleting specific folder
            if [ "$choice" -ge 1 ] && [ "$choice" -le "${#EXISTING_FOLDERS[@]}" ] 2>/dev/null; then
                idx=$((choice - 1))
                folder="${EXISTING_FOLDERS[$idx]}"
                type="${EXISTING_TYPES[$idx]}"
                
                case "$type" in
                    USER) color_code="\033[0;32m" ;;
                    DEV) color_code="\033[0;34m" ;;
                    SYSTEM) color_code="\033[0;31m" ;;
                    TEMP) color_code="\033[0;33m" ;;
                    ANDROID) color_code="\033[0;35m" ;;
                    *) color_code="" ;;
                esac
                
                printf -- "⚠️  Delete ${color_code}%s\033[0m? (y/N): " "$folder"
                read confirm_single
                if [ "$confirm_single" = "y" ] || [ "$confirm_single" = "Y" ]; then
                    if [ "$DEBUG_MODE" = true ]; then
                        echo "[DEBUG] Deleting specific folder: $folder (type: $type)" >&2
                    fi
                    if [ "$type" = "ANDROID" ]; then
                        # Delete all build folders in Android projects
                        printf -- "Deleting ${color_code}%s\033[0m (build folders)...\n" "$folder"
                        for build_dir in $(find "$folder" -type d -name build 2>/dev/null); do
                            delete_with_status "$build_dir" "build folder"
                        done
                    else
                        printf -- "Deleting ${color_code}%s\033[0m...\n" "$folder"
                        delete_with_status "$folder"
                    fi
                    echo "✅ Deleted successfully."
                    echo ""
                else
                    echo "❌ Cancelled."
                    echo ""
                fi
            else
                echo "❌ Invalid folder number. Please choose between 1 and ${#EXISTING_FOLDERS[@]}."
                echo ""
            fi
            ;;
        *)
            echo "❌ Invalid option."
            echo ""
            ;;
    esac
done
