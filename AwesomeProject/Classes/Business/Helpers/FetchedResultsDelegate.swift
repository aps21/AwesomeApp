//
//  AwesomeProject
//

import CoreData
import UIKit

protocol FinishProtocol: AnyObject {
    func didFinish()
}

protocol FetchedResultsProtocol: FinishProtocol {
    func isValid(object: Any) -> Bool
}

class FetchedResultsDelegate: NSObject, NSFetchedResultsControllerDelegate {
    weak var tableView: UITableView!
    weak var delegate: FetchedResultsProtocol?

    init(tableView: UITableView, delegate: FetchedResultsProtocol?) {
        self.tableView = tableView
        self.delegate = delegate
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let delegate = delegate, delegate.isValid(object: anObject) else {
            return
        }

        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                return
            }
            tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            guard let indexPath = indexPath else {
                return
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            guard let indexPath = indexPath else {
                return
            }
            tableView.reloadRows(at: [indexPath], with: .fade)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else {
                return
            }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        default:
            return
        }
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        delegate?.didFinish()
    }
}
