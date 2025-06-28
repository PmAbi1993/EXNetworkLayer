
//
//  MockHTTPClient.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation

private class DummyURLSessionDataTask: URLSessionDataTask {
    override func resume() { }
}

public enum MockData {
    case data(_ data: Data)
    case jsonFile(bundle: Bundle, name: String, extension: String = "json")
    
    var data: Data? {
        switch self {
        case .data(let data):
            return data
        case .jsonFile(let bundle, let name, let `extension`):
            guard let filePath = bundle.path(forResource: name, ofType: `extension`) else {
                return nil
            }
            return NSData(contentsOfFile: filePath) as? Data
        }
    }
}

public class MockHTTPClient: HTTPClient {
    
    var mockData: MockData
    var data: Data?
    
    public init(mockData: MockData) {
        self.mockData = mockData
        self.data = mockData.data
    }

    public func httpDataTask(with request: URLRequest,
                             completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let response = HTTPURLResponse(url: request.url!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        completionHandler(data, response, nil)
        return DummyURLSessionDataTask()
    }
    
    @available(iOS 13.0.0, *)
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation({ continuation in
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
        })
    }
}

