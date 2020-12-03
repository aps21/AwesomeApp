//
//  AwesomeProject
//

import UIKit

public final class EmittedLayer: CAEmitterLayer {
    private let image: UIImage

    public init(image: UIImage) {
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
