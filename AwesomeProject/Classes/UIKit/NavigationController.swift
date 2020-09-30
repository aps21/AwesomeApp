//
// AwesomeProject
//

import UIKit

class NavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    @IBInspectable var isClear: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        delegate = self

        if isClear {
            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundEffect = .init(style: .systemMaterial)
                navigationBar.scrollEdgeAppearance = appearance
                navigationBar.standardAppearance = appearance
            } else {
                navigationBar.setBackgroundImage(nil, for: .default)
                navigationBar.shadowImage = UIImage()

                navigationBar.layer.shadowColor = UIColor.clear.cgColor
                navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1)
                navigationBar.layer.shadowRadius = 1 / 2
                navigationBar.layer.shadowOpacity = 1
            }
        }
    }

    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
