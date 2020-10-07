//
//  AwesomeProject
//

import UIKit

class ThemeManager: ThemesPickerDelegate {
    private enum Constants {
        static let themeKey = "ThemeManager.themeKey"
    }

    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter

    private(set) var theme: Theme

    static let shared = ThemeManager()

    private init(userDefaults: UserDefaults = .standard, notificationCenter: NotificationCenter = .default) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        theme = Theme(rawValue: userDefaults.integer(forKey: Constants.themeKey)) ?? .classic
    }

    func didSelect(theme: Theme) {
        self.theme = theme
        userDefaults.set(theme.rawValue, forKey: Constants.themeKey)
        notificationCenter.post(name: .themeUpdate, object: theme)
    }
}
