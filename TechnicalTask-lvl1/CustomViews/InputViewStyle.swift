import Foundation

enum InputViewStyle {
    case email(placeholder: String)
    case username(placeholder: String)
    case city(placeholder: String)
    case street(placeholder: String)

    var placeholder: String {
        switch self {
        case .email(let placeholder):
            placeholder
        case .username(let placeholder):
            placeholder
        case .city(let placeholder):
            placeholder
        case .street(let placeholder):
            placeholder
        }
    }

    var labelText: String {
        switch self {
        case .email:
            Localization.AddUser.email
        case .username:
            Localization.AddUser.username
        case .city:
            Localization.AddUser.city
        case .street:
            Localization.AddUser.street
        }
    }
}
