import Foundation
import Combine

final class AddUserViewModel {

    @Published var userSaved: Bool = false
    private var cancellable = Set<AnyCancellable>()
    private let userDataManager: UserDataManaging

    init(userDataManager: UserDataManaging) {
        self.userDataManager = userDataManager
    }

    func saveUser(_ user: UserModel) {
        userDataManager.saveUser(user)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error saving user: \(error)")
                    self.userSaved = false
                }
            }, receiveValue: { [weak self] in
                self?.userSaved = true
            })
            .store(in: &cancellable)
    }
}
