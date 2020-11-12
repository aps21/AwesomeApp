//
//  AwesomeProject
//

import CoreData

protocol ChannelDataStorage {
    func save(channels: [DataItem])
}

class ChannelStorage: CoreDataStorage, ChannelDataStorage {
    func save(channels: [DataItem]) {
        coreDataStack.performSave { context in
            channels.forEach { channel in
                switch channel.type {
                case .added, .modified:
                    _ = DBChannel(id: channel.id, dictionary: channel.dictionary, in: context)
                case .removed:
                    if let channel = (try? context.fetch(DBChannel.fetchRequest(channelId: channel.id)))?.first {
                        context.delete(channel)
                    }
                }
            }
        }
    }
}
