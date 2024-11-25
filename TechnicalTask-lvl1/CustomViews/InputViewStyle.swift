import Foundation

enum InputViewStyle {
    case email(placeholder: String)
    case username(placeholder: String)
    case city(placeholder: String)
    case street(placeholder: String)

    var placeholder: String {
        switch self {
        case .email(let placeholder):
            return placeholder
        case .username(let placeholder):
            return placeholder
        case .city(let placeholder):
            return placeholder
        case .street(let placeholder):
            return placeholder
        }
    }

    var labelText: String {
        switch self {
        case .email:
            return "User Email:"
        case .username:
            return "User Name:"
        case .city:
            return "City:"
        case .street:
            return "Street:"
        }
    }
}
