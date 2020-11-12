//
//  AwesomeProject
//

import CoreData
import Foundation

protocol MessageDataSource {
    var total: Int { get }
    func object(at indexPath: IndexPath) -> DBMessage
}

typealias MessagessFetchedResultsObject = CommonFetchedResultsObject<DBMessage>

extension MessagessFetchedResultsObject: MessageDataSource {}
