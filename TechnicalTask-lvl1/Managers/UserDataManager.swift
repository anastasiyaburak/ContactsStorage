import Combine
import CoreData

protocol UserDataManaging {
    func fetchUsers() -> AnyPublisher<[UserModel], Error>
    func saveUser(_ user: UserModel) -> AnyPublisher<Void, Error>
    func deleteUser(by email: String) -> AnyPublisher<Void, Error>
}

final class UserDataManager: UserDataManaging {
    private var context: NSManagedObjectContext {
        return CoreDataStack.shared.context
    }

    func fetchUsers() -> AnyPublisher<[UserModel], Error> {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        return Future { promise in
            do {
                let result = try self.context.fetch(request)
                let users = result.map { userEntity -> UserModel in
                    return UserModel(
                        username: userEntity.username ?? "Unknown",
                        email: userEntity.email ?? "Unknown",
                        address: Address(
                            street: userEntity.street ?? "Unknown",
                            city: userEntity.city ?? "Unknown"
                        )
                    )
                }
                promise(.success(users))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func saveUser(_ user: UserModel) -> AnyPublisher<Void, Error> {
        Future { promise in
            let userEntity = UserEntity(context: self.context)
            userEntity.username = user.username
            userEntity.email = user.email
            userEntity.street = user.address.street
            userEntity.city = user.address.city

            do {
                try self.context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteUser(by email: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "UserDataManager",
                                         code: 0,
                                         userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }

            let context = CoreDataStack.shared.context
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)

            do {
                if let userToDelete = try context.fetch(fetchRequest).first {
                    context.delete(userToDelete)
                    try context.save()
                    promise(.success(()))
                } else {
                    promise(.failure(NSError(domain: "",
                                             code: 404,
                                             userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
