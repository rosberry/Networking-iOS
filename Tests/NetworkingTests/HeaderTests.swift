//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Networking

final class HeaderTests: XCTestCase {

    func testDefaultHeaders() {
        //Given

        //When
        let headers = Header.default
        //Then
        XCTAssertEqual(headers.count, 1, "Default headers must have one header.")
        XCTAssertEqual(headers[0].key, "dpi", "Default headers must contain dpi header.")
        XCTAssertEqual(headers[0].value, "@\(Int(UIScreen.main.scale))x", "Default headers must contain correct dpi header.")
    }

    func testAuthorizationHeader() {
        //Given
        let token = "token"
        //When
        let header = Header.authorization(token: token)
        //Then
        XCTAssertEqual(header.key, "Authorization", "Authorization header key must be equal to Authorization.")
        XCTAssertEqual(header.value, token, "Authorization header value must be equal to \(token).")
    }

    func testContentTypeHeader() {
        //Given
        let type = "type"
        //When
        let header = Header.contentType(type: type)
        //Then
        XCTAssertEqual(header.key, "Content-Type", "Content type header key must be equal to Content-Type.")
        XCTAssertEqual(header.value, type, "Content type header value must be equal to \(type).")
    }

    func testUserAgentHeader() {
        //Given
        let osVersion = "13.0"
        let appVersion = "1.0"
        //When
        let header = Header.userAgent(osVersion: osVersion, appVersion: appVersion)
        //Then
        XCTAssertEqual(header.key, "User-Agent", "User Agent header key must be equal to User-Agent.")
        XCTAssertEqual(header.value, "iOS \(osVersion) version \(appVersion)", "User Agent header value must contain os and app versions.")
    }

    func testDPIHeader() {
        //Given
        let scale: CGFloat = 2
        //When
        let header = Header.dpi(scale: scale)
        //Then
        XCTAssertEqual(header.key, "dpi", "DPI header key must be equal to dpi.")
        XCTAssertEqual(header.value, "@2x", "DPI header value must contain scale.")
    }

    func testClientIDHeader() {
        //Given
        let id = "id"
        //When
        let header = Header.client(id: id)
        //Then
        XCTAssertEqual(header.key, "Client-Id", "Client ID header key must be equal to clientId.")
        XCTAssertEqual(header.value, id, "Client ID header value must be equal to \(id).")
    }
}
