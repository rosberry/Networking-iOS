//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Networking

final class JokesServiceImp: RequestService, JokesService {

    static let shared: JokesServiceImp = .init()
    var lastJoke: Joke?

    private init() {
        super.init()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func loadRandomJoke(category: String, completion: @escaping ResultCompletion<Joke>) {
        request(JokesEndpoint.random(category: category), queue: .main) { result in
            completion(result)
        }
    }
}
