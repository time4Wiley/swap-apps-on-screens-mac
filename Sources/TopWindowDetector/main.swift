import Foundation
import WindowCore
import AppKit

@main
struct TopWindowDetectorApp {
    static func main() {
        print("Top Window Per Screen Detector")
        print("==============================\n")
        
        print("Checking accessibility permissions...")
        
        guard AccessibilityHelper.ensurePermissions() else {
            print("❌ Cannot proceed without accessibility permissions.")
            print("Please grant permissions and run again.")
            exit(1)
        }
        
        print("Detecting screens...")
        let screenInfo = WindowDetector.getScreenInfo()
        
        guard !screenInfo.isEmpty else {
            print("❌ No screens detected!")
            exit(1)
        }
        
        print("Found \(screenInfo.count) screen(s):\n")
        
        let topWindows = WindowDetector.topWindowsPerScreen()
        
        for (index, (screen, screenName)) in screenInfo.enumerated() {
            let screenNumber = index + 1
            let resolution = screen.frame
            
            print("Screen \(screenNumber): \(screenName)")
            print("  Resolution: \(Int(resolution.width))x\(Int(resolution.height))")
            print("  Position: (\(Int(resolution.origin.x)), \(Int(resolution.origin.y)))")
            
            if let windowInfo = topWindows[screen] {
                print("  Top Window:")
                print("    \(windowInfo.description)")
            } else {
                print("  Top Window: None detected")
            }
            print()
        }
        
        if topWindows.isEmpty {
            print("⚠️  No windows detected on any screen.")
            print("Make sure you have at least one visible window open.")
        } else if topWindows.count < screenInfo.count {
            print("ℹ️  Some screens don't have any detectable windows.")
        }
        
        print("\nDebug Information:")
        print("==================")
        let allWindows = WindowDetector.getAllWindowsInfo()
        print("Total windows detected: \(allWindows.count)")
        
        if allWindows.count > 0 && allWindows.count <= 10 {
            print("\nAll windows (front to back):")
            for (index, window) in allWindows.enumerated() {
                print("  \(index + 1). \(window.description)")
            }
        } else if allWindows.count > 10 {
            print("\nFirst 10 windows (front to back):")
            for (index, window) in allWindows.prefix(10).enumerated() {
                print("  \(index + 1). \(window.description)")
            }
            print("  ... and \(allWindows.count - 10) more")
        }
    }
}