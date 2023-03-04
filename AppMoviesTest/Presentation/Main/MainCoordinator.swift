import UIKit

final class MainCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var tabBarController: UITabBarController

    var childCoordinators: [Coordinator] = []
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }
    
    func start() {
        showMainViewController()
    }
    
    private func showMainViewController() {
        
        let mainRouting = MainViewModelRouting()
        let mainViewModel = MainViewModelImpl(routing: mainRouting)
        let mainViewController = MainViewController()
        let mainNavController = UINavigationController(rootViewController: mainViewController)
        mainViewController.viewModel = mainViewModel

        let favoritesRouting = FavoritesViewModelRouting()
        let favoritesViewModel = FavoritesViewModelImpl(routing: favoritesRouting)
        let favoritesViewController = FavoritesViewController()
        let favoritesNavController = UINavigationController(rootViewController: favoritesViewController)
        favoritesViewController.viewModel = favoritesViewModel

        let settingsRouting = SettingsViewModelRouting()
        let settingsViewModel = SettingsViewModelImpl(routing: settingsRouting)
        let settingsViewController = SettingsViewController()
        let settingsNavController = UINavigationController(rootViewController: settingsViewController)
        settingsViewController.viewModel = settingsViewModel
        
        [mainNavController, favoritesNavController, settingsNavController]
            .forEach { $0.navigationBar.prefersLargeTitles = true;
                       $0.navigationItem.largeTitleDisplayMode = .automatic
            }
        
        mainNavController.tabBarItem = UITabBarItem(title: "Main", image: UIImage(systemName: "mail.fill"), tag: 1)
        favoritesNavController.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "filemenu.and.selection"), tag: 2)
        settingsNavController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 3)

        tabBarController.viewControllers = [mainNavController, favoritesNavController, settingsNavController]
    }
    
}
