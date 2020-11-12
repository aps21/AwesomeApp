//
//  AwesomeProject
//

import CoreData
import Firebase
import Foundation

@objc(DBMessage)
final class DBMessage: NSManagedObject, FetchedDBObject {
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

    @nonobjc public class func fetchRequest(parentId channelId: String?) -> NSFetchRequest<DBMessage> {
        let request = NSFetchRequest<DBMessage>(entityName: "DBMessage")
        request.predicate = NSPredicate(format: "channel.identifier == %@", channelId ?? "")
        request.fetchBatchSize = 20
        request.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: true),
            NSSortDescriptor(key: "identifier", ascending: true)
        ]
        return request
    }

    @nonobjc public class func fetchRequest(messageId: String) -> NSFetchRequest<DBMessage> {
        let request = NSFetchRequest<DBMessage>(entityName: "DBMessage")
        request.predicate = NSPredicate(format: "identifier == %@", messageId)
        request.fetchLimit = 1
        return request
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

    init(dbMessage: DBMessage) {
        identifier = dbMessage.identifier
        content = dbMessage.content
        created = dbMessage.created
        senderId = dbMessage.senderId
        senderName = dbMessage.senderName
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
