import UIKit
import Combine

class AppCoordinator {
    private let window: UIWindow
    private var cancellables = Set<AnyCancellable>()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let tabBarController = UITabBarController()
        
        // Create view controllers for each tab
        let dashboardVC = createDashboardViewController()
        let journalVC = createJournalViewController()
        let reportsVC = createReportsViewController()
        let goalsVC = createGoalsViewController()
        let settingsVC = createSettingsViewController()
        
        // Configure tab bar items
        dashboardVC.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "house"), tag: 0)
        journalVC.tabBarItem = UITabBarItem(title: "Journal", image: UIImage(systemName: "book"), tag: 1)
        reportsVC.tabBarItem = UITabBarItem(title: "Reports", image: UIImage(systemName: "chart.bar"), tag: 2)
        goalsVC.tabBarItem = UITabBarItem(title: "Goals", image: UIImage(systemName: "target"), tag: 3)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 4)
        
        // Set the view controllers for the tab bar controller
        tabBarController.viewControllers = [dashboardVC, journalVC, reportsVC, goalsVC, settingsVC]
        
        // Set the tab bar controller as the root view controller
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    // MARK: - Tab View Controllers
    
    private func createDashboardViewController() -> UIViewController {
        let viewController = UIViewController()
        let label = UILabel()
        label.text = "Dashboard - Coming Soon"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.backgroundColor = .systemBackground
        viewController.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        return UINavigationController(rootViewController: viewController)
    }
    
    private func createJournalViewController() -> UIViewController {
        let viewController = UIViewController()
        let label = UILabel()
        label.text = "Journal - Coming Soon"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.backgroundColor = .systemBackground
        viewController.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        return UINavigationController(rootViewController: viewController)
    }
    
    private func createReportsViewController() -> UIViewController {
        let viewController = UIViewController()
        let label = UILabel()
        label.text = "Reports - Coming Soon"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.backgroundColor = .systemBackground
        viewController.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        return UINavigationController(rootViewController: viewController)
    }
    
    private func createGoalsViewController() -> UIViewController {
        let viewController = UIViewController()
        let label = UILabel()
        label.text = "Goals - Coming Soon"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.backgroundColor = .systemBackground
        viewController.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        return UINavigationController(rootViewController: viewController)
    }
    
    private func createSettingsViewController() -> UIViewController {
        let viewController = UIViewController()
        let label = UILabel()
        label.text = "Settings - Coming Soon"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.backgroundColor = .systemBackground
        viewController.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        return UINavigationController(rootViewController: viewController)
    }
}
