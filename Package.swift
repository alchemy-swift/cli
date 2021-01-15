// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "alchemy-cli",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .executable(name: "alchemy", targets: ["CLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.0")),
    ],
    targets: [
        .target(
            name: "CLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
    ]
)
