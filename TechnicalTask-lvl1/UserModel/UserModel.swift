import Foundation

typealias Users = [UserModel]

// MARK: - UserModel
struct UserModel: Codable {
    let username: String
    let email: String
    let address: Address
}

// MARK: - Address
struct Address: Codable {
    let street, city: String
}
