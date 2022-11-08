//
//  SSLPinner.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation

// TODO: Add the ability to provide Public key ssl pinning. Refer [:TrustKit] for this
public enum SSLContent: Equatable {
    case none
    case file(bundle: Bundle, name: String, extenstion: String = "cer")
}

public protocol SSLPinner {
    var sslContent: SSLContent { get }
}

extension SSLPinner {
    var sslContent: SSLContent { .none }
    func isSSLPinned() -> Bool {
        return !(self.sslContent == .none)
    }
}

