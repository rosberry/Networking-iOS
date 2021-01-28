//
//  Created by Evgeny Schwarzkopf on 21.01.2021.
//

import Foundation

struct User: Decodable {
    let name: String
    let lastName: String
    let imageData: Data
    let likes: Int
}
