# Implementing Frontmost App Detection in Tauri 2.x with objc2/icrate

## Context
You're working on a Tauri 2.x application that needs to determine which application is currently frontmost (active/focused) on each screen in a multi-monitor macOS setup. This implementation uses Rust with the objc2 and icrate crates for Objective-C interop.

## Requirements
- Detect the frontmost application on macOS
- Identify which screen the frontmost app's window is on
- Use objc2/icrate for Objective-C bridging (NOT the deprecated objc crate)
- Compatible with Tauri 2.x architecture

## Dependencies to Add to Cargo.toml
```toml
[dependencies]
objc2 = "0.5"
objc2-foundation = { version = "0.2", features = ["NSString", "NSArray", "NSDictionary", "NSNumber", "NSThread"] }
objc2-app-kit = { version = "0.2", features = ["NSWorkspace", "NSApplication", "NSScreen", "NSWindow", "NSRunningApplication"] }
icrate = { version = "0.1", features = ["Foundation", "Foundation_NSString", "Foundation_NSArray", "AppKit", "AppKit_NSWorkspace", "AppKit_NSRunningApplication", "AppKit_NSScreen"] }
block2 = "0.5"
```

## Implementation Steps

### Step 1: Check Frontmost Application
First, implement a function to get the frontmost application using NSWorkspace:

```rust
use icrate::Foundation::{NSString, NSArray};
use icrate::AppKit::{NSWorkspace, NSRunningApplication, NSApplicationActivationPolicy};
use objc2::rc::Id;
use objc2::runtime::ProtocolObject;

fn get_frontmost_app() -> Option<Id<NSRunningApplication>> {
    unsafe {
        let workspace = NSWorkspace::sharedWorkspace();
        let frontmost_app = workspace.frontmostApplication();
        frontmost_app
    }
}
```

### Step 2: Get App Information
Extract relevant information from the NSRunningApplication:

```rust
fn get_app_info(app: &NSRunningApplication) -> AppInfo {
    unsafe {
        let bundle_id = app.bundleIdentifier()
            .map(|s| s.to_string())
            .unwrap_or_default();
        
        let localized_name = app.localizedName()
            .map(|s| s.to_string())
            .unwrap_or_default();
        
        let process_id = app.processIdentifier();
        
        AppInfo {
            bundle_id,
            name: localized_name,
            pid: process_id,
        }
    }
}

struct AppInfo {
    bundle_id: String,
    name: String,
    pid: i32,
}
```

### Step 3: Determine Which Screen Contains the App
To find which screen contains the frontmost app's windows, you'll need to:

1. Get the app's windows using Accessibility API or CGWindowListCopyWindowInfo
2. Check which screen contains each window
3. Return the screen information

```rust
use core_graphics::display::{CGWindowListCopyWindowInfo, kCGWindowListOptionOnScreenOnly, kCGWindowListExcludeDesktopElements};
use core_foundation::array::CFArray;
use core_foundation::dictionary::CFDictionary;
use core_foundation::string::CFString;
use core_foundation::number::CFNumber;
use icrate::AppKit::NSScreen;

fn get_app_screen(pid: i32) -> Option<ScreenInfo> {
    unsafe {
        // Get all windows for this PID
        let options = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
        let window_list = CGWindowListCopyWindowInfo(options, 0);
        
        if window_list.is_null() {
            return None;
        }
        
        let windows: CFArray<CFDictionary> = CFArray::wrap_under_create_rule(window_list);
        
        // Find windows belonging to this PID
        for window in windows.iter() {
            if let Some(owner_pid) = window.find(CFString::from("kCGWindowOwnerPID")) {
                let owner_pid: CFNumber = owner_pid.downcast().unwrap();
                if owner_pid.to_i32() == Some(pid) {
                    // Get window bounds
                    if let Some(bounds) = window.find(CFString::from("kCGWindowBounds")) {
                        let bounds_dict: CFDictionary = bounds.downcast().unwrap();
                        let window_rect = parse_cg_rect(bounds_dict);
                        
                        // Find which screen contains this window
                        let screens = NSScreen::screens();
                        for screen in screens.iter() {
                            let screen_frame = screen.frame();
                            if rect_intersects(window_rect, screen_frame) {
                                return Some(get_screen_info(screen));
                            }
                        }
                    }
                }
            }
        }
        None
    }
}
```

### Step 4: Complete Implementation with Tauri Command
Create a Tauri command that can be called from the frontend:

```rust
#[tauri::command]
async fn get_frontmost_app_on_screen() -> Result<FrontmostAppInfo, String> {
    let app = get_frontmost_app()
        .ok_or_else(|| "No frontmost application found".to_string())?;
    
    let app_info = get_app_info(&app);
    let screen_info = get_app_screen(app_info.pid);
    
    Ok(FrontmostAppInfo {
        app: app_info,
        screen: screen_info,
    })
}

#[derive(serde::Serialize)]
struct FrontmostAppInfo {
    app: AppInfo,
    screen: Option<ScreenInfo>,
}

#[derive(serde::Serialize)]
struct ScreenInfo {
    id: u32,
    name: String,
    frame: CGRect,
    is_main: bool,
}
```

## Important Notes and Gotchas

### 1. Permissions
- Your app needs Screen Recording permission to use CGWindowListCopyWindowInfo
- Add appropriate entitlements in your Info.plist:
```xml
<key>NSScreenCaptureUsageDescription</key>
<string>This app needs screen recording permission to detect window positions</string>
```

### 2. Thread Safety
- NSWorkspace operations should be performed on the main thread
- Use `dispatch_async` or Tauri's async runtime appropriately:
```rust
use icrate::Foundation::NSThread;

if !NSThread::isMainThread() {
    // Dispatch to main thread
    dispatch::Queue::main().exec_async(|| {
        // Your NSWorkspace code here
    });
}
```

### 3. Memory Management
- objc2/icrate uses automatic reference counting (ARC)
- Use `Id<T>` for owned references and `&T` for borrowed references
- Be careful with `unsafe` blocks and ensure proper memory handling

### 4. Error Handling
- Check for null pointers when working with Core Graphics APIs
- Handle cases where no windows are visible or accessible
- Provide meaningful error messages for permission issues

### 5. Alternative Approach Using AXUIElement
If CGWindowListCopyWindowInfo doesn't provide enough information, you can use the Accessibility API:

```rust
use objc2_app_kit::NSAccessibility;
use core_foundation::base::{CFType, TCFType};

fn get_focused_window_ax() -> Option<AXUIElement> {
    unsafe {
        let system_wide = AXUIElementCreateSystemWide();
        let mut focused_app: CFTypeRef = std::ptr::null();
        
        let result = AXUIElementCopyAttributeValue(
            system_wide,
            kAXFocusedApplicationAttribute as CFStringRef,
            &mut focused_app
        );
        
        if result == kAXErrorSuccess {
            // Get focused window from the app
            let mut focused_window: CFTypeRef = std::ptr::null();
            let result = AXUIElementCopyAttributeValue(
                focused_app as AXUIElementRef,
                kAXFocusedWindowAttribute as CFStringRef,
                &mut focused_window
            );
            
            if result == kAXErrorSuccess {
                return Some(focused_window as AXUIElementRef);
            }
        }
        None
    }
}
```

## Testing Considerations
1. Test with multiple monitors connected
2. Test with apps on different spaces/desktops
3. Test with fullscreen applications
4. Test with minimized windows
5. Test permission denied scenarios
6. Test with apps that have multiple windows

## Performance Tips
- Cache screen information if checking frequently
- Use async/await for non-blocking operations
- Consider throttling checks if polling continuously
- Release Core Foundation objects properly to avoid memory leaks

## Example Usage in Tauri Frontend
```javascript
import { invoke } from '@tauri-apps/api/tauri';

async function checkFrontmostApp() {
  try {
    const result = await invoke('get_frontmost_app_on_screen');
    console.log('Frontmost app:', result.app.name);
    if (result.screen) {
      console.log('On screen:', result.screen.id);
    }
  } catch (error) {
    console.error('Failed to get frontmost app:', error);
  }
}
```

This implementation provides a robust way to detect the frontmost application and determine which screen it's on in a Tauri 2.x application using modern Rust bindings for Objective-C.