//
//  File.swift
//  
//
//  Created by Abhijith Pm on 01/11/22.
//

import Foundation


public typealias HTTPHeader = [String: HeaderValue]

public protocol RequestHeaders {
    var headers: HTTPHeader { get }
}

extension Dictionary where Key == String, Value == HeaderValue {
    
    public static var none: HTTPHeader { return [:] }
    
    public static var jsonContent: HTTPHeader {
        return ["Content-Type": "application/json; charset=utf-8"]
    }
}

public protocol HeaderValue {}
extension String: HeaderValue {}
extension Int: HeaderValue {}
extension Double: HeaderValue {}
