//
//  MockURLProtocol.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Foundation

/// テストごとに固有のセッションIDをリクエストヘッダーに乗せて振り分けるため、
/// 並列実行されるテスト同士でスタブが競合しないURLProtocolモック。
final class MockURLProtocol: URLProtocol {

    typealias Handler = (URLRequest) throws -> (statusCode: Int, data: Data)

    private static let sessionIdHeader = "X-Mock-Session-Id"
    private static let lock = NSLock()
    private static var handlers: [String: Handler] = [:]

    static func makeSession(handler: @escaping Handler) -> URLSession {
        let id = UUID().uuidString
        lock.lock()
        handlers[id] = handler
        lock.unlock()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        config.httpAdditionalHeaders = [sessionIdHeader: id]
        return URLSession(configuration: config)
    }

    static func makeSession(statusCode: Int = 200, data: Data) -> URLSession {
        makeSession { _ in (statusCode, data) }
    }

    static func makeSession(statusCode: Int = 200, json: String) -> URLSession {
        makeSession(statusCode: statusCode, data: json.data(using: .utf8)!)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard
            let sessionId = request.value(forHTTPHeaderField: Self.sessionIdHeader),
            let handler = Self.handler(for: sessionId),
            let url = request.url
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        do {
            let (statusCode, data) = try handler(request)
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    private static func handler(for sessionId: String) -> Handler? {
        lock.lock()
        defer { lock.unlock() }
        return handlers[sessionId]
    }
}
