import Foundation
import CoreGraphics

public struct WindowInfo: Sendable {
    public let id: CGWindowID
    public let ownerPID: pid_t
    public let frame: CGRect
    public let appName: String?
    public let windowTitle: String?
    public let layer: Int
    
    public init(
        id: CGWindowID,
        ownerPID: pid_t,
        frame: CGRect,
        appName: String? = nil,
        windowTitle: String? = nil,
        layer: Int = 0
    ) {
        self.id = id
        self.ownerPID = ownerPID
        self.frame = frame
        self.appName = appName
        self.windowTitle = windowTitle
        self.layer = layer
    }
    
    public var description: String {
        var desc = "Window ID: \(id)"
        if let app = appName {
            desc += ", App: \(app)"
        }
        if let title = windowTitle, !title.isEmpty {
            desc += ", Title: \"\(title)\""
        }
        desc += ", Position: (\(Int(frame.origin.x)), \(Int(frame.origin.y)))"
        desc += ", Size: \(Int(frame.width))x\(Int(frame.height))"
        desc += ", PID: \(ownerPID)"
        return desc
    }
}