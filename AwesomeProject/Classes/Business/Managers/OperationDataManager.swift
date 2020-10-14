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
        // TODO: Just for test, remove later
        sleep(2)
        fileManager?.save(name: userName, bio: userBio, avatar: userAvatar) { [weak self] in self?.completion?($0) }
    }
}

class OperationDataManager: Operation, UserManager {
    private let fileManager = UserFileManager()

    func save(name: String?, bio: String?, avatar: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        let operationQueue = OperationQueue()
        let operation = UserDataOperation()
        operation.fileManager = fileManager
        operation.userName = name
        operation.userBio = bio
        operation.userAvatar = avatar
        operation.completion = completion
        operationQueue.addOperation(operation)
    }

    func cachedUser() -> User? {
        fileManager.cachedUser()
    }
}
