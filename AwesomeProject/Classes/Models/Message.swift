//
//  AwesomeProject
//

import Firebase
import Foundation

struct Message: Equatable {
    let content: String
    let created: Date
    let senderId: String
    let senderName: String

    init?(dictionary: [String: Any]) {
        guard let tempContent = dictionary["content"] as? String,
            let tempCreated = dictionary["created"] as? Timestamp,
            let tempSenderId = dictionary["senderId"] as? String,
            let tempSenderName = dictionary["senderName"] as? String else {
            return nil
        }

        content = tempContent
        created = tempCreated.dateValue()
        senderId = tempSenderId
        senderName = tempSenderName
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.created == rhs.created && lhs.senderId == rhs.senderId
    }

    static func payload(message: String, user: User) -> [String: Any] {
        [
            "content": message,
            "created": Timestamp(date: Date()),
            "senderId": user.senderId ?? "",
            "senderName": user.name ?? "Неопознанный кролик"
        ]
    }
}
