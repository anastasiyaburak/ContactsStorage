import UIKit

enum InputViewState {
    case emptyFieldError
    case waiting
    case editing

    var borderColor: UIColor {
        switch self {
        case .emptyFieldError:
            return .systemRed
        case .editing:
            return .white
        case .waiting:
            return .lightGray
        }
    }

    var textColor: UIColor {
        switch self {
        case .emptyFieldError:
            return .systemRed
        case .editing:
            return .white
        case .waiting:
            return .lightGray
        }
    }
}

extension InputViewState: Equatable {
    public static func == (lhs: InputViewState, rhs: InputViewState) -> Bool {
        switch (lhs, rhs) {
        case (.emptyFieldError, .emptyFieldError):
            return true
        case (.waiting, .waiting):
            return true
        case (.editing, .editing):
            return true
        default:
            return false
        }
    }
}
