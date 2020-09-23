//
// AwesomeProject
//

import Foundation

struct User {
    let id: String
    let firstName: String
    let lastName: String
    let bio: String
    var avatarURL: String?

    var name: String {
        [firstName, lastName].compactMap { $0.isEmpty ? nil : $0 }.joined(separator: " ")
    }
}
