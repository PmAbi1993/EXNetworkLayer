//
//  RequestProvider.swift
//  
//
//  Created by Abhijith Pm on 06/11/22.
//

import Foundation

enum RequestCreatorErrors: Error {
    case uriCreationFailed
}

public protocol RequestProvider {
    associatedtype Api: API
    var api: Api { get }
}

extension RequestProvider {
    
    private func requestComponents() -> URLComponents {
        
        var requestParameters: URLComponents = URLComponents()
        requestParameters.scheme = api.scheme.rawValue
        requestParameters.host = api.baseURL
        requestParameters.port = api.port
        requestParameters.path  = api.sanitisedEndpoint
        return requestParameters
    }
    
    public func request() throws -> URLRequest {
        guard let url: URL = requestComponents().url else {
            throw RequestCreatorErrors.uriCreationFailed
        }
        
        let request: URLRequest = URLRequest(
            url: url,
            cachePolicy: api.cachePolicy,
            timeoutInterval: api.timeInterVal
        )
        
        return request
    }
}
