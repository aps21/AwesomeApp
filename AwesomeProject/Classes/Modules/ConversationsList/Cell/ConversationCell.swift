//
// AwesomeProject
//

import UIKit

class ConversationCell: UITableViewCell, ConfigurableView {
    private enum Constants {
        static let colors: [UIColor] = [.red, .gray, .green, .blue, .yellow, .purple, .cyan, .magenta, .orange]
    }

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
        backgroundColor = model.isOnline ? Color.lightYellowColor : Color.white
        iconView.backgroundColor = Constants.colors.randomElement()?.withAlphaComponent(0.5)
        nameLabel.text = model.name
        nameLabel.textColor = Color.black
        if model.message.isEmpty {
            dateLabel.isHidden = true
            messageLabel.text = L10n.Chat.noMessages
            messageLabel.textColor = Color.label?.withAlphaComponent(0.5)
            messageLabel.font = UIFont.italicSystemFont(ofSize: 13)
        } else {
            dateLabel.text = model.date.chatDate()
            dateLabel.isHidden = false
            messageLabel.text = model.message
            messageLabel.textColor = Color.label
            messageLabel.font = model.hasUnreadMessages ? UIFont.boldSystemFont(ofSize: 13) : UIFont.systemFont(ofSize: 13)
        }
        divider.backgroundColor = Color.black
    }

    func hideDivider() {
        divider.isHidden = true
    }
}
