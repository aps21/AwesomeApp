//
//  ProfileImageModel.swift
//  AwesomeProject
//
//  Created by Apnnn1 on 19.11.2020.
//

import UIKit

class ProfileImageModel {
    let url: URL?
    let service: IImagesService

    var requestId: UUID?

    init(url: URL?, service: IImagesService) {
        self.url = url
        self.service = service
    }

    func load(completion: @escaping (UIImage?) -> Void) {
        requestId = service.image(from: url) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    completion(UIImage(data: data))
                case .failure:
                    completion(nil)
                }
            }
        }
    }

    func cancelLoading() {
        if let id = requestId {
            service.cancel(id: id)
        }
    }
}
