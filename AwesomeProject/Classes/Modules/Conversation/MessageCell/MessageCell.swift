//
// AwesomeProject
//

import UIKit

class MessageCell: UITableViewCell, ConfigurableView {
    private let themeManager: ThemeManager = .shared
    private var isMine = true

    @IBOutlet private var bgView: UIView!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private var trailingConstraint: NSLayoutConstraint!

    override func layoutSubviews() {
        super.layoutSubviews()

        if isMine {
            leadingConstraint.constant = frame.width / 4
            trailingConstraint.constant = 16
        } else {
            leadingConstraint.constant = 16
            trailingConstraint.constant = frame.width / 4
        }
    }

    func configure(with model: MessageCellModel) {
        messageLabel.text = model.text
        let theme = themeManager.theme
        bgView.backgroundColor = model.isMine ? Color.messageMyBGColor(theme: theme) : Color.messagePartnerBGColor(theme: theme)
        messageLabel.textColor = model.isMine ? Color.messageMyTextColor(theme: theme) : Color.messagePartnerTextColor(theme: theme)
        isMine = model.isMine
        layoutIfNeeded()
    }
}
