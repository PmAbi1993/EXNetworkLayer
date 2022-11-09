//
//  EXNetworkManager+Cache.swift
//  
//
//  Created by Abhijith Pm on 09/11/22.
//

import Foundation

// MARK: Cached Network calls
extension EXNetworkManager {
    
    public func callApi<U: Codable>(responseType: U.Type,
                                    cacheKey: String,
                                    cachedResponse: U,
                                    result completion: @escaping NetworkResponse<U>) {
        self.callApi(responseType: responseType) { result in
            if case let .success(encodedData) = result {
                let cacher = EXCodableCacher(cacheType: self.requestCacheType)
                cacher.saveResponseToCache(key: cacheKey, data: encodedData)
            }
            completion(result)
        }
        
    }
    
    public func callApi<U: Decodable>(responseType: [U].Type,
                                      cacheKey: String,
                                      cachedResponse: U,
                                      result completion: @escaping NetworkResponse<[U]>) {
        self.callApi(responseType: responseType) { result in
            if case let .success(encodedData) = result {
                let cacher = EXCodableCacher(cacheType: self.requestCacheType)
                cacher.saveResponseToCache(key: cacheKey, data: encodedData)
            }
        }
    }
}
