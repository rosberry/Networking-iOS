//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class JSONDecoderMock: JSONDecoder {

    var error: Error?

    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        if let error = error {
            throw error
        }
        return try super.decode(type, from: data)
    }
}
