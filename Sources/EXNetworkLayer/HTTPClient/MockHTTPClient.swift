//
//  MockHTTPClient.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation

public enum MockData {
    case data(_ data: Data)
    case jsonFile(bundle: Bundle, name: String, `extension`: String = "json")
    
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
        completionHandler(data, nil, nil)
        return URLSession.shared.dataTask(with: request)
    }
}
