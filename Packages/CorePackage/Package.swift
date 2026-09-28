// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CorePackage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Dependencies", targets: ["Dependencies"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Feature", targets: ["Feature"])
    ],
    targets: [
        .target(name: "Dependencies"),
        .target(name: "DesignSystem"),
        .target(
            name: "Domain",
            dependencies: ["Dependencies"]
        ),
        .target(
            name: "Feature",
            dependencies: ["Domain", "DesignSystem", "Dependencies"]
        )
    ]
)
