//
// AwesomeProject
//

import UIKit

class NavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    private let themeManager: ThemeManagerProtocol = ThemeManager.shared
    private let notificationCenter: NotificationCenter = .default
    private var observationTheme: NSObjectProtocol?

    @IBInspectable var isClear: Bool = false

    public override var childForStatusBarStyle: UIViewController? {
        topViewController
    }

    deinit {
        if let observer = observationTheme {
            notificationCenter.removeObserver(observer)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        delegate = self

        if isClear {
            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundEffect = .init(style: .systemMaterial)
                navigationBar.scrollEdgeAppearance = appearance
                navigationBar.standardAppearance = appearance
            } else {
                navigationBar.setBackgroundImage(nil, for: .default)
                navigationBar.shadowImage = UIImage()

                navigationBar.layer.shadowColor = UIColor.clear.cgColor
                navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1)
                navigationBar.layer.shadowRadius = 1 / 2
                navigationBar.layer.shadowOpacity = 1
            }
        }

        applyTheme()
        observationTheme = notificationCenter.addObserver(forName: .themeUpdate, object: nil, queue: .main) { [weak self] _ in
            self?.applyTheme()
        }
    }

    private func applyTheme() {
        let isNight = themeManager.theme == .night
        if #available(iOS 13.0, *) {
            let appearance = navigationBar.standardAppearance
            appearance.backgroundColor = isNight ? Color.black2 : nil
            if let black = Color.black {
                appearance.titleTextAttributes = [.foregroundColor: black]
                appearance.largeTitleTextAttributes = [.foregroundColor: black]
            }
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.standardAppearance = appearance
        } else {
            navigationBar.barTintColor = isNight ? Color.black2 : nil
            navigationBar.backgroundColor = isNight ? Color.black2 : nil
            if let black = Color.black {
                navigationBar.titleTextAttributes = [.foregroundColor: black]
                navigationBar.largeTitleTextAttributes = [.foregroundColor: black]
            }
        }
        navigationBar.barStyle = isNight ? .default : .black
    }

    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}

extension Notification.Name {
    static let themeUpdate = Notification.Name("themeUpdate")
    static let userUpdate = Notification.Name("userUpdate")
}
