import Dependencies
import Foundation

/// The backend base URL. Defaults to APIConstants.baseURL — point that at the Render
/// URL once the backend is deployed.
public struct APIEnvironment: Sendable {
    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}

private struct APIEnvironmentKey: DependencyKey {
    static let liveValue = APIEnvironment(baseURL: APIConstants.baseURL)
}

public extension DependencyValues {
    var apiEnvironment: APIEnvironment {
        get { self[APIEnvironmentKey.self] }
        set { self[APIEnvironmentKey.self] = newValue }
    }
}
