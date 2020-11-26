//
// AwesomeProject
//

import Firebase
import UIKit

extension CALayer {
    func showEmitted(in point: CGPoint) {
        guard let image = UIImage(named: "Messages/send") else {
            return
        }

        let customLayer = EmittedLayer(image: image)
        customLayer.configure(with: point)
        customLayer.frame = bounds
        customLayer.needsDisplayOnBoundsChange = true
        customLayer.zPosition = 1
        addSublayer(customLayer)

        let animation = CAKeyframeAnimation(keyPath: #keyPath(CAEmitterLayer.birthRate))
        animation.duration = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.values = [1, 0, 0]
        animation.keyTimes = [0, 0.5, 1]
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        customLayer.beginTime = CACurrentMediaTime()
        customLayer.birthRate = 1.0
        CATransaction.begin()
        customLayer.add(animation, forKey: nil)
        CATransaction.commit()
    }

    func removeEmitted() {
        guard let customLayers = sublayers?.filter({ $0 is EmittedLayer }), !customLayers.isEmpty else {
            return
        }

        customLayers.forEach { layer in
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
            animation.fromValue = 1
            animation.toValue = 0
            animation.duration = 1
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false

            CATransaction.begin()
            CATransaction.setCompletionBlock {
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
            }
            layer.add(animation, forKey: nil)
            CATransaction.commit()
        }
    }
}

final class EmittedLayer: CAEmitterLayer {
    private let image: UIImage

    // MARK: - Init

    init(image: UIImage) {
        self.image = image
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with position: CGPoint) {
        emitterShape = .point
        emitterSize = CGSize(width: 10, height: 10)
        emitterPosition = position

        let emitterCell = CAEmitterCell()
        emitterCell.contents = image.cgImage
        emitterCell.scale = 0.06
        emitterCell.scaleRange = 0.6
        emitterCell.emissionRange = .pi
        emitterCell.lifetime = 10
        emitterCell.birthRate = 50
        emitterCell.velocity = -30
        emitterCell.velocityRange = -20
        emitterCell.yAcceleration = 0
        emitterCell.xAcceleration = 0
        emitterCell.spin = -0.5
        emitterCell.spinRange = 1

        emitterCells = [emitterCell]
    }
}

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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: CustomWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        let window = CustomWindow(frame: UIScreen.main.bounds)
        window.addGestures()
        let storyboard = UIStoryboard(name: "ConversationsList", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "navController")
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window

        FirebaseApp.configure()

        return true
    }
}
