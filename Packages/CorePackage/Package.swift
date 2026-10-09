// swift-tools-version: 6.0
import PackageDescription

let swiftLintPlugin: Target.PluginUsage = .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
let swiftGenPlugin: Target.PluginUsage = .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
let dependenciesProduct: Target.Dependency = .product(name: "Dependencies", package: "swift-dependencies")

let package = Package(
    name: "CorePackage",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Localizations", targets: ["Localizations"]),
        .library(name: "Resources", targets: ["Resources"]),
        .library(name: "SharedFeatureComponents", targets: ["SharedFeatureComponents"]),
        .library(name: "StartFeature", targets: ["StartFeature"]),
        .library(name: "OccasionSelectionFeature", targets: ["OccasionSelectionFeature"]),
        .library(name: "FormFeature", targets: ["FormFeature"]),
        .library(name: "WishesFeature", targets: ["WishesFeature"]),
        .library(name: "CreateFeature", targets: ["CreateFeature"]),
        .library(name: "LibraryFeature", targets: ["LibraryFeature"]),
        .library(name: "ExampleWishesFeature", targets: ["ExampleWishesFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.1"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.0")
    ],
    targets: [
        // MARK: - Infrastructure / Domain

        .target(
            name: "DesignSystem",
            dependencies: ["Resources"],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "Domain",
            dependencies: [
                "Localizations",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "Localizations",
            resources: [
                .process("en.lproj"),
                .process("pl.lproj")
            ],
            plugins: [swiftGenPlugin, swiftLintPlugin]
        ),
        .target(
            name: "Resources",
            resources: [
                .process("Fonts")
            ],
            plugins: [swiftGenPlugin, swiftLintPlugin]
        ),

        // MARK: - Shared Feature Components

        .target(
            name: "SharedFeatureComponents",
            dependencies: [
                "Domain",
                "DesignSystem",
                "Localizations"
            ],
            plugins: [swiftLintPlugin]
        ),

        // MARK: - Features

        .target(
            name: "StartFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "Localizations",
                "Resources",
                "OccasionSelectionFeature",
                "FormFeature",
                "WishesFeature",
                "ExampleWishesFeature",
                "LibraryFeature",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "OccasionSelectionFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "Localizations",
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
                "Localizations",
                "WishesFeature",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "WishesFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "Localizations",
                "SharedFeatureComponents",
                "CreateFeature",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "CreateFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "Localizations",
                "SharedFeatureComponents",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "LibraryFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "Localizations",
                "SharedFeatureComponents",
                "CreateFeature",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        ),
        .target(
            name: "ExampleWishesFeature",
            dependencies: [
                "Domain",
                "DesignSystem",
                "Localizations",
                "SharedFeatureComponents",
                dependenciesProduct
            ],
            plugins: [swiftLintPlugin]
        )
    ]
)
