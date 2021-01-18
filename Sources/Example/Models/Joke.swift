//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct Joke: Decodable {

    let id: Int
    let type: String
    let setup: String
    let punchline: String
}

extension Joke: CustomStringConvertible {
    public var description: String {
        """
        id \(id)
        type \(type)
        setup \(setup)
        punchline \(punchline)
        """
    }
}
