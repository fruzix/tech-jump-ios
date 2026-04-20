//
//  WebRepository.swift
//  TechJumpIOS
//
//  Created by Aleksandra Niewińska on 15/12/2025.
//

import Combine
import Foundation
import OSLog

enum ApiModel {}

private let networkLogger = Logger(subsystem: "TechJumpIOS", category: "network")

protocol WebRepository {
    var session: URLSession { get }
    var baseURL: String { get }
}

protocol APICall {
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    func body() throws -> Data?
}

enum APIError: Swift.Error, Equatable, LocalizedError {
    case invalidURL(String)
    case requestFailed(String, String)
    case httpCode(HTTPCode, String, String?)
    case unexpectedResponse(String)
    case decodingFailed(String, String)
    case imageDeserialization

    var errorDescription: String? {
        switch self {
        case let .invalidURL(url):
            return "Invalid URL: \(url)"
        case let .requestFailed(url, description):
            return "Request failed for \(url): \(description)"
        case let .httpCode(code, url, body):
            if let body, !body.isEmpty {
                return "Unexpected HTTP code \(code) for \(url). Response: \(body)"
            }
            return "Unexpected HTTP code \(code) for \(url)"
        case let .unexpectedResponse(url):
            return "Unexpected response from the server for \(url)"
        case let .decodingFailed(url, description):
            return "Failed to decode response from \(url): \(description)"
        case .imageDeserialization: return "Cannot deserialize image from Data"
        }
    }
}

extension WebRepository {
    func call<Value, Decoder>(
        endpoint: APICall,
        decoder: Decoder = JSONDecoder(),
        httpCodes: HTTPCodes = .success
    ) async throws -> Value
        where Value: Decodable, Decoder: TopLevelDecoder, Decoder.Input == Data
    {
        let request = try endpoint.urlRequest(baseURL: baseURL)
        networkLogger.debug("Starting request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            let url = request.url?.absoluteString ?? "unknown"
            networkLogger.error("Request failed: \(url) error=\(error.localizedDescription)")
            throw APIError.requestFailed(url, error.localizedDescription)
        }

        let requestURL = request.url?.absoluteString ?? "unknown"
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            networkLogger.error("Unexpected response without HTTP status for \(requestURL)")
            throw APIError.unexpectedResponse(requestURL)
        }
        guard httpCodes.contains(code) else {
            let responseBody = String(data: data, encoding: .utf8)
            networkLogger.error("HTTP failure for \(requestURL) status=\(code) body=\(responseBody ?? "<non-utf8>")")
            throw APIError.httpCode(code, requestURL, responseBody)
        }
        do {
            return try decoder.decode(Value.self, from: data)
        } catch {
            networkLogger.error("Decoding failure for \(requestURL): \(error.localizedDescription)")
            throw APIError.decodingFailed(requestURL, error.localizedDescription)
        }
    }
}

extension APICall {
    func urlRequest(baseURL: String) throws -> URLRequest {
        let urlString = baseURL + path
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL(urlString)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = try body()
        return request
    }
}

typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    static let success = 200 ..< 300
}
