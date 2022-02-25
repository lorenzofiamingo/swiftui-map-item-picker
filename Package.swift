// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapItemPickerSheet",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "MapItemPickerSheet",
            targets: ["MapItemPickerSheet"])
    ],
    targets: [
        .target(name: "MapItemPickerSheet")
    ]
)
