//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public class MultipartFormDataWrapper {
    public let data: Data
    public let contentType: String

    public init(data: Data, contentType: String) {
        self.data = data
        self.contentType = contentType
    }
}
