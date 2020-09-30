//
// AwesomeProject
//

import UIKit

class RoundedImageView: UIImageView {
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != nil, backgroundColor?.cgColor.alpha == 0 {
                backgroundColor = oldValue
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }
}
