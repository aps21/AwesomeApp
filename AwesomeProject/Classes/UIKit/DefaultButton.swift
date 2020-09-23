//
// AwesomeProject
//

import UIKit

@IBDesignable
class DefaultButton: UIButton {
    private var isLoading = false
    private var originalButtonImage: UIImage?
    private var originalButtonTitle: String?

    private lazy var loaderView: UIActivityIndicatorView = {
        let loaderView = UIActivityIndicatorView(style: .white)
        loaderView.hidesWhenStopped = true
        loaderView.stopAnimating()
        return loaderView
    }()

    @IBInspectable var mainColor: UIColor? = UIColor(named: "Color/gray")
    @IBInspectable var highlightedColor: UIColor? = UIColor(named: "Color/darkGray")

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightedColor : mainColor
        }
    }

    private func addLoader() {
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loaderView)
        NSLayoutConstraint.activate([
            loaderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loaderView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func showLoading() {
        originalButtonImage = imageView?.image
        originalButtonTitle = titleLabel?.text
        setImage(nil, for: .normal)
        setTitle(nil, for: .normal)

        isLoading = true
        if loaderView.superview == nil {
            addLoader()
        }
        loaderView.color = tintColor
        loaderView.startAnimating()
    }

    func hideLoading() {
        guard isLoading else {
            return
        }

        isLoading = false
        loaderView.stopAnimating()
        if let image = originalButtonImage {
            setImage(image, for: .normal)
        }
        if let text = originalButtonTitle {
            setTitle(text, for: .normal)
        }
    }

    func didChangeTitle(_ newTitle: String) {
        originalButtonTitle = newTitle
    }
}
