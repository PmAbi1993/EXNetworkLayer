//
//  RequestBodyContent.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation

public typealias RequestBodyParams = [String: HeaderValue]

public enum HTTPRequestBody {
    case none
    case data(data: Data)
    case body(params: RequestBodyParams)
    case url(params: RequestBodyParams)
}

public protocol RequestBodyContent {
    var requestParameters: HTTPRequestBody { get }
}
