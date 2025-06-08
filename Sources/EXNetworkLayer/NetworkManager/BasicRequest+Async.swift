import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension BasicRequest {
    func callApi<U: Decodable>(responseType: U.Type) async throws -> U {
        guard let request = try? requestProvider.request() else {
            throw BasicRequestError.generalError
        }
        return try await withCheckedThrowingContinuation { continuation in
            session.httpDataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: BasicRequestError.apiResponseError(error: error))
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: BasicRequestError.noDataPresentInApi(error))
                    return
                }
                if self.api.shouldLog {
                    self.api.log(self.api,
                                 level: error == nil ? .debug : .error,
                                 data: data,
                                 error: error)
                }
                guard let value = try? self.decoder.decode(responseType, from: data) else {
                    continuation.resume(throwing: BasicRequestError.parsingfailed)
                    return
                }
                continuation.resume(returning: value)
            }.resume()
        }
    }

    func callApi<U: Decodable>(responseType: [U].Type) async throws -> [U] {
        guard let request = try? requestProvider.request() else {
            throw BasicRequestError.generalError
        }
        return try await withCheckedThrowingContinuation { continuation in
            session.httpDataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: BasicRequestError.apiResponseError(error: error))
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: BasicRequestError.noDataPresentInApi(error))
                    return
                }
                if self.api.shouldLog {
                    self.api.log(self.api,
                                 level: error == nil ? .debug : .error,
                                 data: data,
                                 error: error)
                }
                guard let value = try? self.decoder.decode(responseType, from: data) else {
                    continuation.resume(throwing: BasicRequestError.parsingfailed)
                    return
                }
                continuation.resume(returning: value)
            }.resume()
        }
    }
}
