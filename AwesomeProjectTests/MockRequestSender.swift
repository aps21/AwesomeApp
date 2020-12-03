//
//  AwesomeProjectTests
//

@testable import AwesomeProject
import XCTest

class MockRequestSender: IRequestSender {
    enum MockError: Error {
        case simple
    }

    var imageUrl: String?

    func send<Parser>(requestConfig config: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model, Error>) -> Void) {
        if Parser.self == ImageParser.self {
            let currentURL = config.request.urlRequest?.url?.absoluteString
            let expectedURL = RequestsFactory.ImageRequests.allImagesConfig().request.urlRequest?.url?.absoluteString
            XCTAssertEqual(currentURL, expectedURL)
            if let url = imageUrl, let data = [ImageModel(largeImageURL: url, userImageURL: url)] as? Parser.Model {
                completionHandler(.success(data))
            } else {
                completionHandler(.failure(MockError.simple))
            }
        } else {
            completionHandler(.failure(InternalError(errorDescription: "")))
        }
    }

    func cancel(id _: UUID) {}
}
