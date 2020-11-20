//
//  AwesomeProject
//

import Foundation

// https//ws.audioscrobbler.com/2.0/?method=chart.gettoptracks&api_key=d2fc8ba489c03df1a0f1eba71dea6fd9&format=json

class RawImageRequest: IRequest {
    let uniqId: UUID
    let url: URL?

    init(uniqId: UUID, url: URL?) {
        self.uniqId = uniqId
        self.url = url
    }

    var urlRequest: URLRequest? {
        if let url = url {
            return URLRequest(url: url)
        }
        return nil
    }
}

class ImagesRequest: IRequest {
    let uniqId: UUID = UUID()

    private var baseUrl: String = "https://pixabay.com/api/"
    private let apiKey: String
    private var getParameters: [String: String] {
        ["key": apiKey, "q": "yellow+flowers", "image_type": "photo", "pretty": "true", "per_page": "200"]
    }

    private var urlString: String {
        let getParams = getParameters.compactMap({ "\($0.key)=\($0.value)"}).joined(separator: "&")
        return baseUrl + "?" + getParams
    }
    
    // MARK: - IRequest
    
    var urlRequest: URLRequest? {
        if let url = URL(string: urlString) {
            return URLRequest(url: url)
        }
        return nil
    }
    
    // MARK: - Initialization

    init(apiKey: String) {
        self.apiKey = apiKey
    }    
}
