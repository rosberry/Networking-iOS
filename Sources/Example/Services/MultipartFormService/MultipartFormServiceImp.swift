//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Networking
import UIKit

final class MultipartFormServiceImp: RequestService, MultipartFormService {
    
    func upload(_ image: UIImage,
                success: @escaping Success<Data>,
                failure: Failure?) {
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            return
        }
        let multipartFormDataWrapper = MultipartFormDataWrapper(data: data, contentType: "jpg")
        request(MultipartFormEndpoint.upload(multipartFormDataWrapper)) { data in
            switch data {
            case let .success(data):
                success(data)
            case let .failure(error):
                print(error)
            }
        }
    }
}
