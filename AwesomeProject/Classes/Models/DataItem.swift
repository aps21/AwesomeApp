//
//  AwesomeProject
//

import Foundation

struct DataItem {
    enum DiffType {
        case added, modified, removed
    }

    let id: String
    let dictionary: [String: Any]
    let type: DiffType
}
