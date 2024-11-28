import Foundation
import Combine

final class UserListViewModel: ObservableObject {
    @Published var data: Users = []
    @Published var isConnected = false

    private var cancellable = Set<AnyCancellable>()
    private let userDataManager: UserDataManaging

    private let networkManager = UserNetworkManager()

    init(userDataManager: UserDataManaging) {
        self.userDataManager = userDataManager

        InternetReachability.shared.isConnectedSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isConnected = connected
                if connected {
                    self?.fetchUsersList()
                }
            }
            .store(in: &cancellable)
    }

    func deleteUser(by email: String) {
        userDataManager.deleteUser(by: email)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    DebugLogger.shared.debug("Error deleting user: \(error)")
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                self.data.removeAll { $0.email == email }
            }).store(in: &cancellable)
    }

    func fetchUsersList() {
        userDataManager.fetchUsers()
            .map { users in
                users.sorted { $0.username.localizedCaseInsensitiveCompare($1.username) == .orderedAscending }
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    DebugLogger.shared.debug("Error: \(error)")
                }
            }, receiveValue: { [weak self] users in
                self?.data = users
            }).store(in: &cancellable)
    }
}
