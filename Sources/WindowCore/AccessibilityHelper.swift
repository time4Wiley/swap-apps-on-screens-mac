import Foundation
import ApplicationServices

public struct AccessibilityHelper {
    
    private static let kAXTrustedCheckOptionPromptKey = "AXTrustedCheckOptionPrompt"
    
    public static func checkPermissions() -> Bool {
        return AXIsProcessTrusted()
    }
    
    public static func promptForPermissions() {
        print("""
        
        ⚠️  Accessibility permissions are required for this application to work.
        
        To grant permissions:
        1. Open System Settings
        2. Go to Privacy & Security → Accessibility
        3. Click the lock icon to make changes
        4. Add this application to the list (or enable if already present)
        5. Re-run this application
        
        Alternatively, run this command to open the Accessibility settings:
        open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        
        """)
        
        let options: [String: Any] = [kAXTrustedCheckOptionPromptKey: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    public static func ensurePermissions() -> Bool {
        if checkPermissions() {
            print("✓ Accessibility permissions granted\n")
            return true
        } else {
            print("✗ Accessibility permissions not granted")
            promptForPermissions()
            return false
        }
    }
}