//
//  AwesomeProject
//

import UIKit

public extension CALayer {
    func showEmitted(in point: CGPoint) {
        guard let image = UIImage(named: "Images/logo") else {
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
