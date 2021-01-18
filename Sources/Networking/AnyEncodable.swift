//
//  Copyright © 2020 Rosberry. All rights reserved.
//

public struct AnyEncodable: Encodable {

    public let value: Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
}

public extension Encodable {

    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}
