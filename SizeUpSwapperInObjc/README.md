# SizeUpSwapper in Objective-C

A complete re-implementation of the SizeUp Window Swapper in Objective-C, demonstrating equivalent functionality to the Swift version.

## Features

- ✅ Detects all connected screens
- ✅ Finds the topmost window on each screen
- ✅ Swaps windows between screens using SizeUp
- ✅ Checks and prompts for accessibility permissions
- ✅ Preserves and restores the active application

## Architecture

The implementation follows the same modular design as the Swift version:

### Classes

- **WindowInfo**: Data model for window information
  - Properties: windowID, ownerPID, frame, appName, windowTitle, layer
  - Custom description method for debugging

- **AccessibilityHelper**: Manages accessibility permissions
  - `checkPermissions`: Verify current permission status
  - `promptForPermissions`: Show system permission dialog
  - `ensurePermissions`: Combined check and prompt

- **WindowDetector**: Detects screens and windows
  - `topWindowsPerScreen`: Returns array of screen-window pairs
  - `getAllWindowsInfo`: Get all visible windows
  - `getScreenInfo`: Get information about connected screens

- **ScreenWindowPair**: Helper class to pair screens with their top windows
- **ScreenInfo**: Helper class for screen information

## Key Differences from Swift Version

1. **Memory Management**: Uses ARC (Automatic Reference Counting)
2. **Dictionary Keys**: NSScreen can't be used as dictionary keys, so we use an array-based approach with ScreenWindowPair objects
3. **String Handling**: UTF8String conversion for C-style printf output
4. **Property Syntax**: Objective-C properties with readonly/readwrite attributes
5. **Block Syntax**: Different from Swift closures
6. **Nullability**: Explicit nullable annotations for clarity

## Building

### Using Xcode
```bash
xcodebuild -project SizeUpSwapperInObjc.xcodeproj -target SizeUpSwapperInObjc -configuration Release build
```

### Using Build Script
```bash
./build.sh
```

## Running
```bash
./build/Release/SizeUpSwapperInObjc
# or for debug build:
./build/Debug/SizeUpSwapperInObjc
```

## Requirements

- macOS 15.0+ (configured in project)
- Xcode 16.0+
- SizeUp installed and running
- Accessibility permissions granted

## Frameworks Used

- Foundation.framework
- AppKit.framework (NSScreen, NSWorkspace, NSAppleScript)
- CoreGraphics.framework (CGWindowListCopyWindowInfo)
- ApplicationServices.framework (AXIsProcessTrusted)

## Implementation Notes

### Window Detection
Uses `CGWindowListCopyWindowInfo` with Core Foundation bridging to detect windows, same as the Swift version.

### Screen Mapping
Instead of using NSScreen as dictionary keys (not possible in Objective-C), we use an array of ScreenWindowPair objects to maintain the screen-to-window relationship.

### AppleScript Integration
Uses NSAppleScript to communicate with SizeUp, identical approach to Swift version.

### Error Handling
Uses traditional Objective-C patterns with nil checks and BOOL return values instead of Swift's optional handling.

## Testing

The application has been tested and successfully:
- Detects multiple screens
- Identifies top windows on each screen
- Swaps windows using SizeUp
- Handles accessibility permissions properly
- Restores the originally active application

## License

MIT License (same as parent project)