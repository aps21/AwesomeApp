//
//  AwesomeProject
//

import UIKit

extension UIView {
    class func instanceFromNib() -> Self? {
        let items = UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: nil)
        if !items.isEmpty {
            return items[0] as? Self
        }
        return nil
    }
}
