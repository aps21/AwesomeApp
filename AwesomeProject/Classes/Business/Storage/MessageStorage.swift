//
//  AwesomeProject
//

import CoreData

protocol MessageDataStorage {
    func save(channelId: String, messages: [DataItem])
}

class MessageStorage: CoreDataStorage, MessageDataStorage {
    func save(channelId: String, messages: [DataItem]) {
        coreDataStack.performSave { context in
            var dbMessages: [DBMessage] = []

            messages.forEach { message in
                switch message.type {
                case .added, .modified:
                    if let dbMessage = DBMessage(id: message.id, dictionary: message.dictionary, in: context) {
                        dbMessages.append(dbMessage)
                    }
                case .removed:
                    if let message = (try? context.fetch(DBMessage.fetchRequest(messageId: message.id)))?.first {
                        context.delete(message)
                    }
                }
            }
            if !dbMessages.isEmpty {
                let channel = (try? context.fetch(DBChannel.fetchRequest(channelId: channelId)))?.first
                channel?.addToMessages(NSSet(array: dbMessages))
            }
        }
    }
}
