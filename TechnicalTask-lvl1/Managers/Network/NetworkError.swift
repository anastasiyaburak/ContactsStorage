import Foundation

public enum NetworkError: Error, LocalizedError {
    case invalidResponse(URLResponse?)
    case noDataReceived
    case invalidData
    case noConnection
    case invalidRequest(Error)
    case timeout
    case parseError
    case unknown(Error)
    case emptyURL

    public var errorDescription: String? {
        switch self {
        case .emptyURL:
            return "URL is empty"
        case .invalidResponse:
            return "Invalid response from server)"
        case .noDataReceived:
            return "No data received from the server"
        case .invalidData:
            return "Invalid data received"
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .unknown:
            return "Unknown error occurred"
        case .invalidRequest:
            return "Something wrong with our request, we will fix it "
        case .parseError:
            return "Data was not parsed in correct way !"
        }
    }
}
