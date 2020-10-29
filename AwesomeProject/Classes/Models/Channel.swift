//
//  AwesomeProject
//

import CoreData
import Firebase
import Foundation

@objc(DBChannel)
class DBChannel: NSManagedObject, InfoObject {
    @NSManaged var identifier: String
    @NSManaged var name: String
    @NSManaged var lastMessage: String?
    @NSManaged var lastActivity: Date?

    var info: String {
        "Channel(\(identifier), '\(name)')"
    }

    convenience init?(id: String, dictionary: [String: Any], in context: NSManagedObjectContext) {
        guard let tempName = dictionary["name"] as? String else {
            return nil
        }

        self.init(context: context)
        identifier = id
        name = tempName
        lastMessage = dictionary["lastMessage"] as? String
        lastActivity = (dictionary["lastActivity"] as? Timestamp)?.dateValue()
    }

    @nonobjc public class func fetchRequest(channelId: String) -> NSFetchRequest<DBChannel> {
        let request = NSFetchRequest<DBChannel>(entityName: "DBChannel")
        request.predicate = NSPredicate(format: "identifier == %@", channelId)
        request.fetchBatchSize = 1
        return request
    }

    @nonobjc public class func fetchCountRequest() -> NSFetchRequest<DBChannel> {
        let request = NSFetchRequest<DBChannel>(entityName: "DBChannel")
        request.resultType = .countResultType
        return request
    }

    @objc(addMessagesObject:)
    @NSManaged func addToMessages(_ value: DBMessage)

    @objc(removeMessagesObject:)
    @NSManaged func removeFromMessages(_ value: DBMessage)

    @objc(addMessages:)
    @NSManaged func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged func removeFromMessages(_ values: NSSet)
}

struct Channel {
    private let colors: [UIColor] = [.red, .gray, .green, .blue, .yellow, .purple, .cyan, .magenta, .orange]

    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?

    var color: UIColor {
        let intId = identifier.unicodeScalars.reduce(into: 0) { result, value in
            result += abs(Int(value.value) % colors.count)
        }
        return colors[intId % colors.count].withAlphaComponent(0.5)
    }

    init?(id: String, dictionary: [String: Any]) {
        guard let tempName = dictionary["name"] as? String else {
            return nil
        }

        identifier = id
        name = tempName
        lastMessage = dictionary["lastMessage"] as? String
        lastActivity = (dictionary["lastActivity"] as? Timestamp)?.dateValue()
    }
}
