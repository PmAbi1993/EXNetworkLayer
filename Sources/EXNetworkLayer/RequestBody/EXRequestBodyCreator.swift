//
//  EXRequestBodyCreator.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import UIKit

public class EXRequestBodyCreator: RequestBodyContentCreator {
    public var api: API
    public init(api: API) {
        self.api = api
    }
}
