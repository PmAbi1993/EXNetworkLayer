//
//  RequestCacher.swift
//  
//
//  Created by Abhijith Pm on 09/11/22.
//

import Foundation

public enum RequestCacheType {
    case inMemory
    case inDisk
}

public class EXCodableCacher {
    
    static let shared: EXCodableCacher = EXCodableCacher()
    
    var fileManager: FileManager
    var cacheType: RequestCacheType
    var encoder: JSONEncoder
    var decoder: JSONDecoder
    var inMemoryCache: NSCache<NSString, NSData> = NSCache<NSString, NSData>()
    
    public init(fileManager: FileManager = .default,
                cacheType: RequestCacheType = .inMemory,
                encoder: JSONEncoder = JSONEncoder(),
                decoder: JSONDecoder = JSONDecoder()) {
        self.fileManager = .default
        self.cacheType = cacheType
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func getFileURL(for cacheName: String) -> URL? {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: true)
            return documentDirectory
                .appendingPathComponent(cacheName)
                .appendingPathExtension("json")
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

// MARK: Functions to save and Get from Cache
extension EXCodableCacher {
    public func saveResponseToCache<T: Codable>(key: String, data: T) {
        switch self.cacheType {
        case .inMemory:
            saveCacheToMemory(key: key, data: data)
        case .inDisk:
            saveCacheToDisk(key: key, data: data)
        }
    }
    
    public func getResponseFromCache<T: Codable>(key: String, type: T.Type) -> T? {
        switch self.cacheType {
        case .inMemory:
            return getCacheFromMemory(key: key, as: type)
        case .inDisk:
            return getCacheDataFromDisk(key: key, as: type)
        }
    }
}
