//
// AwesomeProject
//

import UIKit

class AvatarHelper {
    static func generateImage(with text: String?, bgColor: UIColor?, size: CGSize) -> UIImage? {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: size.height * 105 / 240)
        label.text = text ?? "🐈"
        label.textAlignment = .center
        label.textColor = UIColor(named: "Color/charcoal")

        let bgView = UIView(frame: CGRect(origin: .zero, size: size))
        bgView.backgroundColor = bgColor

        label.frame = bgView.frame
        bgView.addSubview(label)

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            bgView.layer.render(in: context)
        }
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageWithText
    }
}
