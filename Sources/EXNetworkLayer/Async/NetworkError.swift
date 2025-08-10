import Foundation

public enum NetworkError: Error {
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

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case let (.transport(l), .transport(r)):
            return l == r
        case let (.invalidResponse(l), .invalidResponse(r)):
            return l == r
        case (.decoding, .decoding):
            // Cannot compare Error types directly. For tests, checking the case is sufficient.
            return true
        case (.noData, .noData):
            return true
        case (.timeout, .timeout):
            return true
        case (.cancelled, .cancelled):
            return true
        default:
            return false
        }
    }
}
