# Swap Apps on Screens - Development Guide

## Project Overview

This is a Swift 6 macOS application that detects and swaps windows between multiple monitors. The project uses accessibility APIs and integrates with SizeUp for reliable window management.

## Architecture

### Package Structure
- **WindowCore**: Shared library containing core functionality
  - `WindowInfo.swift`: Data structure for window information
  - `WindowDetector.swift`: Core logic for detecting windows using `CGWindowListCopyWindowInfo`
  - `AccessibilityHelper.swift`: Utilities for checking and requesting accessibility permissions
  - `WindowSwapper.swift`: Logic for swapping window positions using AXUIElement APIs
  
- **TopWindowDetector**: Executable for testing window detection functionality
- **SwapWindows**: Main executable that performs window swapping using native AX API
- **SizeUpSwapper**: Alternative swapper using SizeUp's reliable window management

### Key Technologies
- **Swift 6.0**: Language and concurrency features
- **Swift Package Manager**: Build system and dependency management
- **Accessibility API (AXUIElement)**: For window manipulation
- **Core Graphics API**: For window and screen detection
- **SizeUp Integration**: For reliable window swapping fallback

## Development Guidelines

### Code Style
- Follow Swift naming conventions (camelCase for variables/functions, PascalCase for types)
- Use meaningful variable names that clearly indicate purpose
- Prefer clarity over brevity in naming
- Use Swift's type inference where it improves readability
- Leverage Swift 6 concurrency features where appropriate

### Error Handling
- Use proper error handling with Swift's `Result` type or throwing functions
- Always check accessibility permissions before attempting window operations
- Handle edge cases (no windows, single screen, permission denied)
- Provide clear error messages to help with debugging

### Testing
- Test with multiple screen configurations (single, dual, triple monitors)
- Test with various applications (native macOS apps, Electron apps, web browsers)
- Verify behavior when accessibility permissions are not granted
- Test window swapping with different window states (normal, minimized, full-screen)

## Common Tasks

### Adding New Window Operations
1. Add new methods to `WindowDetector.swift` for detection logic
2. Implement manipulation logic in `WindowSwapper.swift`
3. Create corresponding executable in the executables directory
4. Update `Package.swift` to include the new target

### Debugging Window Detection
- Use `TopWindowDetector` to inspect window hierarchy
- Check Console.app for accessibility API errors
- Verify window bounds intersect with screen frames
- Use `CGWindowListCopyWindowInfo` with different options to debug

### Handling Accessibility Permissions
- Always use `AccessibilityHelper.checkPermissions()` before operations
- Guide users through the permission granting process
- Handle permission denial gracefully with clear instructions

## Build and Run

### Development Build
```bash
swift build
swift run TopWindowDetector
swift run SwapWindows
```

### Release Build
```bash
swift build -c release
```

### Installation
```bash
./install.sh
```

## Integration Points

### Alfred Workflow
- Use `~/bin/SizeUpSwapper` or `~/bin/swap-screens` as the script path
- No arguments needed for basic dual-screen swapping
- Ensure Alfred has accessibility permissions

### SizeUp Integration
- SizeUp must be installed and running
- The app sends AppleScript commands to SizeUp
- Falls back gracefully if SizeUp is not available

## Troubleshooting

### Common Issues
1. **"Permission denied" errors**: Re-grant accessibility permissions
2. **No windows detected**: Check window visibility and screen configuration
3. **Swap fails**: Some apps don't support programmatic repositioning
4. **Build errors**: Ensure Swift 6.0+ and macOS 14.0+ are installed

### Debug Commands
```bash
# Check accessibility permissions status
.build/debug/TopWindowDetector

# List all visible windows
swift run TopWindowDetector | grep "Window ID"

# Test with specific window IDs
# (Future enhancement - not yet implemented)
```

## Security Considerations
- Never bypass accessibility permission checks
- Don't store or log sensitive window content
- Respect user privacy - only access window metadata needed for swapping
- Follow macOS security best practices for accessibility APIs

## Performance Notes
- Window detection is fast (< 100ms typically)
- AXUIElement operations may have slight delays
- SizeUp integration adds ~200-300ms overhead but is more reliable
- Avoid repeated permission checks in tight loops

## Future Enhancements to Consider
- Multi-screen support (> 2 screens) with configurable swap patterns
- Window layout saving and restoration
- Keyboard shortcut customization
- Menu bar application with status indicator
- Window filtering by application or title
- Animation during window swaps
- Undo/redo functionality

## Resources
- [Apple Accessibility API Documentation](https://developer.apple.com/documentation/applicationservices/ax_ui_element)
- [Core Graphics Window Services](https://developer.apple.com/documentation/coregraphics/window_services)
- [Swift Package Manager Documentation](https://swift.org/package-manager/)
- [SizeUp](https://www.irradiatedsoftware.com/sizeup/)