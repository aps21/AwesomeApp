//
// AwesomeProject
//

import UIKit

class SimpleImageButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }
}
