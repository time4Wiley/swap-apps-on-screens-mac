import Foundation
import AppKit
import CoreGraphics

public struct WindowDetector {
    
    public static func topWindowsPerScreen() -> [NSScreen: WindowInfo] {
        guard let windowInfoList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as NSArray? else {
            return [:]
        }
        
        var result: [NSScreen: WindowInfo] = [:]
        
        for case let windowDict as NSDictionary in windowInfoList {
            guard let layer = windowDict[kCGWindowLayer as String] as? Int,
                  layer == 0,
                  let pid = windowDict[kCGWindowOwnerPID as String] as? pid_t,
                  let windowID = windowDict[kCGWindowNumber as String] as? CGWindowID,
                  let boundsDict = windowDict[kCGWindowBounds as String] as? NSDictionary,
                  let windowBounds = CGRect(dictionaryRepresentation: boundsDict) else {
                continue
            }
            
            let appName = windowDict[kCGWindowOwnerName as String] as? String
            let windowTitle = windowDict[kCGWindowName as String] as? String
            
            let windowInfo = WindowInfo(
                id: windowID,
                ownerPID: pid,
                frame: windowBounds,
                appName: appName,
                windowTitle: windowTitle,
                layer: layer
            )
            
            for screen in NSScreen.screens {
                if screen.frame.intersects(windowBounds) && result[screen] == nil {
                    result[screen] = windowInfo
                    break
                }
            }
            
            if result.count == NSScreen.screens.count {
                break
            }
        }
        
        return result
    }
    
    public static func getAllWindowsInfo() -> [WindowInfo] {
        guard let windowInfoList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as NSArray? else {
            return []
        }
        
        var windows: [WindowInfo] = []
        
        for case let windowDict as NSDictionary in windowInfoList {
            guard let layer = windowDict[kCGWindowLayer as String] as? Int,
                  layer == 0,
                  let pid = windowDict[kCGWindowOwnerPID as String] as? pid_t,
                  let windowID = windowDict[kCGWindowNumber as String] as? CGWindowID,
                  let boundsDict = windowDict[kCGWindowBounds as String] as? NSDictionary,
                  let windowBounds = CGRect(dictionaryRepresentation: boundsDict) else {
                continue
            }
            
            let appName = windowDict[kCGWindowOwnerName as String] as? String
            let windowTitle = windowDict[kCGWindowName as String] as? String
            
            let windowInfo = WindowInfo(
                id: windowID,
                ownerPID: pid,
                frame: windowBounds,
                appName: appName,
                windowTitle: windowTitle,
                layer: layer
            )
            
            windows.append(windowInfo)
        }
        
        return windows
    }
    
    public static func getScreenInfo() -> [(screen: NSScreen, name: String)] {
        return NSScreen.screens.enumerated().map { index, screen in
            let name = screen.localizedName
            return (screen, name)
        }
    }
}