//
//  Logger.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation

enum LogLevel: String {
    case info
    case verbose
    case debug
    case warning
    case error
    
    var symbol: String {
        switch self {
        case .info: return "ℹ️"
        case .verbose: return "💭"
        case .debug: return "👨‍💻"
        case .warning: return "⚠️"
        case .error: return "❗️"
        }
    }
    
    var logTitle: String { rawValue.capitalized }
}

public protocol NetworkDataLogger {
    var shouldLog: Bool { get }
}

extension NetworkDataLogger {
    
    func log<T: API>(_ api: T,
                     level: LogLevel,
                     data: Data?,
                     error: Error?,
                     funcName: String = #function, line: Int = #line) {
        guard shouldLog else { return }
        let logString: String = """
---------------------------------------------------------
Log Level: \(level.symbol + " " + level.logTitle)
Scheme: \(api.scheme)
Method: \(api.method)
Request Headers: \(headerDataToString(api.headers))
Request Parameters: \(requestDataToString(api.requestParameters))
BaseURL: \(api.baseURL)
Endpoint: \(api.endPoint)
SSLEnabled: \(!(api.sslContent == .none))
Response: \(responseData(data) ?? "Empty Response")
Error: \(error?.localizedDescription ?? "Empty Error")
---------------------------------------------------------
"""
        print(logString)
    }
    
    private func headerDataToString(_ headers: HTTPHeader) -> String {
        var stringParameters: String = "["
        for key in headers.keys {
            stringParameters
                .append(
                    key + ":" + (headers[key] ?? "").value
                )
        }
        stringParameters.append("]")
        
        return stringParameters
    }
    
    private func requestDataToString(_ body: HTTPRequestBody) -> String {
        
        var requestString: String?
        switch body {
        case .none: requestString = nil
        case .data(let data): requestString = String(data: data, encoding: .utf8)
        case .body(let params), .url(params: let params):
            var stringParameters: String = "["
            for key in params.keys {
                stringParameters
                    .append(
                        key + ":" + (params[key] ?? "").value
                    )
            }
            stringParameters.append("]")
        }
        return requestString ?? "No Parameters"
    }
    
    private func responseData(_ data: Data?) -> String? {
        guard let data = data,
              let responseString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return responseString
    }
}

