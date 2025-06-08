//
//  RequestProvider.swift
//  
//
//  Created by Abhijith Pm on 06/11/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum RequestCreatorErrors: Error {
    // Errors while creating the URL
    case uriCreationFailed
}

public protocol RequestProvider {
    var api: API { get }
    var requestBodyContentCreator: RequestBodyContentCreator { get }
}

extension RequestProvider {
    
    private func requestComponents() -> URLComponents {
        
        var requestParameters: URLComponents = URLComponents()
        requestParameters.scheme = api.scheme.rawValue
        requestParameters.host = api.baseURL
        requestParameters.port = api.port
        requestParameters.path  = api.sanitisedEndpoint
        requestParameters.queryItems = getURLQueryItems()
        return requestParameters
    }
    
    private func getURLQueryItems() -> [URLQueryItem]? {
        switch api.requestParameters {
        case .url(params: let parameters):
            let urlQueryItems: [URLQueryItem] = parameters.map({ parameter in
                return URLQueryItem(name: parameter.key,
                                    value: parameter.value.value)
            })
            return urlQueryItems
        default: return nil
        }
    }
    
    public func request() throws -> URLRequest {
        
        // We need to create a url before initialising the URLRequest. So we are adding the urlquery items before hand and body parameters later in the stage due to protocol function constriction
        guard let url: URL = requestComponents().url else {
            throw RequestCreatorErrors.uriCreationFailed
        }
        
        // Basic request creation
        var request: URLRequest = URLRequest(
            url: url,
            cachePolicy: api.cachePolicy,
            timeoutInterval: api.timeInterVal
        )
        // MARK: Header data
        request.httpMethod = api.method.value
        request.allHTTPHeaderFields = api.allHeaderData()
        // MARK: Adding Request Body here
        request.httpBody = try requestBodyContentCreator.requestParameterData()
        return request
    }
}
