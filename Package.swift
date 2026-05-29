// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TextPocket",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "/tmp/HotKey")
    ],
    targets: [
        .executableTarget(
            name: "TextPocket",
            dependencies: ["HotKey"],
            path: "TextPocket",
            exclude: [
                "Info.plist",
                "TextPocket.entitlements"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
