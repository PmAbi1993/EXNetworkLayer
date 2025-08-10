import Foundation

public extension EXNetworkManager {
    /// Perform the configured request and decode into `T` using `JSONDecoder`.
    /// - Throws: `CancellationError` when the task is cancelled, or `NetworkError` for transport/decoding issues.
    func request<T: Decodable>(_ type: T.Type) async throws -> T {
        if Task.isCancelled { throw CancellationError() }

        let urlRequest = try requestProvider.request()
        do {
            let (data, response) = try await underlyingSession().data(for: urlRequest)

            if Task.isCancelled { throw CancellationError() }

            if api.shouldLog { api.log(api, level: .debug, data: data, error: nil) }

            try validate(response: response)

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decoding(error)
            }
        } catch {
            throw map(error)
        }
    }

    /// Perform the configured request and return raw `Data`.
    func request() async throws -> Data {
        if Task.isCancelled { throw CancellationError() }

        let urlRequest = try requestProvider.request()
        do {
            let (data, response) = try await underlyingSession().data(for: urlRequest)

            if Task.isCancelled { throw CancellationError() }

            if api.shouldLog { api.log(api, level: .debug, data: data, error: nil) }
            try validate(response: response)
            return data
        } catch {
            throw map(error)
        }
    }

    /// Streaming download using URLSession native async bytes API.
    /// Yields chunks as `Data`. Cancelling the consuming task stops the stream.
    func download() -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    if Task.isCancelled { throw CancellationError() }
                    let request = try requestProvider.request()
                    let (bytes, response) = try await underlyingSession().bytes(for: request)
                    try validate(response: response)

                    var buffer = [UInt8]()
                    buffer.reserveCapacity(8 * 1024)

                    for try await byte in bytes {
                        if Task.isCancelled {
                            throw CancellationError()
                        }
                        buffer.append(byte)
                        // Emit in ~8KB chunks to reduce overhead
                        if buffer.count >= 8 * 1024 {
                            continuation.yield(Data(buffer))
                            buffer.removeAll(keepingCapacity: true)
                        }
                    }
                    if !buffer.isEmpty { continuation.yield(Data(buffer)) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: map(error))
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

// MARK: - Internals
extension EXNetworkManager {
    fileprivate func underlyingSession() -> URLSession {
        // Prefer the injected session if it's a URLSession, else default to shared.
        (session as? URLSession) ?? URLSession.shared
    }

    fileprivate func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.invalidResponse(statusCode: http.statusCode)
        }
    }

    fileprivate func map(_ error: Error) -> Error {
        if error is CancellationError { return error }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .cancelled: return CancellationError()
            case .timedOut: return NetworkError.timeout
            default: return NetworkError.transport(urlError)
            }
        }
        return error
    }
}
