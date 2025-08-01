#!/bin/zsh

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Installation directory
INSTALL_DIR="$HOME/bin"

echo "${BLUE}=== Swap Apps on Screens - Uninstall Script ===${NC}\n"

# List of executables to uninstall
EXECUTABLES=(
    "TopWindowDetector"
    "SwapWindows"
    "DiagnoseWindows"
    "SizeUpSwapper"
    "swap-screens"
)

# Check if any executables exist
FOUND_ANY=false
for exe in "${EXECUTABLES[@]}"; do
    if [ -f "$INSTALL_DIR/$exe" ]; then
        FOUND_ANY=true
        break
    fi
done

if [ "$FOUND_ANY" = false ]; then
    echo "${YELLOW}No installed executables found in $INSTALL_DIR${NC}"
    exit 0
fi

# Confirm uninstallation
echo "${YELLOW}This will remove the following files from $INSTALL_DIR:${NC}"
for exe in "${EXECUTABLES[@]}"; do
    if [ -f "$INSTALL_DIR/$exe" ]; then
        echo "  - $exe"
    fi
done

echo "\n${YELLOW}Do you want to continue? (y/N)${NC}"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "${RED}Uninstallation cancelled${NC}"
    exit 0
fi

# Remove executables
echo "\n${BLUE}Removing executables...${NC}"
REMOVED_COUNT=0

for exe in "${EXECUTABLES[@]}"; do
    if [ -f "$INSTALL_DIR/$exe" ]; then
        rm "$INSTALL_DIR/$exe"
        echo "${GREEN}✓ Removed $exe${NC}"
        ((REMOVED_COUNT++))
    fi
done

echo "\n${GREEN}Uninstallation complete!${NC}"
echo "Removed $REMOVED_COUNT file(s) from $INSTALL_DIR"

# Check if user needs to remove from Accessibility permissions
echo "\n${BLUE}Note:${NC} You may want to remove these from Accessibility permissions:"
echo "  System Settings → Privacy & Security → Accessibility"
echo "  - $INSTALL_DIR/SizeUpSwapper"
echo "  - $INSTALL_DIR/swap-screens"

# Clean build artifacts if requested
echo "\n${YELLOW}Do you also want to clean build artifacts? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "${BLUE}Cleaning build artifacts...${NC}"
    swift package clean
    rm -rf .build
    echo "${GREEN}✓ Build artifacts cleaned${NC}"
fi