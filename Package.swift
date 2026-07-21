// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-http-body",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: "HTTP Body", targets: ["HTTP Body"]),
        .library(name: "HTTP Body JSON", targets: ["HTTP Body JSON"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-http-standard.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-coder-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-parser-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-serializer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-either-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-json.git", branch: "main")
    ],
    targets: [
        .target(
            name: "HTTP Body",
            dependencies: [
                .product(name: "HTTP Standard", package: "swift-http-standard"),
                .product(name: "Byte Primitive", package: "swift-byte-primitives"),
                .product(name: "Coder Primitives", package: "swift-coder-primitives"),
                // The DEFINING modules of `Parser.Protocol` / `Serializer.Protocol`.
                // `Coder Primitives` imports them non-exported, so naming their
                // associated types in this package's own public surface requires
                // depending on them directly ([MOD-038]).
                .product(name: "Parser Primitive", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitive", package: "swift-serializer-primitives")
            ]
        ),
        // Opt-in leaf: the JSON wire form. Consumers that do not encode JSON
        // bodies never pay for swift-json.
        .target(
            name: "HTTP Body JSON",
            dependencies: [
                "HTTP Body",
                .product(name: "JSON", package: "swift-json"),
                .product(name: "Byte Primitives Standard Library Integration", package: "swift-byte-primitives"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Parser Primitive", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitive", package: "swift-serializer-primitives")
            ]
        ),
        .testTarget(
            name: "HTTP Body Tests",
            dependencies: [
                "HTTP Body",
                // Fixture codecs conform to the contract directly, so the
                // tests name the inherited associated types themselves.
                .product(name: "Coder Primitives", package: "swift-coder-primitives"),
                .product(name: "Parser Primitive", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitive", package: "swift-serializer-primitives")
            ]
        ),
        .testTarget(
            name: "HTTP Body JSON Tests",
            dependencies: [
                "HTTP Body JSON",
                .product(name: "Coder Primitives", package: "swift-coder-primitives"),
                .product(name: "Parser Primitive", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitive", package: "swift-serializer-primitives")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
