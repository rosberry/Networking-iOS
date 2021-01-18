//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Networking

protocol HasJokesService {

    var jokesService: JokesService { get }
}

protocol JokesService: class {

    var lastJoke: Joke? { get set }
    func loadRandomJoke(category: String, completion: @escaping ResultCompletion<Joke>)
}
