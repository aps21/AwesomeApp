//
//  AwesomeProject
//

import UIKit

enum Theme: Int, CaseIterable {
    case classic, day, night

    var settingsBGColor: UIColor? {
        switch self {
        case .classic:
            return UIColor(named: "Color/blue")
        case .day:
            return UIColor(named: "Color/turquoise")
        case .night:
            return UIColor(named: "Color/charcoal")
        }
    }

    var title: String {
        switch self {
        case .classic:
            return L10n.Theme.classic
        case .day:
            return L10n.Theme.day
        case .night:
            return L10n.Theme.night
        }
    }
}
