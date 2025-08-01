import Foundation
import ApplicationServices

public struct WindowSwapper {
    
    /// Get the AXUIElement for a specific window
    private static func axElement(for window: WindowInfo, debug: Bool = false) -> AXUIElement? {
        let appElement = AXUIElementCreateApplication(window.ownerPID)
        
        var axWindowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            appElement,
            kAXWindowsAttribute as CFString,
            &axWindowsRef
        )
        
        if result != .success {
            if debug {
                print("  ⚠️ Failed to get windows for PID \(window.ownerPID): \(result.rawValue)")
            }
            return nil
        }
        
        // Ensure it's an array type
        guard CFGetTypeID(axWindowsRef) == CFArrayGetTypeID(),
              let windowList = (axWindowsRef as! CFArray) as? [AXUIElement] else {
            if debug {
                print("  ⚠️ Windows attribute is not an array")
            }
            return nil
        }
        
        if debug {
            print("  ℹ️ Found \(CFArrayGetCount(axWindowsRef as! CFArray)) windows for \(window.appName ?? "Unknown")")
        }
        
        // Find the window with matching ID
        for (index, windowElement) in windowList.enumerated() {
            var windowNumber: AnyObject?
            if AXUIElementCopyAttributeValue(
                windowElement,
                "AXWindowNumber" as CFString,
                &windowNumber
            ) == .success,
            let number = windowNumber as? Int {
                if debug {
                    print("    Window \(index): ID = \(number)")
                }
                if number == Int(window.id) {
                    return windowElement
                }
            }
        }
        
        if debug {
            print("  ⚠️ Window ID \(window.id) not found in AX windows")
        }
        
        return nil
    }
    
    /// Get the current position of a window
    private static func getPosition(of element: AXUIElement) -> AXValue? {
        var positionRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            element,
            kAXPositionAttribute as CFString,
            &positionRef
        ) == .success else {
            return nil
        }
        
        // AXValue is a CFTypeRef, so we need to ensure it's the right type
        guard CFGetTypeID(positionRef) == AXValueGetTypeID() else {
            return nil
        }
        
        return (positionRef as! AXValue)
    }
    
    /// Set the position of a window
    private static func setPosition(of element: AXUIElement, to position: AXValue) -> Bool {
        return AXUIElementSetAttributeValue(
            element,
            kAXPositionAttribute as CFString,
            position
        ) == .success
    }
    
    /// Swap the positions of the topmost windows on each screen
    public static func swapTopWindows() -> Result<String, SwapError> {
        // Get top windows per screen
        let topWindows = WindowDetector.topWindowsPerScreen()
        
        guard topWindows.count == 2 else {
            return .failure(.incorrectWindowCount(topWindows.count))
        }
        
        let windows = Array(topWindows.values)
        guard let firstWindow = windows.first,
              let secondWindow = windows.dropFirst().first else {
            return .failure(.windowDetectionFailed)
        }
        
        // Get AX elements for both windows
        print("\nDebug: Getting AX elements...")
        print("\nFirst window: \(firstWindow.appName ?? "Unknown")")
        guard let firstElement = axElement(for: firstWindow, debug: true) else {
            return .failure(.axElementNotFound(firstWindow))
        }
        
        print("\nSecond window: \(secondWindow.appName ?? "Unknown")")
        guard let secondElement = axElement(for: secondWindow, debug: true) else {
            return .failure(.axElementNotFound(secondWindow))
        }
        
        // Get current positions
        guard let firstPosition = getPosition(of: firstElement) else {
            return .failure(.positionReadFailed(firstWindow))
        }
        
        guard let secondPosition = getPosition(of: secondElement) else {
            return .failure(.positionReadFailed(secondWindow))
        }
        
        // Swap positions
        let firstMoved = setPosition(of: firstElement, to: secondPosition)
        let secondMoved = setPosition(of: secondElement, to: firstPosition)
        
        if !firstMoved {
            return .failure(.positionSetFailed(firstWindow))
        }
        
        if !secondMoved {
            // Try to restore first window to original position
            _ = setPosition(of: firstElement, to: firstPosition)
            return .failure(.positionSetFailed(secondWindow))
        }
        
        return .success("Successfully swapped windows")
    }
    
    /// Swap specific windows by their IDs
    public static func swapWindows(firstID: CGWindowID, secondID: CGWindowID) -> Result<String, SwapError> {
        // Find windows by ID
        let allWindows = WindowDetector.getAllWindowsInfo()
        
        guard let firstWindow = allWindows.first(where: { $0.id == firstID }) else {
            return .failure(.windowNotFound(firstID))
        }
        
        guard let secondWindow = allWindows.first(where: { $0.id == secondID }) else {
            return .failure(.windowNotFound(secondID))
        }
        
        // Get AX elements
        guard let firstElement = axElement(for: firstWindow) else {
            return .failure(.axElementNotFound(firstWindow))
        }
        
        guard let secondElement = axElement(for: secondWindow) else {
            return .failure(.axElementNotFound(secondWindow))
        }
        
        // Get and swap positions
        guard let firstPosition = getPosition(of: firstElement),
              let secondPosition = getPosition(of: secondElement) else {
            return .failure(.positionReadFailed(firstWindow))
        }
        
        let firstMoved = setPosition(of: firstElement, to: secondPosition)
        let secondMoved = setPosition(of: secondElement, to: firstPosition)
        
        if !firstMoved || !secondMoved {
            return .failure(.swapFailed)
        }
        
        return .success("Successfully swapped windows \(firstID) and \(secondID)")
    }
}

public enum SwapError: Error, CustomStringConvertible {
    case incorrectWindowCount(Int)
    case windowDetectionFailed
    case windowNotFound(CGWindowID)
    case axElementNotFound(WindowInfo)
    case positionReadFailed(WindowInfo)
    case positionSetFailed(WindowInfo)
    case swapFailed
    
    public var description: String {
        switch self {
        case .incorrectWindowCount(let count):
            return "Expected exactly 2 screens with windows, but found \(count)"
        case .windowDetectionFailed:
            return "Failed to detect windows"
        case .windowNotFound(let id):
            return "Window with ID \(id) not found"
        case .axElementNotFound(let window):
            return "Could not get accessibility element for window: \(window.description)"
        case .positionReadFailed(let window):
            return "Could not read position for window: \(window.description)"
        case .positionSetFailed(let window):
            return "Could not set position for window: \(window.description). The app may not allow window repositioning."
        case .swapFailed:
            return "Failed to swap window positions"
        }
    }
}