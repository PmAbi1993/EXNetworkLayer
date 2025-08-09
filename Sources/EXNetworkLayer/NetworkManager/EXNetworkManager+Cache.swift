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
                                    result completion: @escaping NetworkResponse<U>) {
        let cacher = EXCodableCacher(cacheType: self.requestCacheType)
        if let cached: U = cacher.getResponseFromCache(key: cacheKey, type: responseType) {
            DispatchQueue.main.async {
                completion(.success(cached))
            }
            return
        }
        // Cache miss: perform network call and store result
        self.callApi(responseType: responseType) { result in
            if case let .success(encodedData) = result {
                let cacher = EXCodableCacher(cacheType: self.requestCacheType)
                cacher.saveResponseToCache(key: cacheKey, data: encodedData)
            }
            completion(result)
        }
    }
}
