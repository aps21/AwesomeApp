//
// AwesomeProject
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private enum AppState: String, ItemProtocol {
        case notRunnig = "not running"
        case inactive = "foreground inactive"
        case active = "foreground active"
        case background = "background"
        case suspended = "suspended"
    }

    private let stateLogger = AppStateLogger<AppState>(instanceType: "ApplicationDelegate", initialState: .notRunnig)
    var window: UIWindow?

    func application(
        _: UIApplication,
        willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        stateLogger.capture(reason: #function, state: .notRunnig)
        return true
    }

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }

        stateLogger.capture(reason: #function, state: .inactive)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        stateLogger.capture(reason: #function, state: .active)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        stateLogger.capture(reason: #function, state: .inactive)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        stateLogger.capture(reason: #function, state: .background)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        stateLogger.capture(reason: #function, state: .inactive)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        stateLogger.capture(reason: #function, state: .suspended)
    }
}
