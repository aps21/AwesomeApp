//
//  AwesomeProject
//

import UIKit

private class UserDataOperation: Operation {
    var fileManager: UserFileManager?
    var userName: String?
    var userBio: String?
    var userAvatar: UIImage?
    var completion: ((_ success: Bool) -> Void)?

    override func main() {
        if isCancelled { return }
        // TODO: Just for test, remove later
        sleep(2)
        if isCancelled { return }
        fileManager?.save(name: userName, bio: userBio, avatar: userAvatar) {
            if self.isCancelled { return }
            self.completion?($0)
        }
    }
}

class OperationDataManager: Operation, UserManager {
    private let operationQueue = OperationQueue()
    private let fileManager = UserFileManager()

    func save(name: String?, bio: String?, avatar: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        let operation = UserDataOperation()
        operation.fileManager = fileManager
        operation.userName = name
        operation.userBio = bio
        operation.userAvatar = avatar
        operation.completion = { success in
            // TODO: Just for test, remove later
            sleep(2)
            DispatchQueue.main.async {
                completion(success)
            }
        }
        operationQueue.addOperation(operation)
    }

    func savedUser(completion: @escaping (User?) -> Void) {
        let operationQueue = OperationQueue()
        let operation = {
            // TODO: Just for test, remove later
            sleep(2)
            DispatchQueue.main.async {
                completion(self.fileManager.savedUser())
            }
        }
        operationQueue.addOperation(operation)
    }
}
