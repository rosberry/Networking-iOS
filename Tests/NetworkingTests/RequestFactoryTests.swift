//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Networking

final class RequestFactoryTests: XCTestCase {

    private lazy var factory: RequestFactory = .init()

    func testPassedDependenciesInjection() {
        //Given
        let encoder = JSONEncoder()
        //When
        let requestFactory = RequestFactory(encoder: encoder)
        //Then
        XCTAssertTrue(requestFactory.encoder === encoder, "Encoder must be equal to passed encoder.")
    }

    func testURLParametersRequest() {
        //Given
        let endpoint = URLParametersEndpoint.test
        //When
        let request = try? factory.makeRequest(endpoint: endpoint)
        //Then
        XCTAssertEqual(request?.url?.absoluteString, "google.com/test?test=test", "Request must have a valid URL.")
        XCTAssertEqual(request?.httpMethod, "GET", "Request must have http method from endpoint.")
        XCTAssertEqual(request?.allHTTPHeaderFields, endpoint.headers.headerFields, "Request must have headers from endpoint.")
    }

    func testJSONParametersRequest() {
        //Given
        let human = Human(name: "Artem", age: 26)
        let endpoint = JSONParametersEndpoint(human: human)
        let encoder = JSONEncoder()
        let humanData = try? encoder.encode(human)
        //When
        let request = try? factory.makeRequest(endpoint: endpoint)
        //Then
        XCTAssertEqual(request?.url?.absoluteString, "google.com/test", "Request must have a valid URL.")
        XCTAssertEqual(request?.httpMethod, "GET", "Request must have http method from endpoint.")
        XCTAssertEqual(request?.allHTTPHeaderFields, endpoint.headers.headerFields, "Request must have headers from endpoint.")
        XCTAssertEqual(request?.httpBody, humanData, "Request must have a valid body.")
    }

    func testDataParametersRequest() {
        //Given
        let data = Data()
        let endpoint = DataParametersEndpoint(data: data)
        //When
        let request = try? factory.makeRequest(endpoint: endpoint)
        //Then
        XCTAssertEqual(request?.url?.absoluteString, "google.com/test", "Request must have a valid URL.")
        XCTAssertEqual(request?.httpMethod, "GET", "Request must have http method from endpoint.")
        XCTAssertEqual(request?.allHTTPHeaderFields, endpoint.headers.headerFields, "Request must have headers from endpoint.")
        XCTAssertEqual(request?.httpBody, data, "Request must have a valid body.")
    }
}

private enum URLParametersEndpoint: Endpoint {

    case test

    var baseURL: URL {
        URL(string: "google.com")!
    }

    var path: String {
        "test"
    }

    var parameters: Set<Parameters> {
        return [.url(["test": "test"])]
    }
}

private class JSONParametersEndpoint: Endpoint {

    let human: Human

    init(human: Human) {
        self.human = human
    }

    var baseURL: URL {
        URL(string: "google.com")!
    }

    var path: String {
        "test"
    }

    var parameters: Set<Parameters> {
        return [.json(human)]
    }
}

private class DataParametersEndpoint: Endpoint {

    let data: Data

    init(data: Data) {
        self.data = data
    }

    var baseURL: URL {
        URL(string: "google.com")!
    }

    var path: String {
        "test"
    }

    var parameters: Set<Parameters> {
        return [.data(data)]
    }
}

private extension Collection where Element == Header {

    var headerFields: [String: String] {
        var headers = [String: String]()
        for header in self {
            headers[header.key] = header.value
        }
        return headers
    }
}
