//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Networking
import UIKit

final class MultipartFormServiceImp: RequestService, MultipartFormService {

    static let shared: MultipartFormServiceImp = .init()

    func request(_ multipartFormInformation: MultipartFormInformation,
                 success: @escaping Success<Data>,
                 failure: Failure?) {
        request(MultipartFormEndpoint.uploadImage(multipartFormInformation)) { data in
            switch data {
            case let .success(data):
                success(data)
            case let .failure(error):
                print(error)
            }
        }
    }
}
