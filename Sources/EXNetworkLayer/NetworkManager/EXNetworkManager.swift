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
    
    public init(api: T,
         session: HTTPClient = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder()) {
        self.api = api
        self.session = session
        self.decoder = decoder
        self.requestProvider = EXRequestProvider<T>(api: api)
    }
}
