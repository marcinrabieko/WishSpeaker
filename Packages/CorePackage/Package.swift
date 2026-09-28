// swift-tools-version: 6.0
import PackageDescription

let swiftLintPlugin: Target.PluginUsage = .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")

let package = Package(
    name: "CorePackage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Feature", targets: ["Feature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.1")
    ],
    targets: [
        .target(
            name: "DesignSystem",
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "Domain",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "Feature",
            dependencies: [
                "Domain",
                "DesignSystem",
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            plugins: [swiftLintPlugin]
        )
    ]
)
