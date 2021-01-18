//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public struct Header: Equatable {

    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public extension Header {

    static let `default`: [Header] = {
        var headers = [Header.dpi(scale: UIScreen.main.scale)]
        if let appInfo = Bundle.main.infoDictionary,
            let appVersion = appInfo["CFBundleShortVersionString"] as? String {
            headers.append(Header.userAgent(osVersion: UIDevice.current.systemVersion,
                                            appVersion: appVersion))
        }
        return headers
    }()

    static func authorization(token: String) -> Header {
        .init(key: "Authorization", value: token)
    }

    static func contentType(type: String) -> Header {
        .init(key: "Content-Type", value: type)
    }

    static func accept(type: String) -> Header {
        .init(key: "Accept", value: type)
    }

    static func userAgent(osVersion: String, appVersion: String) -> Header {
        .init(key: "User-Agent", value: "iOS \(osVersion) version \(appVersion)")
    }

    static func dpi(scale: CGFloat) -> Header {
        .init(key: "dpi", value: "@\(Int(scale))x")
    }

    static func client(id: String) -> Header {
        .init(key: "Client-Id", value: id)
    }

    static func device(id: String) -> Header {
        .init(key: "Device-Id", value: id)
    }

    static func accept(language: String) -> Header {
        .init(key: "Accept-Language", value: language)
    }
}
