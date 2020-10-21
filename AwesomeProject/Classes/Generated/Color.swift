//
//  AwesomeProject
//

import UIKit

enum Color {
    static var white: UIColor? {
        switch ThemeManager.shared.theme {
        case .classic, .day:
            return UIColor(named: "Color/white")
        case .night:
            return UIColor(named: "Color/black")
        }
    }

    static var black2: UIColor? {
        UIColor(named: "Color/black2")
    }

    static var black: UIColor? {
        switch ThemeManager.shared.theme {
        case .classic, .day:
            return UIColor(named: "Color/black")
        case .night:
            return UIColor(named: "Color/white")
        }
    }

    static var lightGray: UIColor? {
        switch ThemeManager.shared.theme {
        case .classic, .day:
            return UIColor(named: "Color/lightGray")
        case .night:
            return UIColor(named: "Color/black2")
        }
    }

    static var gray: UIColor? {
        switch ThemeManager.shared.theme {
        case .classic, .day:
            return UIColor(named: "Color/gray")
        case .night:
            return UIColor(named: "Color/charcoal")
        }
    }

    static var lightYellowColor: UIColor? {
        switch ThemeManager.shared.theme {
        case .classic, .day:
            return UIColor(named: "Color/lightYellow")
        case .night:
            return UIColor(named: "Color/darkYellow")
        }
    }

    static var label: UIColor? {
        UIColor(named: "Color/label")
    }

    // MARK: Message

    static func messageBGColor(theme: Theme) -> UIColor? {
        switch theme {
        case .classic, .day:
            return UIColor(named: "Color/white")
        case .night:
            return UIColor(named: "Color/black")
        }
    }

    static func messagePartnerBGColor(theme: Theme) -> UIColor? {
        switch theme {
        case .classic:
            return UIColor(named: "Color/white2")
        case .day:
            return UIColor(named: "Color/gray")
        case .night:
            return UIColor(named: "Color/charcoal2")
        }
    }

    static func messageMyBGColor(theme: Theme) -> UIColor? {
        switch theme {
        case .classic:
            return UIColor(named: "Color/lightGreen")
        case .day:
            return UIColor(named: "Color/dodgerBlue")
        case .night:
            return UIColor(named: "Color/mortag")
        }
    }

    static func messageMyTextColor(theme: Theme) -> UIColor? {
        switch theme {
        case .classic:
            return UIColor(named: "Color/black")
        case .day, .night:
            return UIColor(named: "Color/white")
        }
    }

    static func messagePartnerTextColor(theme: Theme) -> UIColor? {
        switch theme {
        case .classic, .day:
            return UIColor(named: "Color/black")
        case .night:
            return UIColor(named: "Color/white")
        }
    }
}
