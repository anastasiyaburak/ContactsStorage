import Combine
import CoreData

protocol UserDataManaging {
    func fetchUsers() -> AnyPublisher<Users, Error>
    func saveUser(_ user: UserModel) -> AnyPublisher<Void, Error>
    func deleteUser(by email: String) -> AnyPublisher<Void, Error>
}

final class UserDataManager: UserDataManaging {
    private var context: NSManagedObjectContext {
        return CoreDataStack.shared.context
    }

    private var networkManager = UserNetworkManager()
    private var cancellable = Set<AnyCancellable>()

    func fetchUsers() -> AnyPublisher<Users, Error> {
        DebugLogger.shared.debug("fetchUsers")

        let savedUsers = Future<Users, Error> { promise in
            do {
                let users = try self.fetchSavedUsers() ?? []
                promise(.success(users))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()

        let remoteUsers = getUsers()
            .map { response -> Users in
                switch response {
                case .response(let data):
                    return data
                }
            }
            .mapError { error -> Error in
                DebugLogger.shared.error("Failed to fetch remote users: \(error)")
                return error
            }
            .eraseToAnyPublisher()

        return Publishers.CombineLatest(savedUsers, remoteUsers)
            .flatMap { saved, remote in
                self.syncMissingUsers(remoteUsers: remote, savedUsers: saved)
                    .map {
                        let combined = (saved + remote).uniqued(by: \.email)
                        return combined
                    }
            }
            .eraseToAnyPublisher()
    }

    func getUsers() -> AnyPublisher<UploadResponse<[UserModel]>, NetworkError> {
        networkManager.response(UsersApiController.getUsers, receiveOnQueue: .main)
    }

    func fetchSavedUsers() throws -> Users? {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let result = try self.context.fetch(fetchRequest)
            let users = result.map { userEntity -> UserModel in
                return UserModel(username: userEntity.username ?? "Unknown",
                                 email: userEntity.email ?? "Unknown",
                                 address: Address(street: userEntity.street ?? "Unknown",
                                                  city: userEntity.city ?? "Unknown")
                )
            }
            return users
        } catch {
            return nil
        }
    }

    func syncMissingUsers(remoteUsers: Users, savedUsers: Users) -> AnyPublisher<Void, Error> {
        let missingUsers = remoteUsers.filter { remoteUser in
            !savedUsers.contains(where: { $0.email == remoteUser.email })
        }

        guard !missingUsers.isEmpty else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let savePublishers = missingUsers.map { self.saveUser($0) }

        return Publishers.MergeMany(savePublishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func saveUser(_ user: UserModel) -> AnyPublisher<Void, Error> {
        return Future { promise in
            let userEntity = UserEntity(context: self.context)
            userEntity.username = user.username
            userEntity.email = user.email
            userEntity.street = user.address.street
            userEntity.city = user.address.city

            do {
                try self.context.save()
                promise(.success(()))
            } catch {
                DebugLogger.shared.debug("Failed to save user: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteUser(by email: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)

            do {
                if let userToDelete = try self.context.fetch(fetchRequest).first {
                    self.context.delete(userToDelete)
                    try self.context.save()
                    promise(.success(()))
                    DebugLogger.shared.debug("User deleted: \(email)")
                } else {
                    promise(.failure(NSError(domain: "",
                                             code: 404,
                                             userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                }
            } catch {
                DebugLogger.shared.debug("Failed to delete user: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

}
