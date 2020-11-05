//
//  AwesomeProject
//

import CoreData
import Firebase
import Foundation

private enum ColorHelper {
    private static let colors: [UIColor] = [.red, .gray, .green, .blue, .yellow, .purple, .cyan, .magenta, .orange]

    static func color(for identifier: String) -> UIColor {
        let intId = identifier.unicodeScalars.reduce(into: 0) { result, value in
            result += abs(Int(value.value) % colors.count)
        }
        return colors[intId % colors.count].withAlphaComponent(0.5)
    }
}

@objc(DBChannel)
class DBChannel: NSManagedObject, InfoObject {
    @NSManaged var identifier: String
    @NSManaged var name: String
    @NSManaged var lastMessage: String?
    @NSManaged var lastActivity: Date?

    var info: String {
        "Channel(\(identifier), '\(name)')"
    }

    var color: UIColor {
        ColorHelper.color(for: identifier)
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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBChannel> {
        let request = NSFetchRequest<DBChannel>(entityName: "DBChannel")
        request.fetchBatchSize = 20
        request.sortDescriptors = [
            NSSortDescriptor(key: "lastActivity", ascending: false),
            NSSortDescriptor(key: "identifier", ascending: true)
        ]
        return request
    }

    @nonobjc public class func fetchRequest(channelId: String) -> NSFetchRequest<DBChannel> {
        let request = NSFetchRequest<DBChannel>(entityName: "DBChannel")
        request.predicate = NSPredicate(format: "identifier == %@", channelId)
        request.fetchLimit = 1
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
    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?
    let color: UIColor

    init?(id: String, dictionary: [String: Any]) {
        guard let tempName = dictionary["name"] as? String else {
            return nil
        }

        identifier = id
        name = tempName
        lastMessage = dictionary["lastMessage"] as? String
        lastActivity = (dictionary["lastActivity"] as? Timestamp)?.dateValue()
        color = ColorHelper.color(for: identifier)
    }

    init(dbChannel: DBChannel) {
        identifier = dbChannel.identifier
        name = dbChannel.name
        lastMessage = dbChannel.lastMessage
        lastActivity = dbChannel.lastActivity
        color = dbChannel.color
    }
}
