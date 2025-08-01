#!/bin/zsh

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Installation directory
INSTALL_DIR="$HOME/.local/bin"

echo "${BLUE}=== Swap Apps on Screens - Installation Script ===${NC}\n"

# Create installation directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    echo "${BLUE}Creating installation directory: $INSTALL_DIR${NC}"
    mkdir -p "$INSTALL_DIR"
fi

# Build in release mode for better performance
echo "\n${BLUE}Building project in release mode...${NC}"
swift build -c release

if [ $? -ne 0 ]; then
    echo "${RED}❌ Build failed${NC}"
    exit 1
fi

# Install executables
echo "\n${BLUE}Installing executables...${NC}"

# List of executables to install
EXECUTABLES=(
    "TopWindowDetector"
    "SwapWindows"
    "DiagnoseWindows"
    "SizeUpSwapper"
)

for exe in "${EXECUTABLES[@]}"; do
    SOURCE=".build/release/$exe"
    TARGET="$INSTALL_DIR/$exe"
    
    if [ -f "$SOURCE" ]; then
        cp "$SOURCE" "$TARGET"
        chmod +x "$TARGET"
        echo "${GREEN}✓ Installed $exe${NC}"
    else
        echo "${RED}✗ $exe not found${NC}"
    fi
done

# Create convenience symlink for the main SizeUp swapper
ln -sf "$INSTALL_DIR/SizeUpSwapper" "$INSTALL_DIR/swap-screens"
echo "${GREEN}✓ Created symlink 'swap-screens' for SizeUpSwapper${NC}"

echo "\n${BLUE}Installation complete!${NC}"
echo "\n${GREEN}Installed executables to:${NC}"
echo "  $INSTALL_DIR"

echo "\n${GREEN}For Alfred workflow, use this path:${NC}"
echo "  ${BLUE}$INSTALL_DIR/SizeUpSwapper${NC}"
echo "  or"
echo "  ${BLUE}$INSTALL_DIR/swap-screens${NC}"

# Check if directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "\n${RED}⚠️  Warning: $INSTALL_DIR is not in your PATH${NC}"
    echo "Add this line to your ~/.zshrc:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo "\n${GREEN}Don't forget to grant Accessibility permissions to:${NC}"
echo "  - $INSTALL_DIR/SizeUpSwapper"
echo "  - $INSTALL_DIR/swap-screens (if using the symlink)"
echo "  - SizeUp (if not already granted)"

echo "\n${BLUE}To uninstall, run:${NC}"
echo "  rm $INSTALL_DIR/{TopWindowDetector,SwapWindows,DiagnoseWindows,SizeUpSwapper,swap-screens}"