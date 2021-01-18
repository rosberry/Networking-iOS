//
// Copyright (c) 2020 Rosberry. All rights reserved.
//

import Foundation

public protocol Endpoint: Hashable {

    var baseURL: URL { get }
    var path: String { get }
    var method: Method { get }
    var headers: [Header] { get }
    var parameters: Set<Parameters> { get }
    var hashValue: Int { get }
    var automaticTaskCancelling: Bool { get }
}

public extension Endpoint {

    var method: Method {
        .get
    }

    var headers: [Header] {
        Header.default
    }

    var parameters: Set<Parameters> {
        []
    }

    var automaticTaskCancelling: Bool {
        true
    }
}

public extension Endpoint where Self: RawRepresentable, Self.RawValue == String {

    var path: String {
        rawValue
    }
}

public extension Endpoint {

    func hash(into hasher: inout Hasher) {
        hasher.combine(baseURL)
        hasher.combine(path)
        hasher.combine(method)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
