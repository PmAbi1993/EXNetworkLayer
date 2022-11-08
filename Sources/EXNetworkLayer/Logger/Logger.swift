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
    func log(level: LogLevel, messge: String, funcName: String = #function, line: Int = #line) {
        guard shouldLog else { return }
        let logData: String = """
---------------------------------------------------------
Log Level: \(level.symbol + level.logTitle)
Function Name: \(funcName)
line: \(line)
Message:- \(messge)
---------------------------------------------------------
"""
        print(logData)
    }
}
