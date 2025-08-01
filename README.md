# Swap Apps on Screens - Mac

A Swift 6 application that detects and swaps the topmost windows between screens on a dual-monitor (or multi-monitor) Mac setup.

## Features

- Detects all connected screens
- Finds the topmost window on each screen
- Swaps window positions between screens (using native AX API or SizeUp)
- Shows detailed window information (app name, window title, position, size, PID)
- Includes accessibility permission checking and prompting
- Provides debug information about all visible windows
- **SizeUp Integration**: Reliable window swapping using SizeUp's proven functionality

## Requirements

- macOS 14.0 or later
- Swift 6.0
- Accessibility permissions
- SizeUp (for the SizeUpSwapper executable) - [Download here](https://www.irradiatedsoftware.com/sizeup/)

## Installation

### Via Homebrew (Recommended)

```bash
brew tap time4Wiley/tap
brew install swap-apps-on-screens
```

### Manual Installation

Download the latest release from the [releases page](https://github.com/time4Wiley/swap-apps-on-screens-mac/releases) or build from source.

## Building

```bash
# Clone the repository
git clone https://github.com/time4Wiley/swap-apps-on-screens-mac.git
cd swap-apps-on-screens-mac

# Build using Swift Package Manager
swift build

# Or build in release mode for better performance
swift build -c release
```

## Local Installation

For system-wide access and Alfred integration:

```bash
# Run the installation script
./install.sh
```

This will:
- Build all executables in release mode
- Install them to `~/bin`
- Create a convenient `swap-screens` symlink
- Display the path for Alfred workflow integration

**Target path for Alfred workflow:**
```
~/bin/SizeUpSwapper
```
or
```
~/bin/swap-screens
```

## Running

### Window Detector (Testing Detection)
```bash
# Run the debug build
.build/debug/TopWindowDetector

# Or use Swift run
swift run TopWindowDetector
```

### Window Swapper (Swap Windows Between Screens)
```bash
# Run the debug build
.build/debug/SwapWindows

# Or use Swift run
swift run SwapWindows
```

## Granting Accessibility Permissions

On first run, the application will check for accessibility permissions. If not granted, it will:

1. Display instructions on how to grant permissions
2. Open the system dialog to grant permissions
3. Exit with instructions to re-run after granting permissions

To manually grant permissions:
1. Open System Settings
2. Go to Privacy & Security → Accessibility
3. Click the lock icon to make changes
4. Add TopWindowDetector to the list (or enable if already present)

## Output Examples

### TopWindowDetector Output
```
Top Window Per Screen Detector
==============================

Checking accessibility permissions...
✓ Accessibility permissions granted

Detecting screens...
Found 2 screen(s):

Screen 1: Built-in Retina Display
  Resolution: 1728x1117
  Position: (0, 0)
  Top Window:
    Window ID: 37691, App: Code, Title: "WindowDetector.swift", Position: (0, 25), Size: 1728x1092, PID: 85514

Screen 2: LG HDR 4K
  Resolution: 3840x2160
  Position: (1728, 0)
  Top Window:
    Window ID: 31733, App: Safari, Title: "GitHub", Position: (2608, 452), Size: 2080x1256, PID: 6559
```

### SwapWindows Output
```
Window Swapper for Dual Screens
================================

Checking accessibility permissions...
✓ Accessibility permissions granted

Detecting screens and windows...

Current window configuration:
-----------------------------

Screen 1: Built-in Retina Display
  Current top window: Code - WindowDetector.swift
  Position: (0, 25)

Screen 2: LG HDR 4K
  Current top window: Safari - GitHub
  Position: (2608, 452)

🔄 Swapping windows...
✅ Successfully swapped windows

New window configuration:
-------------------------

Screen 1: Built-in Retina Display
  New top window: Safari - GitHub
  Position: (0, 25)

Screen 2: LG HDR 4K
  New top window: Code - WindowDetector.swift
  Position: (2608, 452)

✨ Done!
```

## Architecture

The project is organized into:

- **WindowCore**: Shared library containing:
  - `WindowInfo.swift`: Data structure for window information
  - `WindowDetector.swift`: Core logic for detecting windows
  - `AccessibilityHelper.swift`: Utilities for checking and requesting permissions
  - `WindowSwapper.swift`: Logic for swapping window positions using AXUIElement
  
- **TopWindowDetector**: Executable for testing window detection
- **SwapWindows**: Main executable that swaps the topmost windows between screens

## How It Works

1. **Detection Phase**: Uses `CGWindowListCopyWindowInfo` to get all on-screen windows, already sorted front-to-back
2. **Screen Mapping**: Intersects window bounds with screen frames to determine which screen each window belongs to
3. **AX Element Creation**: Creates accessibility elements for the topmost windows using `AXUIElementCreateApplication`
4. **Position Reading**: Gets current window positions via `AXUIElementCopyAttributeValue` with `kAXPositionAttribute`
5. **Position Swapping**: Sets new positions using `AXUIElementSetAttributeValue`

## Limitations

- Some applications may not allow their windows to be repositioned programmatically (e.g., full-screen apps, certain system windows)
- Requires accessibility permissions to function
- Only swaps the topmost window on each screen (not all windows)

## Troubleshooting

### No windows detected
- Make sure you have at least one visible window open
- Check that the windows are not minimized or hidden
- Ensure the application has accessibility permissions

### Permission denied errors
- Re-grant accessibility permissions in System Settings
- Make sure to run the built executable, not the source file
- Try removing and re-adding the application in accessibility settings

### Build errors
- Ensure you have Swift 6.0 or later installed
- Check that you're on macOS 14.0 or later
- Try cleaning the build directory: `swift package clean`

### Window swap fails
- Some applications don't allow window repositioning (e.g., Microsoft Office, system dialogs)
- Try with different applications like Safari, Terminal, or Finder
- Ensure windows are not in full-screen mode
- Check that both screens have at least one visible window

## Future Enhancements

- Add keyboard shortcut support
- Create a menu bar application
- Support for swapping specific windows by ID
- Save and restore window layouts
- Support for more than 2 screens with customizable swap patterns

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Wei

## Acknowledgments

- [SizeUp](https://www.irradiatedsoftware.com/sizeup/) for providing reliable window management functionality
- The Swift community for excellent documentation and examples