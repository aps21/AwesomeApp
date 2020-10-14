//
//  AwesomeProject
//

import UIKit

class GCDDataManager: UserManager {
    private let fileManager = UserFileManager()
    private let queue = DispatchQueue.global(qos: .default)

    func save(name: String?, bio: String?, avatar: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        let mainCompletion = { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
        queue.async {
            // TODO: Just for test, remove later
            sleep(2)
            self.fileManager.save(name: name, bio: bio, avatar: avatar, completion: mainCompletion)
        }
    }

    func savedUser(completion: @escaping (User?) -> Void) {
        queue.async {
            let user = self.fileManager.savedUser()
            // TODO: Just for test, remove later
            sleep(2)
            DispatchQueue.main.sync {
                completion(user)
            }
        }
    }
}
