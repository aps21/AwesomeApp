//
//  AwesomeProject
//

import UIKit

protocol IImagesService {
    func allImages(completionHandler: @escaping (Result<[URL?], Error>) -> Void)
    @discardableResult
    func image(from url: URL?, completionHandler: @escaping (Result<Data, Error>) -> Void) -> UUID
    func cancel(id: UUID)
}

class ImagesService: IImagesService {
    let requestSender: IRequestSender

    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }
    
    func allImages(completionHandler: @escaping (Result<[URL?], Error>) -> Void) {
        let requestConfig = RequestsFactory.ImageRequests.allImagesConfig()
        requestSender.send(requestConfig: requestConfig) { (result: Result<[ImageModel], Error>) in
            DispatchQueue.main.async {
                completionHandler(result.map { items in items.map { $0.url } })
            }
        }
    }

    @discardableResult
    func image(from url: URL?, completionHandler: @escaping (Result<Data, Error>) -> Void) -> UUID {
        let id = UUID()
        let requestConfig = RequestsFactory.ImageRequests.rawImageConfig(id: id, url: url)
        requestSender.send(requestConfig: requestConfig) { completionHandler($0) }
        return id
    }

    func cancel(id: UUID) {
        requestSender.cancel(id: id)
    }
}
