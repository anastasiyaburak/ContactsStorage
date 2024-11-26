import UIKit
import SnapKit

class AddUserViewController: UIViewController {

    private var activeTextField: InputView?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.text = "Provide all info to save user:"
        return label
    }()

    private lazy var usernameInputView: InputView = {
        let view = InputView()
        view.configure(with: .username(placeholder: "Username"))
        view.delegate = self
        return view
    }()

    private lazy var emailInputView: InputView = {
        let view = InputView()
        view.configure(with: .email(placeholder: "Email"))
        view.delegate = self
        return view
    }()

    private lazy var cityInputView: InputView = {
        let view = InputView()
        view.configure(with: .city(placeholder: "City"))
        view.delegate = self
        return view
    }()

    private lazy var streetInputView: InputView = {
        let view = InputView()
        view.configure(with: .street(placeholder: "Street"))
        view.delegate = self
        return view
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 25
        button.backgroundColor = .black
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(saveButtonWasPressed), for: .touchUpInside)

        return button
    }()

    private lazy var userInfoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [usernameInputView, emailInputView,
                                                       cityInputView, streetInputView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureScreen()
        initialiseHideKeyboard()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func configureScreen() {
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        navigationItem.title = "User info"
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        view.addSubview(userInfoStack)
        userInfoStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }

    @objc private func saveButtonWasPressed() {
        if usernameInputView.hasText, emailInputView.hasText,
           cityInputView.hasText, streetInputView.hasText,
           emailInputView.validateText() {
            print("Save")
        } else {
            print("show alert")
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {

      guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                as? NSValue)?.cgRectValue
        else { return }

      var shouldMoveViewUp = false

      if let activeTextField = activeTextField {
        let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY
        let topOfKeyboard = self.view.frame.height - keyboardSize.height
        if bottomOfTextField > topOfKeyboard {
          shouldMoveViewUp = true
        }
      }

      if shouldMoveViewUp {
          UIView.animate(withDuration: 0.3) { [weak self] in
              self?.view.frame.origin.y = 0 - keyboardSize.height
          }
      }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.frame.origin.y = 0
        }
    }
}

extension AddUserViewController: InputViewDelegate {

    func becomeFirstResponder(_ inputView: InputView) {
        activeTextField = inputView
    }

    func continueButtonPressed(_ inputView: InputView) {
        if inputView == emailInputView, !inputView.validateText() {
            print("Not valid email")
        }
        view.endEditing(true)
    }

    func initialiseHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(swipe)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func endEditingTextField(_ inputView: InputView) {
        activeTextField = nil
    }
}
