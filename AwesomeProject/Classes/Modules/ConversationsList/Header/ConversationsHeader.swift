//
// AwesomeProject
//

import UIKit

class ConversationsHeader: UITableViewHeaderFooterView {
    @IBOutlet private var titleLabel: UILabel!

    func configure(isOnline: Bool) {
        titleLabel.textColor = Color.black
        titleLabel.text = isOnline ? L10n.Chat.onlineHeader : L10n.Chat.historyHeader
    }
}
