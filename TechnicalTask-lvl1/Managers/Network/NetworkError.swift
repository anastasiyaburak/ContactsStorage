import Foundation

 enum NetworkError: Error, LocalizedError {
    case invalidResponse(URLResponse?)
    case noDataReceived
    case invalidData
    case noConnection
    case invalidRequest(Error)
    case timeout
    case parseError
    case unknown(Error)
    case emptyURL

     var errorDescription: String {
        switch self {
        case .emptyURL:
             "URL is empty"
        case .invalidResponse:
             "Invalid response from server)"
        case .noDataReceived:
             "No data received from the server"
        case .invalidData:
             "Invalid data received"
        case .noConnection:
             "No internet connection"
        case .timeout:
             "Request timed out"
        case .unknown:
             "Unknown error occurred"
        case .invalidRequest:
             "Something wrong with our request, we will fix it "
        case .parseError:
             "Data was not parsed in correct way !"
        }
    }
}
