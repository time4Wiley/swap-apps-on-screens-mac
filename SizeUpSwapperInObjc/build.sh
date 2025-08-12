#!/bin/bash

# Build script for SizeUpSwapperInObjc

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "${BLUE}Building SizeUpSwapperInObjc...${NC}"

# Clean and build
if xcodebuild -project SizeUpSwapperInObjc.xcodeproj -target SizeUpSwapperInObjc -configuration Release clean build; then
    echo "${GREEN}✓ Build successful!${NC}"
    echo ""
    echo "${BLUE}Executable location:${NC}"
    echo "  build/Release/SizeUpSwapperInObjc"
    echo ""
    echo "${BLUE}To run:${NC}"
    echo "  ./build/Release/SizeUpSwapperInObjc"
else
    echo "${RED}✗ Build failed${NC}"
    exit 1
fi