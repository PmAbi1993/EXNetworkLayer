//
//  EXNetworkManager.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import UIKit

public class EXNetworkManager<T: API>: BasicRequest {
    
    public var api: API
    public var session: HTTPClient
    public var decoder: JSONDecoder
    public var requestProvider: RequestProvider
    
    
    private var sslPinner: SSLPinningHandler?
    
    public init(api: T,
         session: HTTPClient = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder()) {
        self.api = api
        self.session = session
        self.decoder = decoder
        self.requestProvider = EXRequestProvider<T>(api: api)
        if let sslSession = prepareSessionForSSL() {
            self.session = sslSession
        }
    }
}

// MARK: Prepare session for ssl Pinning
extension EXNetworkManager {
    func prepareSessionForSSL() -> URLSession? {
        switch self.api.sslContent {
        case .none: return .shared
        case .file(bundle: let bundle, name: let fileName, extenstion: let extenstion):
            sslPinner = SSLPinningHandler(bundle: bundle, fileName: fileName, fileExtension: extenstion)
            return sslPinner?.urlSession ?? URLSession(configuration: .default)
        }
    }
}
