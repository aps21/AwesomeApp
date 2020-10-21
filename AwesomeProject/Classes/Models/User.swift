//
// AwesomeProject
//

import UIKit

struct User: Codable {
    var senderId: String? {
        UIDevice.current.identifierForVendor?.uuidString
    }

    let name: String?
    let bio: String?
    let imageData: Data?

    var image: UIImage? {
        imageData.flatMap { UIImage(data: $0) }
    }

    var initials: String {
        let nameItems = name?.split(separator: " ") ?? []
        return (nameItems.first?.description.firstSymbol ?? "") + (nameItems.dropFirst().first?.description.firstSymbol ?? "")
    }
}
