//
//  AwesomeProject
//

import CoreData
import UIKit

protocol FetchedDBObject: InfoObject, NSManagedObject {
    static func fetchRequest(parentId: String?) -> NSFetchRequest<Self>
}

protocol FetchedDelegate: NSFetchedResultsControllerDelegate, FetchedResultsProtocol {
    associatedtype DBObject: FetchedDBObject

    var delegate: (FinishProtocol & ErrorDelegate)? { get }
    var fetchDelegate: FetchedResultsDelegate { get }
    var fetchResultController: NSFetchedResultsController<DBObject> { get }

    var total: Int { get }
    func object(at indexPath: IndexPath) -> DBObject
}

class CommonFetchedResultsObject<DBObject: FetchedDBObject>: NSObject, FetchedDelegate {
    weak var tableView: UITableView!
    weak var delegate: (FinishProtocol & ErrorDelegate)?

    let parentId: String?

    let coreDataStack = CoreDataStack.shared

    lazy var fetchDelegate = FetchedResultsDelegate(tableView: tableView, delegate: self)

    lazy var fetchResultController: NSFetchedResultsController<DBObject> = {
        fetchResultVC(mainContext: coreDataStack.mainContext, parentId: parentId)
    }()

    var total: Int {
        fetchResultController.fetchedObjects?.count ?? 0
    }

    init(parentId: String?, tableView: UITableView, delegate: (FinishProtocol & ErrorDelegate)?) {
        self.parentId = parentId
        self.tableView = tableView
        self.delegate = delegate
        super.init()
    }

    func isValid(object: Any) -> Bool {
        object is DBObject
    }

    func didFinish() {
        delegate?.didFinish()
    }

    func object(at indexPath: IndexPath) -> DBObject {
        fetchResultController.object(at: indexPath)
    }

    func fetchResultVC<Object: FetchedDBObject>
        (mainContext: NSManagedObjectContext,
         parentId: String?
    ) -> NSFetchedResultsController<Object> {
        let request: NSFetchRequest<Object> = Object.fetchRequest(parentId: parentId)
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        do {
            try controller.performFetch()
        } catch {
            delegate?.show(error: error.localizedDescription)
        }
        controller.delegate = fetchDelegate
        return controller
    }
}
