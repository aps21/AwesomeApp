//
// AwesomeProject
//

import UIKit

protocol ErrorDelegate: AnyObject {
    func show(error: String?)
}

class ParentVC: UIViewController, ErrorDelegate {
    private var observationTheme: NSObjectProtocol?
    private let debugLogger = Logger()

    let themeManager: ThemeManagerProtocol = ThemeManager.shared
    let notificationCenter: NotificationCenter = .default

    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch themeManager.theme {
        case .classic, .day:
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        case .night:
            return .lightContent
        }
    }

    deinit {
        if let observer = observationTheme {
            notificationCenter.removeObserver(observer)
        }
        log(message: "\(String(describing: self)) released 😵")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateColors()
        observationTheme = notificationCenter.addObserver(forName: .themeUpdate, object: nil, queue: .main) { [weak self] _ in
            self?.updateColors()
        }
    }

    func configureStatusBar() {
        switch preferredStatusBarStyle {
        case .lightContent:
            navigationController?.navigationBar.barStyle = .black
        default:
            navigationController?.navigationBar.barStyle = .default
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    func updateColors() {
        configureStatusBar()
    }

    func log(message: String) {
        debugLogger.log(message)
    }

    func show(error: String?) {
        let alertVC = UIAlertController(title: L10n.Alert.errorTitle, message: error ?? L10n.Alert.errorUnknown, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: L10n.Alert.errorOk, style: .default, handler: nil))
        present(alertVC, animated: true)
    }
}
