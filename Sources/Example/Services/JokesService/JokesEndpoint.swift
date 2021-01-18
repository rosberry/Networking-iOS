//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Networking

enum JokesEndpoint: Endpoint {

    case random(category: String)

    var baseURL: URL {
        URL(string: "https://official-joke-api.appspot.com/jokes")!
    }

    var path: String {
        "random"
    }
}
