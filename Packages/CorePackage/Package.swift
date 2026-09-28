// swift-tools-version: 6.0
import PackageDescription

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
    targets: [
        .target(name: "DesignSystem"),
        .target(name: "Domain"),
        .target(
            name: "Feature",
            dependencies: ["Domain", "DesignSystem"]
        )
    ]
)
