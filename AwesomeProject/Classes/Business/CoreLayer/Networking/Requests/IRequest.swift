//
//  AwesomeProject
//

import Foundation

protocol IRequest {
    var uniqId: UUID { get }
    var urlRequest: URLRequest? { get }
}
