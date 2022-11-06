//
//  File.swift
//  
//
//  Created by Abhijith Pm on 01/11/22.
//

import Foundation

public enum HTTPScheme: String {
    case http
    case https
    
    var value: String {
        self.rawValue.uppercased()
    }
}
