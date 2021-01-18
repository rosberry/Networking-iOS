//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Networking

final class EndpointTests: XCTestCase {

    func testDefaultValues() {
        //Given
        let endpoint = DefaultEndpoint.test
        //When

        //Then
        XCTAssertEqual(endpoint.method, .get, "Endpoint method must be get by default.")
        XCTAssertTrue(endpoint.parameters == [], "Endpoint parameters must be nil by default.")
        XCTAssertEqual(endpoint.headers, [Header.dpi(scale: UIScreen.main.scale)], "Endpoint headers must have dpi header by default.")
        XCTAssertEqual(endpoint.path, endpoint.rawValue, "Endpoint path for RawRepresentable must be equal to raw value.")
    }
}

enum DefaultEndpoint: String, Endpoint {

    case test

    var baseURL: URL {
        URL(string: "https://www.rosberry.com")!
    }
}

enum PostEndpoint: String, Endpoint {

    case test

    var baseURL: URL {
        URL(string: "https://www.rosberry.com")!
    }

    var method: Networking.Method {
        .post
    }
}
