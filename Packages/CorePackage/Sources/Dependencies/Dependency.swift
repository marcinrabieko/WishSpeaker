import Foundation
import OSLog

//
// simple dependency injection inspired by SwiftUI Environment, freepoint.co and avanderlee.com
//

public protocol DependencyKey {
    associatedtype Value: Sendable

    static var defaultValue: Self.Value { get }
    static var testValue: Self.Value { get }
    static var previewValue: Self.Value { get }
}

public extension DependencyKey {
    static var testValue: Self.Value {
        os_log(.error, log: .default, "Using default value for \(Self.self) in test environment.")
        return defaultValue
    }

    static var previewValue: Self.Value {
        os_log(.error, log: .default, "Using default value for \(Self.self) in preview environment.")
        return defaultValue
    }
}

extension DependencyKey {
    static func resolvedValue(_ environment: Environment) -> Self.Value {
        switch environment {
        case .live:
            defaultValue
        case .preview:
            previewValue
        case .test:
            testValue
        }
    }
}

public struct DependencyValues: Sendable {
    private var registrations: [ObjectIdentifier: any Sendable] = [:]

    internal var environment: Environment = .current

    public subscript<K>(key: K.Type) -> K.Value where K: DependencyKey {
        get { registrations[ObjectIdentifier(key)] as? K.Value ?? key.resolvedValue(environment) }
        set { registrations[ObjectIdentifier(key)] = newValue }
    }
}

extension DependencyValues {
    /// Stores the current dependency values using swift's @TaskLocal property wrapper.
    /// This means each async task gets its own copy of dependency values,
    /// Allowing dependency overrides to be scoped per task, rather than shared globally.
    /// @TaskLocal makes dependency injection safe for swift concurrency,
    /// Without needing locks, actors, or global mutable state.
    @TaskLocal
    private static var current = DependencyValues()

    public static func withDependencies<T>(setup: (inout DependencyValues) -> Void, perform action: () -> T) -> T {
        var newValues = current
        setup(&newValues)

        return $current.withValue(newValues, operation: action)
    }

    public static func withDependencies<T>(setup: (inout DependencyValues) -> Void, perform action: () throws -> T) throws -> T {
        var newValues = current
        setup(&newValues)

        return try $current.withValue(newValues, operation: action)
    }

    // `isolation` captures the caller's actor (via `#isolation`) so the `perform` closure
    // runs in the same isolation domain — no actor boundary crossing, no @Sendable requirement.
    public static func withDependencies<T>(
        setup: (inout DependencyValues) -> Void,
        isolation: isolated (any Actor)? = #isolation,
        perform action: () async -> T
    ) async -> T {
        var newValues = current
        setup(&newValues)

        return await $current.withValue(newValues, operation: action, isolation: isolation)
    }

    public static func withDependencies<T>(
        setup: (inout DependencyValues) -> Void,
        isolation: isolated (any Actor)? = #isolation,
        perform action: () async throws -> T
    ) async throws -> T {
        var newValues = current
        setup(&newValues)

        return try await $current.withValue(newValues, operation: action, isolation: isolation)
    }
}

/// Extension for runtime dependency resolution
/// In classes and structures a LazyDependency wrapped is encouraged
extension DependencyValues {
    public static func resolve<T>(_ keyPath: KeyPath<DependencyValues, T>) -> T {
        current[keyPath: keyPath]
    }
}

/// Environment
///
enum Environment: Sendable {
    case live
    case test
    case preview

    static var current: Self {
        if ProcessInfo.processInfo.environment["XCTestSessionIdentifier"] != nil {
            .test
        } else if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            .preview
        } else {
            .live
        }
    }
}

/// Property wrapper with declaration-time resolution
@propertyWrapper
public struct Dependency<T: Sendable>: Sendable {
    /// Captured value
    ///
    public let wrappedValue: T

    /// Creates a property wrapper
    ///
    /// - Parameters:
    ///   - keyPath: a keyPath to one of the DependencyValues' properties
    public init(_ keyPath: KeyPath<DependencyValues, T>) {
        self.wrappedValue = DependencyValues.resolve(keyPath)
    }
}

/// Property wrapper with use-time resolution
@propertyWrapper
public struct LazyDependency<T: Sendable>: Sendable {
    private let keyPath: KeyPath<DependencyValues, T>

    /// Resolves current value for the specified keypath
    public var wrappedValue: T {
        DependencyValues.resolve(keyPath)
    }

    /// Creates a property wrapper
    ///
    /// - Parameters:
    ///   - keyPath: a keyPath to one of the DependencyValues' properties
    public init(_ keyPath: KeyPath<DependencyValues, T>) {
        self.keyPath = keyPath
    }
}

extension KeyPath: @unchecked @retroactive Sendable {
}
