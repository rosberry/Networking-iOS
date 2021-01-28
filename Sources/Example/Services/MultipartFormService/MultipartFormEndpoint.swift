//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Networking

enum MultipartFormEndpoint {
    case upload(_ multipartFormDataWrapper: MultipartFormDataInformation)
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
        case .upload:
            return .post
        }
    }
    
    var parameters: Set<Parameters> {
        switch self {
        case .upload(let multipartFormDataInformation):
            var params: [String: Any] = [:]
            params["name"] = "Djamshyt"
            params["lastName"] = "Djamshytovich"
            params["image"] = multipartFormDataInformation
            params["likes"] = 23
            return [.multipartFormData(params)]
        }
    }
}
