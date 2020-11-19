//
//  AwesomeProject
//

import Foundation

struct RequestsFactory {
    struct ImageRequests {
        static func allImagesConfig() -> RequestConfig<ImageParser> {
            let request = ImagesRequest(apiKey: "19186455-1ba654403e587a3ddc5331dd5")
            return RequestConfig(request: request, parser: ImageParser())
        }

        static func rawImageConfig(id: UUID, url: URL?) -> RequestConfig<RawImageParser> {
            let request = RawImageRequest(uniqId: id, url: url)
            return RequestConfig(request: request, parser: RawImageParser())
        }
    }
    
}
