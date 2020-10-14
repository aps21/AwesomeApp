//
//  AwesomeProject
//

import UIKit

class GCDDataManager: UserManager {
    private let fileManager = UserFileManager()
    private let queue = DispatchQueue.global(qos: .default)

    func save(name: String?, bio: String?, avatar: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        queue.async {
            // TODO: Just for test, remove later
            sleep(2)
            self.fileManager.save(name: name, bio: bio, avatar: avatar, completion: completion)
        }
    }

    func cachedUser() -> User? {
        fileManager.cachedUser()
    }
}
