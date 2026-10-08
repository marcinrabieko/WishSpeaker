import Foundation
import OSLog

public enum APIError: Error, Sendable {
    case invalidResponse
    case server(statusCode: Int, message: String?)
    case decoding(Error)
    case transport(Error)
}

private let networkLogger = Logger(subsystem: "com.wishspeaker.app", category: "Networking")

/// Thin JSON POST wrapper around URLSession for the WishSpeaker backend. Every current
/// endpoint is a POST with a JSON body and a JSON response, so this does not attempt to
/// be a general-purpose HTTP client.
public struct APIClient: Sendable {
    public let baseURL: URL

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    public func post<Request: Encodable, Response: Decodable>(
        _ path: String,
        body: Request
    ) async throws -> Response {
        let data = try await postRawData(path, body: body)

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            networkLogger.error("[\(path, privacy: .public)] Decoding failed: \(String(describing: error), privacy: .public)")
            throw APIError.decoding(error)
        }
    }

    public func get<Response: Decodable>(_ path: String) async throws -> Response {
        let request = URLRequest(url: baseURL.appendingPathComponent(path))
        logRequest(request)

        let data: Data
        let response: URLResponse

        let startedAt = Date()
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logTransportError(error, path: path, elapsedSince: startedAt)
            throw APIError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            networkLogger.error("[\(path, privacy: .public)] Response was not an HTTPURLResponse: \(String(describing: response), privacy: .public)")
            throw APIError.invalidResponse
        }

        logResponse(httpResponse, data: data, path: path, elapsedSince: startedAt)

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = try? decoder.decode(APIErrorBody.self, from: data).detail
            throw APIError.server(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            networkLogger.error("[\(path, privacy: .public)] Decoding failed: \(String(describing: error), privacy: .public)")
            throw APIError.decoding(error)
        }
    }

    /// For endpoints that respond with a raw binary body (e.g. audio/mpeg) instead of
    /// JSON — still sends a JSON-encoded request body, same as `post`.
    public func postRawData<Request: Encodable>(
        _ path: String,
        body: Request
    ) async throws -> Data {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            networkLogger.error("[\(path, privacy: .public)] Request body encoding failed: \(String(describing: error), privacy: .public)")
            throw APIError.decoding(error)
        }

        logRequest(request)

        let data: Data
        let response: URLResponse

        let startedAt = Date()
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logTransportError(error, path: path, elapsedSince: startedAt)
            throw APIError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            networkLogger.error("[\(path, privacy: .public)] Response was not an HTTPURLResponse: \(String(describing: response), privacy: .public)")
            throw APIError.invalidResponse
        }

        logResponse(httpResponse, data: data, path: path, elapsedSince: startedAt)

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = try? decoder.decode(APIErrorBody.self, from: data).detail
            throw APIError.server(statusCode: httpResponse.statusCode, message: message)
        }

        return data
    }

    // MARK: - Logging

    private func logRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "<nil>"
        let headers = request.allHTTPHeaderFields ?? [:]
        let timeout = request.timeoutInterval

        networkLogger.debug("""
        ➡️ REQUEST \(method, privacy: .public) \(url, privacy: .public)
        Timeout: \(timeout, privacy: .public)s
        Headers: \(headers, privacy: .public)
        Body: \(bodyDescription(request.httpBody), privacy: .public)
        """)
    }

    private func logResponse(_ response: HTTPURLResponse, data: Data, path: String, elapsedSince startedAt: Date) {
        let elapsed = Date().timeIntervalSince(startedAt)
        let headers = response.allHeaderFields

        networkLogger.debug("""
        ⬅️ RESPONSE [\(path, privacy: .public)] status=\(response.statusCode, privacy: .public) elapsed=\(String(format: "%.2f", elapsed), privacy: .public)s
        Headers: \(headers, privacy: .public)
        Body (\(data.count, privacy: .public) bytes): \(bodyDescription(data), privacy: .public)
        """)
    }

    /// Timeouts surface here as `URLError.timedOut` — logged with the full
    /// NSError (domain/code/userInfo) since "The request timed out" alone doesn't say
    /// whether it was a connect timeout (server unreachable) or a read timeout (server
    /// accepted the connection but never finished responding, e.g. a slow video render).
    private func logTransportError(_ error: Error, path: String, elapsedSince startedAt: Date) {
        let elapsed = Date().timeIntervalSince(startedAt)
        let nsError = error as NSError

        if let urlError = error as? URLError {
            networkLogger.error("""
            ❌ TRANSPORT ERROR [\(path, privacy: .public)] elapsed=\(String(format: "%.2f", elapsed), privacy: .public)s
            URLError.code: \(urlError.code.rawValue, privacy: .public) (\(String(describing: urlError.code), privacy: .public))
            Description: \(urlError.localizedDescription, privacy: .public)
            userInfo: \(nsError.userInfo, privacy: .public)
            """)
        } else {
            networkLogger.error("""
            ❌ TRANSPORT ERROR [\(path, privacy: .public)] elapsed=\(String(format: "%.2f", elapsed), privacy: .public)s
            \(String(describing: error), privacy: .public)
            """)
        }
    }

    /// JSON bodies are pretty-printed for readability; binary bodies (audio/video
    /// bytes) are never dumped as garbled text — only their size.
    private func bodyDescription(_ data: Data?) -> String {
        guard let data, !data.isEmpty else {
            return "<empty>"
        }

        if let json = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
           let string = String(data: pretty, encoding: .utf8) {
            return string
        }

        if let string = String(data: data, encoding: .utf8), string.utf8.count < 2000 {
            return string
        }

        return "<binary, \(data.count) bytes>"
    }
}

private struct APIErrorBody: Decodable {
    let detail: String?
}
