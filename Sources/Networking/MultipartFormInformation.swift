//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public class MultipartFormInformation {
    let data: Data
    let contentType: String

    init(data: Data, contentType: String) {
        self.data = data
        self.contentType = contentType
    }
}
