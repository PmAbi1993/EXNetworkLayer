//
//  NetworkManager.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum BasicRequestError: Error {
    case requestCreationFailed(RequestCreatorErrors)
    case noDataPresentInApi(_ errorFromApi: Error?)
    case apiResponseError(error: Error)
    case parsingfailed
    case generalError
}

public typealias NetworkResponse<U: Codable> = (Result<U, BasicRequestError>) -> Void

public protocol BasicRequest {
    var api: API { get }
    var session: HTTPClient { get set }
    var decoder: JSONDecoder { get }
    var requestProvider: RequestProvider { get }
}

// MARK: Execute request with Single object as response
extension BasicRequest {
    public func callApi<U: Codable>(responseType: U.Type, completion: @escaping NetworkResponse<U>) {
        
        // MARK: Get the request
        // TODO: Move all this to `try catch block`
        guard let request: URLRequest = try?  requestProvider.request() else {
            completion(.failure(.generalError))
            return
        }
        // MARK: Call the api
        session.httpDataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.apiResponseError(error: error)))
                return
            }
            guard let data = data else {
                completion(.failure(.noDataPresentInApi(error)))
                return
            }
            if self.api.shouldLog {
                self.api.log(self.api,
                             level: error == nil ? .debug : .error,
                             data: data,
                             error: error)
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

// MARK: Execute request with Array of objects as response
extension BasicRequest {
    public func callApi<U: Codable>(responseType: [U].Type, completion: @escaping NetworkResponse<[U]>) {
        
        guard let request: URLRequest = try?  requestProvider.request() else {
            completion(.failure(.generalError))
            return
        }
        
        session.httpDataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.apiResponseError(error: error)))
                return
            }
            guard let data = data else {
                completion(.failure(.noDataPresentInApi(error)))
                return
            }
            // Logging if the data is present
            if self.api.shouldLog {
                self.api.log(self.api,
                             level: error == nil ? .debug : .error,
                             data: data,
                             error: error)
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
