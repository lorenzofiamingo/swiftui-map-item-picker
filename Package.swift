// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "swiftui-map-item-picker",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "MapItemPicker",
            targets: ["MapItemPicker"])
    ],
    targets: [
        .target(name: "MapItemPicker")
    ]
)
