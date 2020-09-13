//
// AwesomeProject
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, StateLogger {
    enum AppState: String, ItemProtocol {
        case notRunnig = "not running"
        case inactive = "foreground inactive"
        case active = "foreground active"
        case background = "background"
        case suspended = "suspended"
    }

    let objectType: String = "Application"
    var previousState: AppState = .notRunnig
    var window: UIWindow?

    func application(
        _: UIApplication,
        willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        logNextState(.notRunnig, functionName: #function)
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

        logNextState(.inactive, functionName: #function)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        logNextState(.active, functionName: #function)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        logNextState(.inactive, functionName: #function)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        logNextState(.background, functionName: #function)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        logNextState(.inactive, functionName: #function)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        logNextState(.suspended, functionName: #function)
    }
}
