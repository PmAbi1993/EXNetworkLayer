//
//  EXCodableCacher 2.swift
//  
//
//  Created by Abhijith Pm on 09/11/22.
//

import Foundation

// MARK: Functions to Create, Read cache saved to disk
extension EXCodableCacher {
    
    func saveCacheToDisk<T: Codable>(key: String, data: T) {
        guard let url = getFileURL(for: key) else {
            return
        }
        // Check if file exist at path
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print(error.localizedDescription)
            }
        }
        do {
            let encodedData = try encoder.encode(data)
            try encodedData.write(to: url, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getCacheDataFromDisk<T: Codable>(key: String, as type: T.Type) -> T? {
        do {
            guard let fileURL = getFileURL(for: key) else {
                return nil
            }
            let fileData = try NSData(contentsOfFile: fileURL.path) as Data
            return try decoder.decode(type, from: fileData)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
