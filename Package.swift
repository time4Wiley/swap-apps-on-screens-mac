// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwapAppsOnScreens",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "TopWindowDetector",
            targets: ["TopWindowDetector"]
        ),
        .executable(
            name: "SwapWindows",
            targets: ["SwapWindows"]
        ),
        .executable(
            name: "DiagnoseWindows",
            targets: ["DiagnoseWindows"]
        ),
        .executable(
            name: "SizeUpSwapper",
            targets: ["SizeUpSwapper"]
        ),
    ],
    targets: [
        .target(
            name: "WindowCore",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .executableTarget(
            name: "TopWindowDetector",
            dependencies: ["WindowCore"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .executableTarget(
            name: "SwapWindows",
            dependencies: ["WindowCore"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .executableTarget(
            name: "DiagnoseWindows",
            dependencies: ["WindowCore"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .executableTarget(
            name: "SizeUpSwapper",
            dependencies: ["WindowCore"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
    ]
)