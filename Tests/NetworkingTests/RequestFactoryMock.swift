//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Networking

final class RequestFactoryMock: RequestFactory {

    var error: Error?
    var request: URLRequest?

    override func makeRequest<E: Endpoint>(endpoint: E) throws -> URLRequest {
        if let error = error {
            throw error
        }
        if let request = request {
            return request
        }
        return try super.makeRequest(endpoint: endpoint)
    }

    func clean() {
        request = nil
    }
}
