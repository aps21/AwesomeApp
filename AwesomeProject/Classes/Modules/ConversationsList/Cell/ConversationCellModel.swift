//
// AwesomeProject
//

import UIKit

struct ConversationCellModel {
    let name: String
    let message: String
    let date: Date?
    let color: UIColor

    init(channel: Channel) {
        name = channel.name
        message = channel.lastMessage ?? ""
        date = channel.lastActivity
        color = channel.color
    }
}
