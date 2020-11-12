//
//  AwesomeProject
//

import CoreData
import Foundation

protocol ChannelDataSource {
    var total: Int { get }
    func object(at indexPath: IndexPath) -> DBChannel
}

typealias ConversationsFetchedResultsObject = CommonFetchedResultsObject<DBChannel>

extension ConversationsFetchedResultsObject: ChannelDataSource {}
