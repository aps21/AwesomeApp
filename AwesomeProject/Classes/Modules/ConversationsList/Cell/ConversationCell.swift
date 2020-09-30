//
// AwesomeProject
//

import UIKit

class ConversationCell: UITableViewCell, ConfigurableView {
    private enum Constants {
        static let colors: [UIColor] = [.red, .gray, .green, .blue, .yellow, .purple, .cyan, .magenta, .orange]
        static let lightYellowColor = UIColor(named: "Color/lightYellow")
        static let whiteColor = UIColor(named: "Color/white")
        static let labelColor = UIColor(named: "Color/label")
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
        backgroundColor = model.isOnline ? Constants.lightYellowColor : Constants.whiteColor
        iconView.backgroundColor = Constants.colors.randomElement()?.withAlphaComponent(0.5)
        nameLabel.text = model.name
        if model.message.isEmpty {
            dateLabel.isHidden = true
        } else {
            dateLabel.text = model.date.chatDate()
            dateLabel.isHidden = false
        }
        if model.message.isEmpty {
            messageLabel.text = L10n.Chat.noMessages
            messageLabel.textColor = Constants.labelColor?.withAlphaComponent(0.5)
            messageLabel.font = UIFont.italicSystemFont(ofSize: 13)
        } else {
            messageLabel.text = model.message
            messageLabel.textColor = Constants.labelColor
            messageLabel.font = model.hasUnreadMessages ? UIFont.boldSystemFont(ofSize: 13) : UIFont.systemFont(ofSize: 13)
        }
    }

    func hideDivider() {
        divider.isHidden = true
    }
}
