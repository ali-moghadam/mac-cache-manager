#!/bin/bash

# Show help message
show_help() {
    echo "macOS Cache Manager"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -a, --accurate  Use accurate mode for precise size calculation (slower)"
    echo ""
    echo "Description:"
    echo "  This tool scans and helps you clean cache folders on your Mac."
    echo ""
    echo "  Cache Categories:"
    echo "    USER    → Application caches (browsers, npm, pip, yarn, etc.)"
    echo "    DEV     → Development tools (Xcode, Gradle, Docker, VS Code, etc.)"
    echo "    SYSTEM  → macOS system caches (requires admin privileges)"
    echo "    TEMP    → Temporary files and logs"
    echo "    ANDROID → Android Studio build folders"
    echo ""
    echo "Examples:"
    echo "  $0              # Run in fast mode (default)"
    echo "  $0 --accurate   # Run with precise size calculation"
    exit 0
}

# Parse command line arguments
FAST_MODE=true
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
elif [ "$1" = "--accurate" ] || [ "$1" = "-a" ]; then
    FAST_MODE=false
fi

# ANSI color codes
GREEN='\033[0;32m'   # User cache
BLUE='\033[0;34m'    # Developer/App cache
RED='\033[0;31m'     # System cache
YELLOW='\033[0;33m'  # Temp / misc
MAGENTA='\033[0;35m' # Android Studio build
NC='\033[0m'         # No Color

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
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔍 Scanning for cache folders..."

# Define all possible cache folders with type
CACHE_FOLDERS=(
    "$HOME/Library/Caches|USER"
    "$HOME/Library/Containers|USER"
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
    "$HOME/.gem|USER"
    "$HOME/.composer/cache|USER"
    "$HOME/.node-gyp|USER"
    "$HOME/.thumbnails|USER"

    "$HOME/Library/Developer/Xcode/DerivedData|DEV"
    "$HOME/Library/Developer/Xcode/Archives|DEV"
    "$HOME/Library/Developer/CoreSimulator|DEV"
    "$HOME/Library/Developer/Xcode/iOS DeviceSupport|DEV"
    "$HOME/Library/Application Support/Code/Cache|DEV"
    "$HOME/Library/Application Support/Code/CachedData|DEV"
    "$HOME/Library/Application Support/Code/CachedExtensions|DEV"
    "$HOME/.gradle/caches|DEV"
    "$HOME/.m2/repository|DEV"
    "$HOME/Library/Caches/CocoaPods|DEV"
    "~/.cocoapods|DEV"
    "$HOME/.android/build-cache|DEV"
    "$HOME/Library/Android/sdk/.temp|DEV"
    "$HOME/.cargo/registry|DEV"
    "$HOME/.cargo/git|DEV"

    "$HOME/Library/Containers/com.docker.docker/Data/vms|DEV"
    "$HOME/Library/Group Containers|DEV"

    "/Library/Caches|SYSTEM"
    "/System/Library/Caches|SYSTEM"
    "/private/var/folders|SYSTEM"
    "/private/var/log|SYSTEM"

    "/tmp|TEMP"
    "/private/var/tmp|TEMP"
    "/Library/Updates|TEMP"
    "/Users/Shared|TEMP"
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
    if [ -d "$folder" ]; then
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

echo ""
echo "🔢 Calculating sizes of existing cache folders..."
echo "----------------------------"
# Print header
printf "%-3s %-80s %-10s %-10s\n" "No." "Folder" "Type" "Size"
echo "--------------------------------------------------------------------------------"

# Start timer
START_TIME=$(date +%s)

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
    
    # Print row with loading indicator (no newline yet)
    printf "%-3s %-80s ${color}%-10s${NC} %-10s\r" "$index" "$folder" "$type" "⏳⏳"

    if [ "$type" = "ANDROID" ]; then
        # Calculate total size of all build folders inside this Android project directory
        TOTAL_ANDROID_BYTES=0
        for build_dir in $(find "$folder" -type d -name build 2>/dev/null); do
            size_bytes=$(du -sk "$build_dir" 2>/dev/null | awk '{print $1*1024}')
            TOTAL_ANDROID_BYTES=$((TOTAL_ANDROID_BYTES + size_bytes))
        done
        size_bytes=$TOTAL_ANDROID_BYTES

        # Human-readable
        if [ $TOTAL_ANDROID_BYTES -ge 1073741824 ]; then
            size_hr=$(echo "scale=2; $TOTAL_ANDROID_BYTES/1073741824" | bc)
            size_hr="${size_hr}G"
        elif [ $TOTAL_ANDROID_BYTES -ge 1048576 ]; then
            size_hr=$(echo "scale=2; $TOTAL_ANDROID_BYTES/1048576" | bc)
            size_hr="${size_hr}M"
        elif [ $TOTAL_ANDROID_BYTES -ge 1024 ]; then
            size_hr=$(echo "scale=2; $TOTAL_ANDROID_BYTES/1024" | bc)
            size_hr="${size_hr}K"
        else
            size_hr="${TOTAL_ANDROID_BYTES}B"
        fi
    else
        # Normal folder
        if [ "$FAST_MODE" = true ]; then
            # Fast mode - single du call
            size_kb=$(du -sk "$folder" 2>/dev/null | awk '{print $1}')
            
            if [ -n "$size_kb" ]; then
                size_bytes=$((size_kb * 1024))
                
                # Convert to human-readable
                if [ $size_bytes -ge 1073741824 ]; then
                    size_hr=$(echo "scale=1; $size_bytes/1073741824" | bc)
                    size_hr="${size_hr}G"
                elif [ $size_bytes -ge 1048576 ]; then
                    size_hr=$(echo "scale=1; $size_bytes/1048576" | bc)
                    size_hr="${size_hr}M"
                elif [ $size_bytes -ge 1024 ]; then
                    size_hr=$(echo "scale=1; $size_bytes/1024" | bc)
                    size_hr="${size_hr}K"
                else
                    size_hr="${size_bytes}B"
                fi
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
    
    # Update the line (overwrite loading indicator) and add newline
    printf "\r\033[K%-3s %-80s ${color}%-10s${NC} %-10s\n" "$index" "$folder" "$type" "$size_hr"
    
    # Save to temp file for deletion menu
    echo "$folder|$type" >> /tmp/cache_list.txt
    
    index=$((index + 1))
done

# Convert total bytes to human-readable
if [ $TOTAL_BYTES -ge 1073741824 ]; then
    TOTAL_HR=$(echo "scale=2; $TOTAL_BYTES/1073741824" | bc)
    TOTAL_HR="${TOTAL_HR}G"
elif [ $TOTAL_BYTES -ge 1048576 ]; then
    TOTAL_HR=$(echo "scale=2; $TOTAL_BYTES/1048576" | bc)
    TOTAL_HR="${TOTAL_HR}M"
elif [ $TOTAL_BYTES -ge 1024 ]; then
    TOTAL_HR=$(echo "scale=2; $TOTAL_BYTES/1024" | bc)
    TOTAL_HR="${TOTAL_HR}K"
else
    TOTAL_HR="${TOTAL_BYTES}B"
fi

echo "----------------------------"
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
echo ""

# ─────────────── Convert type totals to human-readable ───────────────
convert_size() {
    local bytes=$1
    if [ $bytes -ge 1073741824 ]; then
        echo "$(echo "scale=1; $bytes/1073741824" | bc)G"
    elif [ $bytes -ge 1048576 ]; then
        echo "$(echo "scale=1; $bytes/1048576" | bc)M"
    elif [ $bytes -ge 1024 ]; then
        echo "$(echo "scale=1; $bytes/1024" | bc)K"
    else
        echo "${bytes}B"
    fi
}

USER_HR=$(convert_size $USER_BYTES)
DEV_HR=$(convert_size $DEV_BYTES)
SYSTEM_HR=$(convert_size $SYSTEM_BYTES)
TEMP_HR=$(convert_size $TEMP_BYTES)
ANDROID_HR=$(convert_size $ANDROID_BYTES)

# ─────────────── MENU ───────────────
echo "A) Delete ALL ($TOTAL_HR)"
echo "1-${#EXISTING_FOLDERS[@]}) Delete specific folder by number"
printf -- "\033[0;32mU) Delete USER caches ($USER_HR)\033[0m\n"
printf -- "\033[0;34mD) Delete DEV caches ($DEV_HR)\033[0m\n"
printf -- "\033[0;31mS) Delete SYSTEM caches ($SYSTEM_HR)\033[0m\n"
printf -- "\033[0;33mT) Delete TEMP caches ($TEMP_HR)\033[0m\n"
printf -- "\033[0;35mN) Delete ANDROID caches ($ANDROID_HR)\033[0m\n"
echo "Q) Quit"
echo ""

# ─────────────── CLEANUP CHOICE ───────────────
read -p "Choose an option (A/U/D/S/T/N/1-${#EXISTING_FOLDERS[@]}/Q): " choice

# Handle empty input (just pressing Enter)
if [ -z "$choice" ]; then
    echo "👋 Exiting without deleting anything."
    rm -f /tmp/cache_list.txt
    exit 0
fi

case "$choice" in
    [qQ])
        echo "👋 Exiting without deleting anything."
        ;;
    [aA])
        read -p "⚠️  Delete ALL listed cache folders? (y/N): " confirm_all
        if [ "$confirm_all" = "y" ] || [ "$confirm_all" = "Y" ]; then
            while IFS='|' read -r folder type; do
                echo "Deleting $folder..."
                sudo rm -rf "$folder"
            done < /tmp/cache_list.txt
            echo "✅ All cache folders deleted."
        else
            echo "❌ Cancelled."
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
                    printf -- "Deleting ${color_code}%s\033[0m...\n" "$folder"
                    if [ "$target" = "ANDROID" ]; then
                        # Delete all build folders in Android projects
                        for build_dir in $(find "$folder" -type d -name build 2>/dev/null); do
                            sudo rm -rf "$build_dir"
                        done
                    else
                        sudo rm -rf "$folder"
                    fi
                fi
            done < /tmp/cache_list.txt
            echo "✅ All $target caches deleted."
        else
            echo "❌ Cancelled."
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
                if [ "$type" = "ANDROID" ]; then
                    # Delete all build folders in Android projects
                    printf -- "Deleting ${color_code}%s\033[0m (build folders)...\n" "$folder"
                    for build_dir in $(find "$folder" -type d -name build 2>/dev/null); do
                        sudo rm -rf "$build_dir"
                    done
                else
                    printf -- "Deleting ${color_code}%s\033[0m...\n" "$folder"
                    sudo rm -rf "$folder"
                fi
                echo "✅ Deleted successfully."
            else
                echo "❌ Cancelled."
            fi
        else
            echo "❌ Invalid folder number. Please choose between 1 and ${#EXISTING_FOLDERS[@]}."
        fi
        ;;
    *)
        echo "❌ Invalid option."
        ;;
esac

# Clean up temp file
rm -f /tmp/cache_list.txt
