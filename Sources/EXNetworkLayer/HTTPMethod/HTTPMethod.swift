//
//  RequestMethods.swift
//  
//
//  Created by Abhijith Pm on 06/11/22.
//

import Foundation

public enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
    
    public var value: String {
        self.rawValue.uppercased()
    }
}

