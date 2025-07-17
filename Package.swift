// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebpApp",
    platforms: [
        .macOS(.v11)
    ],
    targets: [
        .executableTarget(
            name: "WebpApp",
            path: "Sources",
            swiftSettings: [
                .interoperabilityMode(.C)
            ]
        )
    ]
)
