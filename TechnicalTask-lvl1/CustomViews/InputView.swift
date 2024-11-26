import UIKit
import SnapKit

@objc protocol InputViewDelegate: AnyObject {
    @objc optional func becomeFirstResponder(_ inputView: InputView)
    @objc optional func continueButtonPressed(_ inputView: InputView)
    @objc optional func validationResult(_ inputView: InputView, result: Bool)
    @objc optional func changeText(_ inputView: InputView, text: String)
    @objc optional func endEditingTextField(_ inputView: InputView)
}

class InputView: UIView {
    enum Constants {
        static let labelHeight: CGFloat = 40
        static let textFieldInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }

    override public var isFirstResponder: Bool { textField.isFirstResponder }
    override public var isFocused: Bool { textField.isFocused }
    var text: String? { textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) }
    var hasText: Bool { textField.text?.isEmpty ?? false }
    private(set) var style: InputViewStyle!
    weak var delegate: InputViewDelegate?
    var state: InputViewState = .waiting
    private(set) var inputTextColor: UIColor = .clear

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
        self.textField.backgroundColor = .clear
        self.textField.tintColor = .black
        self.addSubviews()
        self.applyStyle(
            style,
            startValue: startValue,
            customPlaceholder: placeholder,
            returnType: returnType)
    }

    func applyStyle(
        _ style: InputViewStyle,
        startValue: String,
        customPlaceholder: String?,
        returnType: UIReturnKeyType
    ) {
        self.style = style
        let mainPlaceholder = customPlaceholder ?? style.placeholder
        textField.attributedPlaceholder = NSAttributedString(string: mainPlaceholder,
                                                             attributes: [.foregroundColor: UIColor(ciColor: .gray)])
        textField.text = startValue
        textField.returnKeyType = returnType
        textField.autocorrectionType = .no
        switch style {
        case .email:
            textField.keyboardType = .emailAddress
            textField.textContentType = .emailAddress
        default:
            textField.keyboardType = .default
            self.setState(.waiting)
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
        self.setState(.editing)
    }

    public func makeFirstResponder() {
        self.textField.becomeFirstResponder()
    }

    public func setState(_ newState: InputViewState) {
        guard self.state != newState else { return }
        self.state = newState
        switch state {
        case .emptyFieldError:
            textField.layer.borderColor = UIColor.red.cgColor
        case .waiting, .editing:
            textField.layer.borderColor = UIColor.black.cgColor
        }
    }

    @discardableResult
    public func validateText(_ text: String? = nil) -> Bool {
        let text = text ?? (textField.text ?? "")
        var result: Bool
        switch self.style {
        case .email:
            result = text.checkEmailRegularExpression()
        case .username, .city, .street:
            result = true
        case .none:
            result = false
        }

        if result == false {
            self.setState(.emptyFieldError)
        } else {
            if self.isFirstResponder {
                self.setState(.editing)
            } else {
                self.setState(.waiting)
            }
        }
        delegate?.validationResult?(self, result: result)
        return result
    }

    func startEditing(_ inputView: InputView) {
        delegate?.becomeFirstResponder?(self)
        switch self.state {
        case .editing:
            break
        case .emptyFieldError:
            break
        case .waiting:
            self.setState(.editing)
        }
    }

    func endEditing() {
        delegate?.endEditingTextField?(self)
        switch self.state {
        case .editing:
            self.setState(.waiting)
        case .emptyFieldError:
            break
        case .waiting:
            break
        }
    }
}

extension InputView: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.endEditing()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.startEditing(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.continueButtonPressed?(self)
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

}
