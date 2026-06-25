// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BackdropBlurKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "BackdropBlurKit",
            targets: ["BackdropBlurKit"]
        ),
    ],
    targets: [
        .target(
            name: "BackdropBlurKit"
        ),
        .testTarget(
            name: "BackdropBlurKitTests",
            path: "Tests/BackdropBlurKit"
        ),
    ],
    swiftLanguageModes: [.v6]
)
