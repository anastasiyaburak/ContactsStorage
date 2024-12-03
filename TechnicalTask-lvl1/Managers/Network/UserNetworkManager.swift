import Foundation
import Combine

protocol APIClientProtocol {
    func response<T: Codable>(_ controller: ApiController,
                              receiveOnQueue: OperationQueue) -> AnyPublisher<UploadResponse<T>, NetworkError>
}

enum UploadResponse<T: Decodable> {
    case response(data: T)
}

final class UserNetworkManager: APIClientProtocol {
    enum HTTPMethod: String {
        case GET
    }

    func response<DataType: Codable>(_ controller: ApiController,
                                     receiveOnQueue: OperationQueue = .main
    ) -> AnyPublisher<UploadResponse<DataType>, NetworkError> {
        self.request(controller, receiveOnQueue: receiveOnQueue)
    }

    private func request<DataType: Codable>(_ controller: ApiController,
                                            receiveOnQueue: OperationQueue = .main
    ) -> AnyPublisher<UploadResponse<DataType>, NetworkError> {
        guard let url = controller.url
        else {
            return Fail(error: NetworkError.emptyURL).eraseToAnyPublisher()
        }

        let request = createRequest(with: url, type: controller.method)
        let subject: PassthroughSubject<UploadResponse<DataType>, NetworkError> = .init()

        URLSession.shared.dataTask(
            with: request,
            completionHandler: { [weak self] data, _, error in
                guard let self else { return }

                guard let data else {
                    if let error {
                        subject.send(completion: .failure(self.parseError(error)))
                    } else {
                        subject.send(completion: .failure(NetworkError.noDataReceived))
                    }

                    return
                }

                do {
                    let result = try JSONDecoder().decode(DataType.self, from: data)
                    subject.send(.response(data: result))
                } catch {
                    subject.send(completion: .failure(.invalidData))
                }
        }).resume()

        return subject
            .receive(on: receiveOnQueue)
            .eraseToAnyPublisher()
    }

    private func parseError(_ error: Error) -> NetworkError {
        switch (error as NSError).code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorCannotConnectToHost:
             .noConnection
        case NSURLErrorTimedOut:
             .timeout
        case NSURLErrorBadURL:
             .invalidRequest(error)
        default:
             .unknown(error)
        }
    }

    private func createRequest(with url: URL,
                               type: HTTPMethod,
                               timeOutInterval: TimeInterval = 30) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.timeoutInterval = timeOutInterval
        return request
    }
}
