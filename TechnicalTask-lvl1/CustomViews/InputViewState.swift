import UIKit

enum InputViewState {
    case emptyFieldError
    case waiting
    case editing

    var borderColor: UIColor {
        switch self {
        case .emptyFieldError:
                .systemRed
        case .editing:
                .white
        case .waiting:
                .lightGray
        }
    }

    var textColor: UIColor {
        switch self {
        case .emptyFieldError:
                .systemRed
        case .editing:
                .white
        case .waiting:
                .lightGray
        }
    }
}

extension InputViewState: Equatable {
    public static func == (lhs: InputViewState, rhs: InputViewState) -> Bool {
        switch (lhs, rhs) {
        case (.emptyFieldError, .emptyFieldError):
            true
        case (.waiting, .waiting):
            true
        case (.editing, .editing):
            true
        default:
            false
        }
    }
}
