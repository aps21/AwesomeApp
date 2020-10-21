//
// AwesomeProject
//

import UIKit

class MessageCell: UITableViewCell, ConfigurableView {
    private let themeManager: ThemeManager = .shared
    private var isMine = true

    @IBOutlet private var bgView: UIView!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var contentStack: UIStackView!
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
        isMine = model.isMine

        dateLabel.text = model.date
        nameLabel.text = model.name
        messageLabel.text = model.text

        let theme = themeManager.theme
        bgView.backgroundColor = isMine ? Color.messageMyBGColor(theme: theme) : Color.messagePartnerBGColor(theme: theme)
        let color = isMine ? Color.messageMyTextColor(theme: theme) : Color.messagePartnerTextColor(theme: theme)
        [dateLabel, nameLabel, messageLabel].forEach { (label: UILabel) in
            label.textColor = color
        }

        contentStack.alignment = isMine ? .trailing : .leading
        nameLabel.isHidden = isMine

        layoutIfNeeded()
    }
}
