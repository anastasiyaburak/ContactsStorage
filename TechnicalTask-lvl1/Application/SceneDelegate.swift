import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemBackground
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        let dataManager = UserDataManager()
        let networkManager = UserNetworkManager()
        let userViewModel = UserListViewModel(userDataManager: dataManager, networkManager: networkManager)
        let userListViewController = UserListViewController(viewModel: userViewModel)
        window?.rootViewController = UINavigationController(rootViewController: userListViewController)
        window?.makeKeyAndVisible()
    }
}
