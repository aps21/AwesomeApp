//
//  AwesomeProject
//

import CoreData
import Firebase
import Foundation

@objc(DBMessage)
class DBMessage: NSManagedObject, InfoObject {
    @NSManaged var identifier: String
    @NSManaged var content: String
    @NSManaged var created: Date
    @NSManaged var senderId: String
    @NSManaged var senderName: String

    var info: String {
        "Message(\(identifier), '\(content)')"
    }

    convenience init?(id: String, dictionary: [String: Any], in context: NSManagedObjectContext) {
        guard let tempContent = dictionary["content"] as? String,
            let tempCreated = dictionary["created"] as? Timestamp,
            let tempSenderId = dictionary["senderId"] as? String,
            let tempSenderName = dictionary["senderName"] as? String else {
                return nil
        }

        self.init(context: context)
        identifier = id
        content = tempContent
        created = tempCreated.dateValue()
        senderId = tempSenderId
        senderName = tempSenderName
    }

    static func payload(message: String, user: User) -> [String: Any] {
        [
            "content": message,
            "created": Timestamp(date: Date()),
            "senderId": user.senderId ?? "",
            "senderName": user.name ?? "Неопознанный кролик"
        ]
    }

    @nonobjc public class func fetchCountRequest() -> NSFetchRequest<DBMessage> {
        let request = NSFetchRequest<DBMessage>(entityName: "DBMessage")
        request.resultType = .countResultType
        return request
    }
}

struct Message {
    let identifier: String
    let content: String
    let created: Date
    let senderId: String
    let senderName: String

    init?(id: String, dictionary: [String: Any]) {
        guard let tempContent = dictionary["content"] as? String,
            let tempCreated = dictionary["created"] as? Timestamp,
            let tempSenderId = dictionary["senderId"] as? String,
            let tempSenderName = dictionary["senderName"] as? String else {
                return nil
        }

        identifier = id
        content = tempContent
        created = tempCreated.dateValue()
        senderId = tempSenderId
        senderName = tempSenderName
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
