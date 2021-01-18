//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public enum Parameters {

    case json(Encodable)
    case url([String: CustomStringConvertible])
    case data(Data)

    var identifier: String {
        switch self {
            case .json:
                return "json"
            case .url:
                return "url"
            case .data:
                return "data"
        }
    }
}

extension Parameters: Equatable {

    public static func == (lhs: Parameters, rhs: Parameters) -> Bool {
        switch (lhs, rhs) {
            case let (.data(lhsData), .data(rhsData)):
                return lhsData == rhsData
            case let (.url(lhsParams), .url(rhsParams)):
                return NSDictionary(dictionary: lhsParams).isEqual(to: rhsParams)
            case let (.json(lhsEncodable), .json(rhsEncodable)):
                let encoder = JSONEncoder()
                guard let lhsData = try? encoder.encode(AnyEncodable(value: lhsEncodable)),
                    let rhsData = try? encoder.encode(AnyEncodable(value: rhsEncodable)) else {
                    return false
                }
                return lhsData == rhsData
            default:
                return false
        }
    }
}

extension Parameters: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
