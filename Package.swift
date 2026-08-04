// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LiveBackdropKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "LiveBackdropKit",
            targets: ["LiveBackdropKit"]
        ),
    ],
    targets: [
        .target(
            name: "LiveBackdropKit",
            resources: [.process("Metal")]
        ),
        .testTarget(
            name: "LiveBackdropKitTests",
            path: "Tests/LiveBackdropKitTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
