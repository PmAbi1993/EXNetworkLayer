//
//  EXRequestProvider.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation

public class EXRequestProvider<T: API>: RequestProvider {
    
    public var api: API
    public var requestBodyContentCreator: RequestBodyContentCreator

    public init(api: T) {
        self.api = api
        self.requestBodyContentCreator = EXRequestBodyCreator(api: api)
    }
}
