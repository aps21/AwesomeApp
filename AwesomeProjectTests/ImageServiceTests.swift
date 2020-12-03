//
//  AwesomeProjectTests
//

@testable import AwesomeProject
import XCTest

class ImageServiceTests: XCTestCase {
    var sut: ImagesService!
    var requestSender: MockRequestSender!

    override func setUp() {
        super.setUp()

        requestSender = MockRequestSender()
        sut = ImagesService(requestSender: requestSender)
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
        requestSender = nil
    }

    func testImageServiceAllImagesRequestSuccess() throws {
        // GIVEN
        let stubImageUrl = "httsp://www.google.com"
        requestSender.imageUrl = stubImageUrl
        // WHEN
        var resultSuccess: [URL?]?
        let expectation = self.expectation(description: "testImageServiceAllImagesRequestSuccess")
        sut.allImages(completionHandler: { result in
            resultSuccess = try? result.get()
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5)
        // THEN
        XCTAssertNotNil(resultSuccess)
        XCTAssertEqual(resultSuccess?.first??.absoluteString, stubImageUrl)
    }

    func testImageServiceAllImagesRequestError() throws {
        // GIVEN
        requestSender.imageUrl = nil
        // WHEN
        var resultError: Error?
        let expectation = self.expectation(description: "testImageServiceAllImagesRequestError")
        sut.allImages(completionHandler: { result in
            if case let .failure(error) = result {
                resultError = error
            }
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5)
        // THEN
        XCTAssertNotNil(resultError)
    }
}
