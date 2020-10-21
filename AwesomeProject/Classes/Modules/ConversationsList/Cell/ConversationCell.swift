//
// AwesomeProject
//

import UIKit

class ConversationCell: UITableViewCell, ConfigurableView {
    @IBOutlet private var iconView: RoundedImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var divider: UIView!

    override func prepareForReuse() {
        super.prepareForReuse()

        divider.isHidden = false
    }

    func configure(with model: ConversationCellModel) {
        iconView.backgroundColor = model.color
        nameLabel.text = model.name
        nameLabel.textColor = Color.black
        dateLabel.text = model.date?.chatDate()
        if model.message.isEmpty {
            messageLabel.text = L10n.Chat.noMessages
            messageLabel.textColor = Color.label?.withAlphaComponent(0.5)
            messageLabel.font = UIFont.italicSystemFont(ofSize: 13)
        } else {
            messageLabel.text = model.message
            messageLabel.textColor = Color.label
            messageLabel.font = UIFont.systemFont(ofSize: 13)
        }
        divider.backgroundColor = Color.black
    }

    func hideDivider() {
        divider.isHidden = true
    }
}
