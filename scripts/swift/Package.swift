// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift",
    products: [
        .executable(name: "reveal-macos", targets: ["reveal-macos"]),
        .executable(name: "reveal-macos-stdin", targets: ["reveal-macos-stdin"]),
        .executable(name: "open-macos", targets: ["open-macos"]),
        .executable(name: "open-macos-stdin", targets: ["open-macos-stdin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "SharedForFinder",
            dependencies: []
        ),
        .executableTarget(
            name: "reveal-macos",
            dependencies: ["SharedForFinder", .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
        .executableTarget(
            name: "reveal-macos-stdin",
            dependencies: ["SharedForFinder", .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
        .executableTarget(
            name: "open-macos",
            dependencies: ["SharedForFinder", .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
        .executableTarget(
            name: "open-macos-stdin",
            dependencies: ["SharedForFinder", .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
    ]
)
