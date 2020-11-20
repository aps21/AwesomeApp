//
//  AwesomeProject
//

import Foundation

protocol IServicesAssembly {
    var imagesService: IImagesService { get }
}

class ServicesAssembly: IServicesAssembly {
    private let coreAssembly: ICoreAssembly
    
    init(coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
    }

    lazy var imagesService: IImagesService = ImagesService(requestSender: self.coreAssembly.requestSender)
}
