// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Muharrir",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.7.0"),
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "4.0.0"),
        .package(url: "https://github.com/mattt/ollama-swift.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "muharrir",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "Rainbow", package: "Rainbow"),
                .product(name: "Ollama", package: "ollama-swift"),
            ]
        ),
        .testTarget(
            name: "MuharrirTests",
            dependencies: ["muharrir"]
        ),
    ]
)
