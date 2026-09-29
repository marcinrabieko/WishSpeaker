// swift-tools-version: 6.0
import PackageDescription

let swiftLintPlugin: Target.PluginUsage = .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
let dependenciesProduct: Target.Dependency = .product(name: "Dependencies", package: "swift-dependencies")

let package = Package(
    name: "CorePackage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "SharedFeatureComponents", targets: ["SharedFeatureComponents"]),
        .library(name: "StartFeature", targets: ["StartFeature"]),
        .library(name: "OccasionSelectionFeature", targets: ["OccasionSelectionFeature"]),
        .library(name: "FormFeature", targets: ["FormFeature"]),
        .library(name: "GeneratedPreviewFeature", targets: ["GeneratedPreviewFeature"]),
        .library(name: "PackageSelectionFeature", targets: ["PackageSelectionFeature"]),
        .library(name: "FinalWishFeature", targets: ["FinalWishFeature"]),
        .library(name: "MyWishesFeature", targets: ["MyWishesFeature"]),
        .library(name: "ExampleWishesFeature", targets: ["ExampleWishesFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.1")
    ],
    targets: [
        // MARK: - Infrastructure / Domain

        .target(
            name: "DesignSystem",
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "Domain",
            dependencies: [dependenciesProduct],
            plugins: [swiftLintPlugin]
        ),

        // MARK: - Shared Feature Components

        .target(
            name: "SharedFeatureComponents",
            dependencies: [
                "Domain",
                "DesignSystem"
            ],
            plugins: [swiftLintPlugin]
        ),

        // MARK: - Features

        .target(
            name: "StartFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "OccasionSelectionFeature",
                "ExampleWishesFeature",
                "MyWishesFeature",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "OccasionSelectionFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "FormFeature",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "FormFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "GeneratedPreviewFeature",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "GeneratedPreviewFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "PackageSelectionFeature",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "PackageSelectionFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "FinalWishFeature",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "FinalWishFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "SharedFeatureComponents",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "MyWishesFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "SharedFeatureComponents",
                "FinalWishFeature",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "ExampleWishesFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        )
    ]
)
