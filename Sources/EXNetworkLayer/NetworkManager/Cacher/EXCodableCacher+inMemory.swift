//
//  EXCodableCacher+inMemory.swift
//  
//
//  Created by Abhijith Pm on 09/11/22.
//

import Foundation

// MARK: Functions to save and retreive data into memory
extension EXCodableCacher {
    
    func saveCacheToMemory<T: Codable>(key: String, data: T) {
        do {
            let encodedData: Data = try JSONEncoder().encode(data)
            EXCodableCacher
                .shared
                .inMemoryCache.setObject(encodedData as NSData,
                                         forKey: NSString(string: key)
                )
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getCacheFromMemory<T: Codable>(key: String, as type: T.Type) -> T? {
        do {
            guard let data = EXCodableCacher
                .shared.inMemoryCache.object(forKey: NSString(string: key)) else {
                return nil
            }
            let decodedData: T = try decoder.decode(type, from: data as Data)
            return decodedData
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
