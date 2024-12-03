import UIKit

class UserCell: UITableViewCell {

    private lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.Images.contactsIcon.image
        return imageView
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private lazy var infoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [usernameLabel, emailLabel, addressLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureScreen()
    }

    private func configureScreen() {
        self.backgroundColor = .clear

        self.contentView.addSubview(self.userImage)
        self.contentView.addSubview(self.infoStack)
        userImage.snp.makeConstraints {
            $0.left.equalToSuperview().inset(20)
            $0.top.height.equalToSuperview().inset(10)
            $0.width.equalTo(userImage.snp.height)
        }

        infoStack.snp.makeConstraints {
            $0.left.equalTo(userImage.snp.right).offset(10)
            $0.top.bottom.equalToSuperview().inset(20)
            $0.right.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI(for user: UserModel) {
        usernameLabel.text = user.username
        emailLabel.text = user.email
        addressLabel.text = "\(user.address.street), \(user.address.city)"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        emailLabel.text = nil
        addressLabel.text = nil
    }
}
