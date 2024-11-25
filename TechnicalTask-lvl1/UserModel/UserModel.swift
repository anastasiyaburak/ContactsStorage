import Foundation

typealias Users = [UserModel]

// MARK: - UserModel
struct UserModel: Codable {
    let id: Int
    let username, email: String
    let address: Address
}

// MARK: - Address
struct Address: Codable {
    let street, city: String
}
