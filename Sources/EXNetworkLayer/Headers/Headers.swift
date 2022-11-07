//
//  File.swift
//  
//
//  Created by Abhijith Pm on 01/11/22.
//

import Foundation


public typealias HTTPHeader = [String: HeaderValue]

public protocol RequestHeaders {
    var method: HTTPMethod { get }
    var headers: HTTPHeader { get }
}

extension RequestHeaders {
    public func allHeaderData() -> [String: String] {
        var updatedHeaders: [String: String] = [:]
        for key in headers.keys {
            if let dictionaryData = headers[key] {
                updatedHeaders[key] = dictionaryData.value
            }
        }
        return updatedHeaders
    }
}
extension Dictionary where Key == String, Value == HeaderValue {
    
    public static var none: HTTPHeader { return [:] }
    
    public static var jsonContent: HTTPHeader {
        return ["Content-Type": "application/json; charset=utf-8"]
    }
}

public protocol HeaderValue {
    var value: String { get }
}
extension String: HeaderValue {
    public var value: String {
        self
    }
}
extension Int: HeaderValue {
    public var value: String {
        "\(self)"
    }
}
extension Double: HeaderValue {
    public var value: String {
        "\(self)"
    }
}
