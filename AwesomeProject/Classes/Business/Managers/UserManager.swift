//
//  AwesomeProject
//

import UIKit

protocol UserManager {
    func save(name: String?, bio: String?, avatar: UIImage?, completion: @escaping (_ success: Bool) -> Void)
    func cachedUser() -> User?
}
