//
//  AwesomeProject
//

import Foundation

struct ImageModel: Decodable {
    let largeImageURL: String?
    let userImageURL: String

    var url: URL? {
        URL(string: userImageURL.isEmpty ? largeImageURL ?? "" : userImageURL)
    }
}

struct ImagePackage: Decodable {
    let hits: [ImageModel]
}

class ImageParser: IParser {
    func parse(data: Data) -> [ImageModel]? {
        let json = try? JSONDecoder().decode(ImagePackage.self, from: data)
        return json?.hits
    }
}

class RawImageParser: IParser {
    func parse(data: Data) -> Data? {
        data
    }
}
