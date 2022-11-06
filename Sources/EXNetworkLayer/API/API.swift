//
//  File.swift
//  
//
//  Created by Abhijith Pm on 01/11/22.
//

import Foundation

public protocol API: RequestHeaders, RequestEndpoint {
    var scheme: HTTPScheme { get }
}

extension API {
    var port: Int? { nil }
    var uniqueID: String { UUID().uuidString }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var timeInterVal: TimeInterval { 60.0 }
}
