import UIKit
import Combine
import SnapKit

class InputView: UIView {
    enum Constants {
        static let labelHeight: CGFloat = 40
        static let textFieldInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }

    @Published var text: String?
    @Published var state: InputViewState = .waiting
    let didBeginEditing = PassthroughSubject<UITextField, Never>()
    var textChanged = PassthroughSubject<String?, Never>()
    var validationState = PassthroughSubject<Bool, Never>()

    private(set) var style: InputViewStyle!

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()

    lazy var textField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.isUserInteractionEnabled = true
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textColor = .black
        textField.layer.cornerRadius = 20
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.delegate = self
        return textField
    }()

    func configure(
        with style: InputViewStyle,
        startValue: String = "",
        placeholder: String? = nil,
        returnType: UIReturnKeyType = .default
    ) {
        self.addSubviews()
        self.applyStyle(style, startValue: startValue, placeholder: placeholder, returnType: returnType)
    }

    private func applyStyle(
        _ style: InputViewStyle,
        startValue: String,
        placeholder: String?,
        returnType: UIReturnKeyType
    ) {
        self.style = style
        let mainPlaceholder = placeholder ?? style.placeholder
        textField.attributedPlaceholder = NSAttributedString(string: mainPlaceholder,
                                                             attributes: [.foregroundColor: UIColor.gray])
        textField.text = startValue
        textField.returnKeyType = returnType
        textField.autocorrectionType = .no
        switch style {
        case .email:
            textField.keyboardType = .emailAddress
            textField.textContentType = .emailAddress
        default:
            textField.keyboardType = .default
            state = .waiting
        }
        setLabelText(style: style)
    }

    private func setLabelText(style: InputViewStyle) {
        label.text = style.labelText
    }

    private func addSubviews() {
        self.addSubview(label)
        label.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(Constants.labelHeight)
            $0.left.equalToSuperview().inset(Constants.textFieldInsets.left)
        }

        self.addSubview(textField)
        textField.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constants.textFieldInsets.left)
            $0.top.equalTo(label.snp.bottom)
            $0.bottom.equalToSuperview().inset(Constants.textFieldInsets.bottom)
        }
    }

    @objc private func textFieldDidChange() {
        text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        textChanged.send(text)
        validateText()
    }

    @discardableResult
    func validateText() -> Bool {
        guard let text = text else { return false }
        let isValid: Bool
        switch style {
        case .email:
            isValid = text.checkEmailRegularExpression()
        case .username, .city, .street:
            isValid = !text.isEmpty
        case .none:
            isValid = false
        }
        validationState.send(isValid)
        state = isValid ? .waiting : .emptyFieldError
        textField.layer.borderColor = isValid ? UIColor.black.cgColor : UIColor.red.cgColor
        return isValid
    }
}

extension InputView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        state = .waiting
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        state = .editing
        didBeginEditing.send(textField)
    }
}
