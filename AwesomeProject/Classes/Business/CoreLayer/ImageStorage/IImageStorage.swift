//
//  AwesomeProject
//

import Foundation
import UIKit

protocol IImageStorage {
    func save(image: UIImage, for key: String)
    func fetchImage(key: String) -> UIImage?
}
