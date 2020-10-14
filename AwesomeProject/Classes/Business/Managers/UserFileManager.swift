//
//  AwesomeProject
//

import UIKit

// TODO: Maybe need to make more universal
class UserFileManager {
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

    func cachedUser() -> User? {
        if let fileURL = fileURL {
            do {
                let data = try Data(contentsOf: fileURL)
                return try decoder.decode(User.self, from: data)
            } catch {
                print(error)
            }
        }
        return nil
    }

    func avatarImage(userData: User? = nil, height: CGFloat) -> UIImage? {
        let user = userData ?? cachedUser()
        if let image = user?.image {
            let size = CGSize(width: height, height: height)
            let rect = CGRect(origin: .zero, size: size)
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
        return AvatarHelper.generateImage(
            with: user?.initials,
            bgColor: UIColor(named: "Color/yellow"),
            size: CGSize(width: height, height: height)
        )
    }
}
