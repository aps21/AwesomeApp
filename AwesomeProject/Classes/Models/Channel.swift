//
//  AwesomeProject
//

import Firebase
import Foundation

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
