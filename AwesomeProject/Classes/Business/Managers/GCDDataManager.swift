//
//  AwesomeProject
//

import UIKit

class GCDDataManager: UserManager {
    private let fileManager = UserFileManager()
    private let queue = DispatchQueue.global(qos: .default)

    private(set) lazy var user: User? = fileManager.savedUser()

    func save(name: String?, bio: String?, avatar: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        let mainCompletion = { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
        queue.async {
            self.fileManager.save(name: name, bio: bio, avatar: avatar, completion: mainCompletion)
        }
    }

    func savedUser(completion: @escaping (User?) -> Void) {
        queue.async {
            let user = self.fileManager.savedUser()
            self.user = user
            DispatchQueue.main.sync {
                completion(user)
            }
        }
    }
}
