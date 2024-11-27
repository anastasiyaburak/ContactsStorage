import UIKit
import SnapKit
import Combine

class UserListViewController: UIViewController {
    private let viewModel: UserListViewModel
    private var cancellable = Set<AnyCancellable>()

    private lazy var addBarItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                  target: self,
                                                  action: #selector(addButtonWasPressed))

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(cellClasses: UserCell.self)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    private var internetBanner: UILabel = {
        let banner = UILabel()
        banner.text = "No Internet Connection. You are in offline mode."
        banner.backgroundColor = .red
        banner.textColor = .white
        banner.textAlignment = .center
        banner.isHidden = true
        return banner
    }()

    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchUsersList()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = Localization.UserList.title
        navigationItem.rightBarButtonItem = addBarItem

        view.addSubview(tableView)
        tableView.addSubview(refreshControl)

        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.left.right.equalToSuperview()
        }

        view.addSubview(internetBanner)
        internetBanner.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 40)
    }

    private func setupViewModel() {
        viewModel.$data
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
    }

    @objc private func addButtonWasPressed() {
        let dataManager = UserDataManager()
        let viewModel = AddUserViewModel(userDataManager: dataManager)
        let controller = AddUserViewController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func refreshData() {
        viewModel.fetchUsersList()
        refreshControl.endRefreshing()
    }
}

extension UserListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UserCell = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }

        let user = viewModel.data[indexPath.row]
        cell.setupUI(for: user)

        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = viewModel.data[indexPath.row]

        let deleteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }

            self.viewModel.deleteUser(by: user.email)
            tableView.performBatchUpdates {
                self.viewModel.data.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completionHandler(true)
        }

        deleteAction.image = Asset.Images.bin.image
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}
