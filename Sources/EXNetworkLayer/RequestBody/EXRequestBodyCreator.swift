//
//  EXRequestBodyCreator.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation

public class EXRequestBodyCreator: RequestBodyContentCreator {
    public var api: API
    public init(api: API) {
        self.api = api
    }
}
