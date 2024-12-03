import Foundation

protocol ApiController {
    var url: URL? { get }
    var path: String { get }
    var query: String { get }
    var method: UserNetworkManager.HTTPMethod { get }
}

enum UsersApiController {
    case getUsers
}

extension UsersApiController: ApiController {
    var url: URL? {
        URL(string: path + query)
    }

    var path: String {
        switch self {
        case .getUsers:
             "https://jsonplaceholder.typicode.com/"
        }
    }

    var query: String {
        switch self {
        case .getUsers:
             "users"
        }
    }

    var method: UserNetworkManager.HTTPMethod {
        switch self {
        case .getUsers:
             .GET
        }
    }
}
