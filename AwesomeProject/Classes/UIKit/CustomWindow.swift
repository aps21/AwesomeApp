//
//  AwesomeProject
//

import UIKit

class CustomWindow: UIWindow, UIGestureRecognizerDelegate {
    private lazy var longTapGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(showAnimation(_:)))
        gesture.minimumPressDuration = 0.15
        gesture.delegate = self
        return gesture
    }()

    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(showAnimation(_:)))
        gesture.delegate = self
        return gesture
    }()

    func addGestures() {
        addGestureRecognizer(longTapGesture)
        addGestureRecognizer(panGesture)
    }

    @objc
    private func showAnimation(_ gesture: UIGestureRecognizer) {
        let point = gesture.location(in: self)
        switch gesture.state {
        case .began:
            layer.showEmitted(in: point)
        case .changed:
            layer.removeEmitted()
            layer.showEmitted(in: point)
        default:
            layer.removeEmitted()
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
