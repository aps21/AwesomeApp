//
//  AwesomeProject
//

import UIKit

class ThemeManager: ThemesPickerDelegate {
    private enum Constants {
        static let themeKey = "ThemeManager.themeKey"
    }

    private var currentTheme: Theme = .classic

    private let queue = DispatchQueue.global(qos: .userInitiated)
    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter

    var theme: Theme {
        get {
            var tempTheme: Theme = .classic
            queue.sync { tempTheme = self.currentTheme }
            return tempTheme
        }
        set {
            queue.async {
                self.currentTheme = newValue
                self.userDefaults.set(newValue.rawValue, forKey: Constants.themeKey)
                self.notificationCenter.post(name: .themeUpdate, object: newValue)
            }
        }
    }

    static let shared = ThemeManager()

    private init(userDefaults: UserDefaults = .standard, notificationCenter: NotificationCenter = .default) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        currentTheme = Theme(rawValue: userDefaults.integer(forKey: Constants.themeKey)) ?? .classic
    }
    
    func didSelect(theme: Theme) {
        self.theme = theme
    }
}
