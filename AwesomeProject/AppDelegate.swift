//
// AwesomeProject
//

import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: CustomWindow?

    var isUnitTests: Bool {
        ProcessInfo.processInfo.environment["UNIT_TESTS"] == "true"
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
        let window = CustomWindow(frame: UIScreen.main.bounds)
        window.addGestures()
        let storyboard = UIStoryboard(name: "ConversationsList", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "navController")
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window

        FirebaseApp.configure()

        return true
    }
}
