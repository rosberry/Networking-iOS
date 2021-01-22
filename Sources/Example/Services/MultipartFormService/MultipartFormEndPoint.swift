//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Networking

enum MultipartFormEndpoint {
    case uploadImage(_ multipartFormInformation: MultipartFormInformation)
}

extension MultipartFormEndpoint: Endpoint {
    
    var headers: [Header] {
        [.accept(type: "application/json")]
    }
    
    var baseURL: URL {
        return URL(string: "http://httpbin.org")!
    }
    
    var path: String {
        return "post"
    }
    
    var method: Networking.Method {
        switch self {
        case .uploadImage:
            return .post
        }
    }
    
    var parameters: Set<Parameters> {
        switch self {
        case .uploadImage(let multipartFormInformation):
            var params: [String: Any] = [:]
            params["name"] = "Djamshyt"
            params["lastName"] = "Djamshytovich"
            params["image"] = multipartFormInformation
            params["likes"] = 23
            return [.multipartFormData(params)]
        }
    }
}
