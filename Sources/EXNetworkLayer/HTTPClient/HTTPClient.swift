//
//  HTTPClient.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation

public protocol HTTPClient {
    func httpDataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    
    @available(iOS 13.0.0, *)
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

@available(iOS 13.0.0, *)
extension HTTPClient {
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = httpDataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data = data, let response = response else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
}

extension URLSession: HTTPClient {
    public func httpDataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.dataTask(with: request, completionHandler: completionHandler)
    }
}
