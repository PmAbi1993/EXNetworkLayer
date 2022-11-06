//
//  File.swift
//  
//
//  Created by Abhijith Pm on 01/11/22.
//

import Foundation

public protocol RequestEndpoint {
    var baseURL: String { get }
    var endPoint: String { get }
}

extension RequestEndpoint {
    
    var sanitisedEndpoint: String {
        sanitisedString(endPoint)
    }
}

extension RequestEndpoint {
    private func sanitisedString(_ value: String) -> String {
        var sanitisedString: String = value
        if !sanitisedString.starts(with: "/") {
            sanitisedString.insert("/", at: sanitisedString.startIndex)
        }
        return sanitisedString
    }
}
