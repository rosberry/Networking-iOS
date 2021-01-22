//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Networking
import Foundation
import UIKit

protocol HasMultipartFormService {
    var multipartFormService: MultipartFormService { get }
}

protocol MultipartFormService: class {
    func upload(_ UIImage: UIImage,
                 success: @escaping Success<Data>,
                 failure: Failure?)
}
