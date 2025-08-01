import Foundation
import WindowCore
import AppKit
import ApplicationServices

@main
struct DiagnoseWindowsApp {
    static func main() {
        print("Window Accessibility Diagnostics")
        print("================================\n")
        
        print("Checking accessibility permissions...")
        guard AccessibilityHelper.ensurePermissions() else {
            print("❌ Cannot proceed without accessibility permissions.")
            exit(1)
        }
        
        print("\nDiagnosing all visible windows...")
        let allWindows = WindowDetector.getAllWindowsInfo()
        
        print("Found \(allWindows.count) windows\n")
        
        for window in allWindows.prefix(10) {
            print("Window: \(window.appName ?? "Unknown") - \(window.windowTitle ?? "No title")")
            print("  ID: \(window.id), PID: \(window.ownerPID)")
            
            // Try to get AX element
            let appElement = AXUIElementCreateApplication(window.ownerPID)
            
            // Check if we can get windows
            var axWindowsRef: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(
                appElement,
                kAXWindowsAttribute as CFString,
                &axWindowsRef
            )
            
            if result != .success {
                print("  ❌ Cannot get AX windows: Error \(result.rawValue)")
                
                // Try to get more info about the app
                var titleRef: CFTypeRef?
                if AXUIElementCopyAttributeValue(
                    appElement,
                    kAXTitleAttribute as CFString,
                    &titleRef
                ) == .success,
                let title = titleRef as? String {
                    print("  App AX Title: \(title)")
                }
                
                // Check if app is trusted
                var trustedRef: CFTypeRef?
                if AXUIElementCopyAttributeValue(
                    appElement,
                    "AXTrusted" as CFString,
                    &trustedRef
                ) == .success {
                    print("  AX Trusted: \(String(describing: trustedRef))")
                }
            } else if CFGetTypeID(axWindowsRef) == CFArrayGetTypeID() {
                let windowCount = CFArrayGetCount((axWindowsRef as! CFArray))
                print("  ✅ Found \(windowCount) AX windows")
                
                // List window IDs
                if let windowList = (axWindowsRef as! CFArray) as? [AXUIElement] {
                    var foundMatch = false
                    for (index, axWindow) in windowList.enumerated() {
                        var windowNumber: AnyObject?
                        if AXUIElementCopyAttributeValue(
                            axWindow,
                            "AXWindowNumber" as CFString,
                            &windowNumber
                        ) == .success,
                        let number = windowNumber as? Int {
                            if number == Int(window.id) {
                                print("  ✅ Window ID \(window.id) found at index \(index)")
                                foundMatch = true
                                
                                // Check if we can get position
                                var posRef: CFTypeRef?
                                if AXUIElementCopyAttributeValue(
                                    axWindow,
                                    kAXPositionAttribute as CFString,
                                    &posRef
                                ) == .success {
                                    print("  ✅ Can read position")
                                    
                                    // Check if position is settable
                                    var settable: DarwinBoolean = false
                                    if AXUIElementIsAttributeSettable(
                                        axWindow,
                                        kAXPositionAttribute as CFString,
                                        &settable
                                    ) == .success {
                                        print("  Position settable: \(settable.boolValue)")
                                    }
                                } else {
                                    print("  ❌ Cannot read position")
                                }
                            }
                        }
                    }
                    if !foundMatch {
                        print("  ⚠️ Window ID \(window.id) not found in AX windows")
                    }
                }
            }
            print()
        }
        
        // Special check for problematic apps
        print("\nChecking known problematic applications:")
        let problematicApps = ["iTerm2", "Terminal", "Microsoft Excel", "Microsoft Word"]
        
        for appName in problematicApps {
            let appWindows = allWindows.filter { $0.appName == appName }
            if !appWindows.isEmpty {
                print("\n\(appName): Found \(appWindows.count) window(s)")
                if appName == "iTerm2" {
                    print("  ℹ️ iTerm2 may require special handling or specific settings")
                    print("  Try: iTerm2 → Preferences → General → Selection → ")
                    print("       'Applications in terminal may access clipboard'")
                }
            }
        }
    }
}