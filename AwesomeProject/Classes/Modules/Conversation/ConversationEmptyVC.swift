//
//  AwesomeProject
//

import UIKit

class ConversationEmptyVC: ParentVC {
    @IBOutlet private var image: UIImageView!
    @IBOutlet private var label: UILabel!

    override func updateColors() {
        super.updateColors()
        view.backgroundColor = Color.white
        image.tintColor = Color.black
        label.textColor = Color.black
    }
}
