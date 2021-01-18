//
// Copyright (c) 2018 Rosberry. All rights reserved.
//

import Foundation

public enum GeneralRequestError: Error {
    case noInternetConnection
    case timedOut
    case noAuth
    case notFound
    case cancelled
    case unknown
    case internalServerError
    case serviceUnavailable
    case gatewayTimeout
    case forbidden
}

extension GeneralRequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .noInternetConnection:
                return "No internet connection"
            case .timedOut:
                return "Time out"
            case .noAuth:
                return "Unauthorized"
            case .notFound:
                return "Not found"
            case .cancelled:
                return "Cancelled"
            case .unknown:
                return "unknown"
            case .internalServerError:
                return "Internal server error"
            case .serviceUnavailable:
                return "Service unavailable"
            case .gatewayTimeout:
                return "Gateway timeout"
            case .forbidden:
                return "Forbidden"
        }
    }
}
