//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class URLProtocolMock: URLProtocol {

    static var mocks: [URLMock] = []

    static var delay: TimeInterval = 0.01

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let mock = Self.mocks.first { mock in
            mock.url == request.url
        }
        if let mock = mock {
            if let data = mock.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let error = mock.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.delay) {
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {

    }
}

final class URLMock {

    let url: URL?
    let data: Data?
    let error: Error?

    init(url: URL?, data: Data? = nil, error: Error? = nil) {
        self.url = url
        self.data = data
        self.error = error
    }
}
