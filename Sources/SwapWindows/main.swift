import Foundation
import WindowCore
import AppKit

@main
struct SwapWindowsApp {
    static func main() {
        print("Window Swapper for Dual Screens")
        print("================================\n")
        
        print("Checking accessibility permissions...")
        
        guard AccessibilityHelper.ensurePermissions() else {
            print("❌ Cannot proceed without accessibility permissions.")
            print("Please grant permissions and run again.")
            exit(1)
        }
        
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
            print("\nMake sure you have:")
            print("- At least 2 screens connected")
            print("- At least one visible window on each screen")
            exit(1)
        }
        
        // Display current state
        print("\nCurrent window configuration:")
        print("-----------------------------")
        for (index, (screen, screenName)) in screenInfo.enumerated() {
            let screenNumber = index + 1
            print("\nScreen \(screenNumber): \(screenName)")
            
            if let window = topWindows[screen] {
                print("  Current top window: \(window.appName ?? "Unknown") - \(window.windowTitle ?? "No title")")
                print("  Position: (\(Int(window.frame.origin.x)), \(Int(window.frame.origin.y)))")
            } else {
                print("  No window detected")
            }
        }
        
        // Perform the swap
        print("\n🔄 Swapping windows...")
        
        switch WindowSwapper.swapTopWindows() {
        case .success(let message):
            print("✅ \(message)")
            
            // Show new configuration
            Thread.sleep(forTimeInterval: 0.5) // Give windows time to move
            
            print("\nNew window configuration:")
            print("-------------------------")
            let newTopWindows = WindowDetector.topWindowsPerScreen()
            
            for (index, (screen, screenName)) in screenInfo.enumerated() {
                let screenNumber = index + 1
                print("\nScreen \(screenNumber): \(screenName)")
                
                if let window = newTopWindows[screen] {
                    print("  New top window: \(window.appName ?? "Unknown") - \(window.windowTitle ?? "No title")")
                    print("  Position: (\(Int(window.frame.origin.x)), \(Int(window.frame.origin.y)))")
                }
            }
            
        case .failure(let error):
            print("❌ Swap failed: \(error)")
            
            if error.description.contains("not allow window repositioning") {
                print("\n💡 Tip: Some applications (like certain system apps or full-screen windows)")
                print("   may not allow their windows to be repositioned programmatically.")
                print("   Try with different applications.")
            }
            
            exit(1)
        }
        
        print("\n✨ Done!")
    }
}