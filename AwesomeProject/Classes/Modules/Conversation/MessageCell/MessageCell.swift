//
// AwesomeProject
//

import UIKit

class MessageCell: UITableViewCell, ConfigurableView {
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
        bgView.backgroundColor = UIColor(named: model.isMine ? "Color/lightGreen" : "Color/gray")
        isMine = model.isMine
        layoutIfNeeded()
    }
}

extension MessageCell {
    class func instanceFromNib() -> MessageCell? {
        return UINib(nibName: String(describing: MessageCell.self), bundle: nil).instantiate(withOwner: nil)[0] as? MessageCell
    }
}
