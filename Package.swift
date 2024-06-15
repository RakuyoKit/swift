// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "RakuyoSwift",
    platforms: [.macOS(.v13)],
    products: [
        .plugin(name: "FormatSwift", targets: ["FormatSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.4.0"),
    ],
    targets: [
        .plugin(
            name: "FormatSwift",
            capability: .command(
                intent: .custom(
                    verb: "format",
                    description: "Formats Swift source files according to the Rakuyo Swift Style Guide"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Format Swift source files"),
                ]
            ),
            dependencies: [
                "RakuyoSwiftFormatTool",
                "SwiftFormat",
                "SwiftLintBinary",
            ]
        ),

        .executableTarget(
            name: "RakuyoSwiftFormatTool",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .process("rakuyo.swiftformat"),
                .process("swiftlint.yml"),
            ]
        ),

        .testTarget(
            name: "RakuyoSwiftFormatToolTests",
            dependencies: ["RakuyoSwiftFormatTool"]
        ),

        .binaryTarget(
            name: "SwiftFormat",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.54.0/SwiftFormat.artifactbundle.zip",
            checksum: "edf4ed2f1664ad621ae71031ff915e0c6ef80ad66e87ea0e5a10c3580a27a6dd"
        ),

        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.55.1/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "722a705de1cf4e0e07f2b7d2f9f631f3a8b2635a0c84cce99f9677b38aa4a1d6"
        ),
    ]
)
