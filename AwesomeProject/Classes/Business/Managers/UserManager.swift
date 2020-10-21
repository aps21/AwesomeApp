//
//  AwesomeProject
//

import UIKit

protocol UserManager {
    var user: User? { get }
    func save(name: String?, bio: String?, avatar: UIImage?, completion: @escaping (_ success: Bool) -> Void)
    func savedUser(completion: @escaping (User?) -> Void)
    func avatarImage(userData: User?, height: CGFloat) -> UIImage?
}

extension UserManager {
    var user: User? {
        nil
    }

    func avatarImage(userData: User?, height: CGFloat) -> UIImage? {
        let user = userData
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
