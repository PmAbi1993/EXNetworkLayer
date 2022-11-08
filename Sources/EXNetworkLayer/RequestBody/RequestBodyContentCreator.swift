//
//  RequestBodyContentCreator.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation

enum RequestBodyContentCreatorErros: Error {
    case jsonParsingFailedForBodyParams
}

public protocol RequestBodyContentCreator {
    var api: API { get }
}
extension RequestBodyContentCreator {
    func requestParameterData() throws -> Data? {
        switch api.requestParameters {
        case .data(data: let data):
            return data
        case .body(params: let params):
            do {
                return try JSONSerialization.data(withJSONObject: params)
            } catch {
                throw RequestBodyContentCreatorErros.jsonParsingFailedForBodyParams
            }
        default: return nil
        }
    }
}
