import Foundation

public enum APIError: Error, Sendable {
    case invalidResponse
    case server(statusCode: Int, message: String?)
    case decoding(Error)
    case transport(Error)
}

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
            throw APIError.decoding(error)
        }
    }

    public func get<Response: Decodable>(_ path: String) async throws -> Response {
        let request = URLRequest(url: baseURL.appendingPathComponent(path))

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = try? decoder.decode(APIErrorBody.self, from: data).detail
            throw APIError.server(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
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
            throw APIError.decoding(error)
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = try? decoder.decode(APIErrorBody.self, from: data).detail
            throw APIError.server(statusCode: httpResponse.statusCode, message: message)
        }

        return data
    }
}

private struct APIErrorBody: Decodable {
    let detail: String?
}
