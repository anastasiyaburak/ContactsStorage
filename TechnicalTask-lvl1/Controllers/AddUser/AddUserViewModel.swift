import Foundation
import Combine

protocol AddUserViewModeling: AnyObject {
    var userSaved: AnyPublisher<Bool, Never> { get }
    var errorMessage: AnyPublisher<String?, Never> { get }
    func saveUser(_ user: UserModel)
}

final class AddUserViewModel: AddUserViewModeling {
    @Published private var _userSaved: Bool = false
    @Published private var _errorMessage: String?

    private var cancellable = Set<AnyCancellable>()
    private let userDataManager: UserDataManaging

    init(userDataManager: UserDataManaging) {
        self.userDataManager = userDataManager
    }

    var userSaved: AnyPublisher<Bool, Never> {
        $_userSaved.eraseToAnyPublisher()
    }

    var errorMessage: AnyPublisher<String?, Never> {
        $_errorMessage.eraseToAnyPublisher()
    }

    func saveUser(_ user: UserModel) {
        userDataManager.saveUser(user)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case let .failure(error as NSError) = completion {
                    DebugLogger.shared.debug("Error saving user: \(error)")
                    self._userSaved = false
                    self._errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] in
                self?._userSaved = true
                self?._errorMessage = nil
            })
            .store(in: &cancellable)
    }
}
