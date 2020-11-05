//
//  AwesomeProject
//

import CoreData
import Foundation

class CoreDataStack {
    static let shared = CoreDataStack()

    private let debugLogger = Logger(logger: .coreDataLogger)
    private let dataModelName = "Chat"
    private let dataModelExtension = "momd"

    private var storeUrl: URL = {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("documents path not found")
        }
        return documentsUrl.appendingPathComponent("Chat.sqlite")
    }()

    private(set) lazy var managerObjectModel: NSManagedObjectModel = {
        guard let modelUrl = Bundle.main.url(forResource: dataModelName, withExtension: dataModelExtension) else {
            fatalError("model not found")
        }

        guard let managerObjectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            fatalError("managerObjectModel could not be created")
        }

        return managerObjectModel
    }()

    private(set) lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managerObjectModel)

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
        } catch {
            fatalError(error.localizedDescription)
        }

        return coordinator
    }()

    private lazy var writterContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()

    private(set) lazy var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = writterContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }()

    var didUpdateDataBase: ((CoreDataStack) -> Void)?

    private init() {
        enableObservers()
    }

    private func saveContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    private func performSave(in context: NSManagedObjectContext) throws {
        try context.save()
        if let parent = context.parent {
            try performSave(in: parent)
        }
    }

    private func logDBStatistics() {
        mainContext.performAndWait {
            do {
                let channels = try mainContext.count(for: DBChannel.fetchCountRequest())
                let messages = try mainContext.count(for: DBMessage.fetchCountRequest())
                debugLogger.log("Channels total: \(channels)")
                debugLogger.log("Messages total: \(messages)")
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    @objc
    private func didChangeContext(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        didUpdateDataBase?(self)

        let stringConstructor = { (type: String, items: Set<NSManagedObject>) in
            "\(type) \(items.count):\n  \(items.compactMap { ($0 as? InfoObject)?.info }.joined(separator: "\n  "))"
        }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>,
            inserts.count > 0 {
            debugLogger.log(stringConstructor("Inserted", inserts))
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            updates.count > 0 {
            debugLogger.log(stringConstructor("Updated", updates))
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            deletes.count > 0 {
            debugLogger.log(stringConstructor("Deleted", deletes))
        }

        logDBStatistics()
    }

    func performSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = saveContext()
        context.performAndWait {
            block(context)
            if context.hasChanges {
                do {
                    try context.obtainPermanentIDs(for: Array(context.insertedObjects))
                    try performSave(in: context)
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
        }
    }

    func enableObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(didChangeContext(notification:)),
            name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: mainContext
        )
    }
}
