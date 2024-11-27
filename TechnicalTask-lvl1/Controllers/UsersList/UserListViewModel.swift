import Foundation
import Combine

final class UserListViewModel: ObservableObject {
    @Published var data: Users = []

    private var cancellable = Set<AnyCancellable>()
    private let userDataManager: UserDataManaging

    init(userDataManager: UserDataManaging) {
        self.userDataManager = userDataManager
        fetchUsers()
    }

    func fetchUsers() {
        userDataManager.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching users: \(error)")
                }
            }, receiveValue: { [weak self] users in
                self?.data = users
            })
            .store(in: &cancellable)
    }

    func deleteUser(by email: String) {
        userDataManager.deleteUser(by: email)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error deleting user: \(error)")
                }
            }, receiveValue: { [weak self] in
                self?.fetchUsers()
            })
            .store(in: &cancellable)
    }
}
