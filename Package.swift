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
    ]
)