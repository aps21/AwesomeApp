//
// AwesomeProject
//

import UIKit

class ConversationTitle: UIView {
    init(title: String) {
        super.init(frame: .zero)

        let height: CGFloat = 40
        let image = AvatarHelper.generateImage(
            with: title.split(separator: " ").map { $0.description.firstSymbol }.joined(separator: ""),
            bgColor: UIColor(named: "Color/yellow"),
            size: CGSize(width: height, height: height)
        )
        let imageView = UIImageView(image: image)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = height / 2
        let label = UILabel()
        label.text = title
        label.textColor = Color.black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        stack.alignment = .center

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        stack.sizeToFit()
        frame = stack.frame
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
