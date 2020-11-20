//
//  AwesomeProject
//

import UIKit

protocol UserStore {
    func save(name: String?, bio: String?, avatar: UIImage?, completion: @escaping (_ success: Bool) -> Void)
    func savedUser() -> User?
}

class UserFileManager: UserStore {
    private let file = "user.txt"
    private let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private var fileURL: URL? {
        if let dir = directory.first {
            return dir.appendingPathComponent(file)
        }
        return nil
    }

    init() {}

    func save(name: String?, bio: String?, avatar: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        let user = User(name: name, bio: bio, imageData: avatar?.pngData())

        if let fileURL = fileURL {
            do {
                let data = try encoder.encode(user)
                try data.write(to: fileURL)
                completion(true)
            } catch {
                completion(false)
            }
        } else {
            completion(false)
        }
    }

    func savedUser() -> User? {
        if let fileURL = fileURL,
            let data = try? Data(contentsOf: fileURL),
            let user = try? decoder.decode(User.self, from: data) {
            return user
        }
        return User(name: "Marina D", bio: "UI designer from LA", imageData: nil)
    }
}