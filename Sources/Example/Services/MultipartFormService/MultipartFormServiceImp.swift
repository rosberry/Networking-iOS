//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Networking
import UIKit

final class MultipartFormServiceImp: RequestService, MultipartFormService {
    
    func upload(_ image: UIImage,
                success: @escaping Success<[String: Any]>,
                failure: Failure?) {
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            return
        }
        let multipartFormDataInformation = MultipartFormDataInformation(data: data, contentType: "jpg")
        request(MultipartFormEndpoint.upload(multipartFormDataInformation)) { data in
            switch data {
            case let .success(data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        success(json)
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}
