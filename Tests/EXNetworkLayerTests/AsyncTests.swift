import XCTest
@testable import EXNetworkLayer

// MARK: - URLProtocol Stub
final class TestURLProtocol: URLProtocol {
    // Handler can configure response behavior per test
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data, TimeInterval?, Int?))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = TestURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data, delay, chunkSize) = try handler(request)
            let send: () -> Void = { [weak self] in
                guard let self, let client = self.client else { return }
                client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let size = chunkSize, size > 0, data.count > size {
                    var start = 0
                    while start < data.count {
                        let end = min(start + size, data.count)
                        let sub = data.subdata(in: start..<end)
                        client.urlProtocol(self, didLoad: sub)
                        start = end
                    }
                } else {
                    client.urlProtocol(self, didLoad: data)
                }
                client.urlProtocolDidFinishLoading(self)
            }
            if let delay, delay > 0 {
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) { send() }
            } else {
                send()
            }
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // No-op; URLSession cancellation will call this.
    }
}

// MARK: - Helpers
private func makeSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [TestURLProtocol.self]
    return URLSession(configuration: config)
}

private struct User: Codable, Equatable { let id: Int; let name: String }

private struct SampleAPI: API {
    var scheme: HTTPScheme { .https }
    var method: HTTPMethod { .get }
    var headers: HTTPHeader { .jsonContent }
    var requestParameters: HTTPRequestBody { .none }
    var baseURL: String { "example.com" }
    var endPoint: String { "/test" }
    var shouldLog: Bool { false }
    var sslContent: SSLContent { .none }
}

final class AsyncTests: XCTestCase {
    private func makeClient() -> EXNetworkManager<SampleAPI> {
        EXNetworkManager(api: SampleAPI(), session: makeSession())
    }

    func testRequestDecodesSuccess() async throws {
        let url = URL(string: "https://example.com/test")!
        let body = try JSONEncoder().encode(User(id: 42, name: "Jane"))
        TestURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, body, nil, nil)
        }
        let client = makeClient()
        let user: User = try await client.request(User.self)
        XCTAssertEqual(user, User(id: 42, name: "Jane"))
    }

    func testRequestNon2xxThrowsInvalidResponse() async {
        let url = URL(string: "https://example.com/test")!
        TestURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data(), nil, nil)
        }
        let client = makeClient()
        await XCTAssertThrowsErrorAsync(try await client.request(User.self)) { error in
            guard case NetworkError.invalidResponse(let code) = error else { return XCTFail("Wrong error: \(error)") }
            XCTAssertEqual(code, 404)
        }
    }

    func testRequestDecodingError() async {
        let url = URL(string: "https://example.com/test")!
        let invalidJSON = Data("{}".utf8)
        TestURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, invalidJSON, nil, nil)
        }
        let client = makeClient()
        await XCTAssertThrowsErrorAsync(try await client.request(User.self)) { error in
            guard case NetworkError.decoding = error else { return XCTFail("Wrong error: \(error)") }
        }
    }

    func testTransportTimeoutMapsToTimeout() async {
        TestURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }
        let client = makeClient()
        await XCTAssertThrowsErrorAsync(try await client.request(User.self)) { error in
            guard case NetworkError.timeout = error else { return XCTFail("Wrong error: \(error)") }
        }
    }

    func testCancellationSurfacesCancellationError() async {
        let url = URL(string: "https://example.com/test")!
        let body = Data("{\"id\":1,\"name\":\"A\"}".utf8)
        // Delay the response so we can cancel before it completes
        TestURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, body, 0.5, nil)
        }
        let client = makeClient()
        let task = Task {
            let _: User = try await client.request(User.self)
        }
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("Expected CancellationError")
        } catch is CancellationError {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testStreamingDownloadYieldsChunks() async throws {
        let url = URL(string: "https://example.com/test")!
        // 20KB of data split into 5KB chunks
        let total = 20 * 1024
        let data = Data(Array(repeating: 0xAB, count: total))
        TestURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data, nil, 5 * 1024)
        }
        let client = makeClient()
        var received = Data()
        for try await chunk in client.download() {
            received.append(chunk)
        }
        XCTAssertEqual(received.count, total)
        XCTAssertEqual(received.prefix(4), Data([0xAB, 0xAB, 0xAB, 0xAB]))
    }

    func testStreamingPartialConsumptionEarlyBreak() async throws {
        let url = URL(string: "https://example.com/test")!
        // 100KB payload streamed in small chunks; our downloader will coalesce to ~8KB
        let total = 100 * 1024
        let data = Data(Array(repeating: 0xCD, count: total))
        TestURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data, nil, 1024) // 1KB chunks from transport
        }
        let client = makeClient()
        var firstChunk: Data?
        var count = 0
        for try await chunk in client.download() {
            count += 1
            firstChunk = chunk
            break // Early break to ensure producer task cancels via onTermination
        }
        XCTAssertEqual(firstChunk?.count, 8 * 1024)
        XCTAssertEqual(count, 1)
    }

    func testRawDataRequestSuccess() async throws {
        let url = URL(string: "https://example.com/test")!
        let payload = Data([0x01, 0x02, 0x03])
        TestURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, payload, nil, nil)
        }
        let client = makeClient()
        let data = try await client.request()
        XCTAssertEqual(data, payload)
    }

    func testConcurrentlyPreservesOrder() async throws {
        let result = try await concurrently([
            { try await Task.sleep(nanoseconds: 50_000_000); return 1 },
            { return 2 },
            { try await Task.sleep(nanoseconds: 10_000_000); return 3 }
        ])
        XCTAssertEqual(result, [1, 2, 3])
    }

    enum DummyError: Error { case boom }
    func testConcurrentlyFailFastCancelsOthers() async {
        var finished = false
        do {
            _ = try await concurrently([
                { try await Task.sleep(nanoseconds: 200_000_000); return 0 },
                { () async throws -> Int in throw DummyError.boom },
                {
                    // should be cancelled before finishing
                    try await Task.sleep(nanoseconds: 300_000_000)
                    finished = true
                    return 2
                }
            ])
            XCTFail("Expected error")
        } catch {
            // expected; ensure last task didn't finish
            XCTAssertFalse(finished)
        }
    }
}

// MARK: - Async Assert Helpers
extension XCTestCase {
    func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure @escaping () async throws -> T,
                                      _ message: @autoclosure @escaping () -> String = "",
                                      file: StaticString = #filePath,
                                      line: UInt = #line,
                                      _ errorHandler: @escaping (Error) -> Void) async {
        do {
            _ = try await expression()
            XCTFail("Expected error not thrown. " + message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
