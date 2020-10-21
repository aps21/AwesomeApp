//
// AwesomeProject
//

import Foundation

struct MessageCellModel {
    let text: String
    let date: String
    let name: String
    let isMine: Bool

    init(message: Message, isMine: Bool) {
        text = message.content
        date = message.created.messageDate()
        name = message.senderName
        self.isMine = isMine
    }
}
