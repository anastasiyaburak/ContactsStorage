import UIKit
import SnapKit
import Combine

final class AddUserViewController: UIViewController {

    private var activeTextField: InputView?
    private var cancellable: Set<AnyCancellable> = []

    private let viewModel: AddUserViewModel

    private lazy var provideInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.text = Localization.AddUser.provideInfo
        return label
    }()

    private lazy var usernameInputView: InputView = {
        let view = InputView()
        view.configure(with: .username(placeholder: Localization.Placeholder.username))
        view.delegate = self
        return view
    }()

    private lazy var emailInputView: InputView = {
        let view = InputView()
        view.configure(with: .email(placeholder: Localization.Placeholder.email))
        view.delegate = self
        return view
    }()

    private lazy var cityInputView: InputView = {
        let view = InputView()
        view.configure(with: .city(placeholder: Localization.Placeholder.city))
        view.delegate = self
        return view
    }()

    private lazy var streetInputView: InputView = {
        let view = InputView()
        view.configure(with: .street(placeholder: Localization.Placeholder.street))
        view.delegate = self
        return view
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 25
        button.backgroundColor = .black
        button.setTitle(Localization.Button.save, for: .normal)
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

    init(viewModel: AddUserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureScreen()
        setNotifications()
        initialiseHideKeyboard()
        observeViewModel()
    }

    private func configureScreen() {
        view.backgroundColor = .white
        navigationItem.title = Localization.AddUser.title

        view.addSubview(provideInfoLabel)
        provideInfoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }

        view.addSubview(userInfoStack)
        userInfoStack.snp.makeConstraints {
            $0.top.equalTo(provideInfoLabel.snp.bottom)
            $0.left.right.equalToSuperview()
        }

        view.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }

    private func setNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func observeViewModel() {
        viewModel.$userSaved
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userSaved in
                guard let self = self else { return }
                if userSaved {
                    print("User saved successfully!")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Error saving user.")
                }
            }
            .store(in: &cancellable)
    }

    @objc private func saveButtonWasPressed() {
        if usernameInputView.hasText, emailInputView.hasText,
           cityInputView.hasText, streetInputView.hasText,
           emailInputView.validateText() {
            let user = UserModel(username: usernameInputView.text ?? "",
                                 email: emailInputView.text ?? "",
                                 address: Address(street: streetInputView.text ?? "",
                                                  city: cityInputView.text ?? ""))
            viewModel.saveUser(user)
        } else {
            print("Please fill in all fields correctly.")
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func initialiseHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                  as? NSValue)?.cgRectValue else { return }

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

    func endEditingTextField(_ inputView: InputView) {
        activeTextField = nil
    }
}
