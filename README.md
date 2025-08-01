# Top Window Per Screen Detector

A Swift 6 application that detects the topmost window on each screen of a dual-monitor (or multi-monitor) MacBook setup.

## Features

- Detects all connected screens
- Finds the topmost window on each screen
- Shows detailed window information (app name, window title, position, size, PID)
- Includes accessibility permission checking and prompting
- Provides debug information about all visible windows

## Requirements

- macOS 14.0 or later
- Swift 6.0
- Accessibility permissions

## Building

```bash
# Clone the repository
git clone <repository-url>
cd swap-apps-on-screens-mac

# Build using Swift Package Manager
swift build

# Or build in release mode for better performance
swift build -c release
```

## Running

```bash
# Run the debug build
.build/debug/TopWindowDetector

# Or run the release build
.build/release/TopWindowDetector
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

## Output Example

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

Debug Information:
==================
Total windows detected: 15

First 10 windows (front to back):
  1. Window ID: 37691, App: Code, Title: "WindowDetector.swift", Position: (0, 25), Size: 1728x1092, PID: 85514
  2. Window ID: 31733, App: Safari, Title: "GitHub", Position: (2608, 452), Size: 2080x1256, PID: 6559
  ... and 5 more
```

## Architecture

The project is organized into:

- **WindowCore**: Shared library containing:
  - `WindowInfo.swift`: Data structure for window information
  - `WindowDetector.swift`: Core logic for detecting windows
  - `AccessibilityHelper.swift`: Utilities for checking and requesting permissions
  
- **TopWindowDetector**: Main executable that uses WindowCore to detect and display window information

## Next Steps

This detector serves as the foundation for implementing window swapping functionality. The window detection logic can be extended to:

- Swap window positions between screens
- Save and restore window layouts
- Create keyboard shortcuts for window management

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