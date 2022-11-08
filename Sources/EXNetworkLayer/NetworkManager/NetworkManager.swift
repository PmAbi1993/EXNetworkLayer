//
//  NetworkManager.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation

public enum BasicRequestError: Error {
    case requestCreationFailed(RequestCreatorErrors)
    case noDataPresentInApi(_ errorFromApi: Error?)
    case parsingfailed
    case generalError
}

public typealias NetworkResponse<U: Codable> = (Result<U, BasicRequestError>) -> Void

public protocol BasicRequest {
    var api: API { get }
    var session: URLSession { get }
    var decoder: JSONDecoder { get }
    var requestProvider: RequestProvider { get }
}

extension BasicRequest {
    public func callApi<U: Decodable>(responseType: U.Type, completion: @escaping NetworkResponse<U>) {
        
        // MARK: Get the request
        // TODO: Move all this to `try catch block`
        guard let request: URLRequest = try?  requestProvider.request() else {
            completion(.failure(.generalError))
            return
        }
        // MARK: Call the api
        session.dataTask(with: request) { data, response, error in
            
            guard let data = data else {
                completion(.failure(.noDataPresentInApi(error)))
                return
            }
            
            // MARK: Decoding the response
            guard let responseData = try? decoder.decode(responseType, from: data) else {
                completion(.failure(.parsingfailed))
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(responseData))
            }
        }.resume()
    }
}
