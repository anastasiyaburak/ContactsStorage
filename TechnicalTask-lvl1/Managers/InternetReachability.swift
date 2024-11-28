import Foundation
import Network
import Logging
import Combine

protocol Reachability {
    var isInternetConnected: Bool { get }
    var isConnectedSubject: CurrentValueSubject<Bool, Never> { get }
}

final class InternetReachability: Reachability {

    static let shared = InternetReachability()
    private var monitor: NWPathMonitor

    private(set) var isInternetConnected: Bool = false
    private(set) var isConnectedSubject = CurrentValueSubject<Bool, Never>(false)

    private init() {
        monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue.global(qos: .background))

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.isInternetConnected = (path.status == .satisfied)
            self.isConnectedSubject.send(self.isInternetConnected)
            DebugLogger.shared.debug("Network status: \(self.isInternetConnected ? "Connected": "Disconnected")")
        }
    }
}
