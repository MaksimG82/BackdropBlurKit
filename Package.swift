// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Undertow",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "Undertow",
            targets: ["Undertow"]
        ),
    ],
    targets: [
        .target(
            name: "Undertow",
            resources: [.process("Metal")]
        ),
        .testTarget(
            name: "UndertowTests",
            path: "Tests/UndertowTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
