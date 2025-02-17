// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "RakuyoSwift",
    platforms: [.macOS(.v13)],
    products: [
        .plugin(name: "FormatSwift", targets: ["FormatSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
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
                "swiftformat",
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
            name: "swiftformat",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.55.0/SwiftFormat.artifactbundle.zip",
            checksum: "83bf5673561eff20d407d6642e3572dfbd8e6c129eab66e950f361af424b0b0f"
        ),

        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.55.1/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "722a705de1cf4e0e07f2b7d2f9f631f3a8b2635a0c84cce99f9677b38aa4a1d6"
        ),
    ]
)
