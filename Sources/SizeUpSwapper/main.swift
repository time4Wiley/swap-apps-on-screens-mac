import Foundation
import WindowCore
import AppKit

@main
struct SizeUpSwapperApp {
    static func main() {
        print("SizeUp Window Swapper")
        print("=====================\n")
        
        print("Checking accessibility permissions...")
        guard AccessibilityHelper.ensurePermissions() else {
            print("❌ Cannot proceed without accessibility permissions.")
            exit(1)
        }
        
        // Check if SizeUp is running
        let runningApps = NSWorkspace.shared.runningApplications
        let sizeUpRunning = runningApps.contains { app in
            app.bundleIdentifier == "com.irradiatedsoftware.SizeUp"
        }
        
        if !sizeUpRunning {
            print("⚠️  SizeUp doesn't appear to be running.")
            print("Please ensure SizeUp is installed and running.")
            print("You can download it from: https://www.irradiatedsoftware.com/sizeup/")
            exit(1)
        }
        
        print("✓ SizeUp is running\n")
        
        // Detect screens and windows
        print("Detecting screens and windows...")
        let screenInfo = WindowDetector.getScreenInfo()
        
        guard screenInfo.count >= 2 else {
            print("❌ This tool requires at least 2 screens.")
            print("Currently detected: \(screenInfo.count) screen(s)")
            exit(1)
        }
        
        let topWindows = WindowDetector.topWindowsPerScreen()
        
        guard topWindows.count >= 2 else {
            print("❌ Need at least one window on each of two screens.")
            print("Currently detected: \(topWindows.count) window(s) across screens")
            exit(1)
        }
        
        // Display current state
        print("\nCurrent window configuration:")
        print("-----------------------------")
        var windowsToSwap: [WindowInfo] = []
        
        for (index, (screen, screenName)) in screenInfo.enumerated() {
            let screenNumber = index + 1
            print("\nScreen \(screenNumber): \(screenName)")
            
            if let window = topWindows[screen] {
                print("  Window: \(window.appName ?? "Unknown") - \(window.windowTitle ?? "No title")")
                print("  Position: (\(Int(window.frame.origin.x)), \(Int(window.frame.origin.y)))")
                windowsToSwap.append(window)
            } else {
                print("  No window detected")
            }
        }
        
        guard windowsToSwap.count >= 2 else {
            print("\n❌ Not enough windows to swap")
            exit(1)
        }
        
        // Save the currently active application
        let activeApp = NSWorkspace.shared.frontmostApplication
        print("\n💾 Current active app: \(activeApp?.localizedName ?? "Unknown")")
        
        // Perform the swap using SizeUp
        print("\n🔄 Swapping windows using SizeUp...")
        
        // We need to activate each window and tell SizeUp to move it to the next monitor
        for (index, window) in windowsToSwap.enumerated() {
            print("\nMoving window \(index + 1): \(window.appName ?? "Unknown")")
            
            // First, we need to activate the window's application
            if let app = NSRunningApplication(processIdentifier: window.ownerPID) {
                app.activate()
                
                // Give the app time to activate
                Thread.sleep(forTimeInterval: 0.2)
                
                // Now use AppleScript to tell SizeUp to move the window
                let script = """
                tell application "SizeUp"
                    do action Next Monitor
                end tell
                """
                
                if let appleScript = NSAppleScript(source: script) {
                    var error: NSDictionary?
                    appleScript.executeAndReturnError(&error)
                    
                    if let error = error {
                        print("  ❌ Failed to move window: \(error)")
                    } else {
                        print("  ✅ Window moved to next monitor")
                    }
                    
                    // Give SizeUp time to complete the move
                    Thread.sleep(forTimeInterval: 0.3)
                } else {
                    print("  ❌ Failed to create AppleScript")
                }
            } else {
                print("  ❌ Could not activate application with PID \(window.ownerPID)")
            }
        }
        
        // Restore the originally active application
        if let activeApp = activeApp {
            print("\n🔄 Restoring active app: \(activeApp.localizedName ?? "Unknown")")
            activeApp.activate()
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        print("\n✨ Done! Windows should now be swapped.")
        print("\nNote: SizeUp moves each window to the 'next' monitor in its list.")
        print("If you have more than 2 monitors, the behavior may differ from a simple swap.")
    }
}