//
//  HTTPClient.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol HTTPClient {
    func httpDataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: HTTPClient {
    public func httpDataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.dataTask(with: request, completionHandler: completionHandler)
    }
}
