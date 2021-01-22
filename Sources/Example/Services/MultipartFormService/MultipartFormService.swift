//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Networking
import Foundation

protocol HasMultipartFormService {
    var multipartFormService: MultipartFormService { get }
}

protocol MultipartFormService: class {
    func request(_ multipartFormInformation: MultipartFormInformation,
                 success: @escaping Success<Data>,
                 failure: Failure?)
}
