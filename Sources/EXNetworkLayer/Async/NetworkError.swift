import Foundation

public enum NetworkError: Error, Equatable {
    case transport(URLError)
    case invalidResponse(statusCode: Int)
    case decoding(Error)
    case noData
    case timeout
    case cancelled
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .transport(let urlError): return urlError.localizedDescription
        case .invalidResponse(let code): return "Invalid response with status code: \(code)"
        case .decoding(let error): return "Decoding failed: \(error.localizedDescription)"
        case .noData: return "No data received"
        case .timeout: return "Request timed out"
        case .cancelled: return "Cancelled"
        }
    }
}

