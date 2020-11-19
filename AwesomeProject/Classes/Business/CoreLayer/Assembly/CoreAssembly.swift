//
//  AwesomeProject
//

import Foundation

protocol ICoreAssembly {
    var requestSender: IRequestSender { get }
}

class CoreAssembly: ICoreAssembly {
    lazy var requestSender: IRequestSender = RequestSender()
}
