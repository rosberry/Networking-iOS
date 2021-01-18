//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

open class GeneralErrorHandler: ErrorHandler {

    public init() {
    }

    public func handle<E: Endpoint>(error: inout Error, endpoint: E) {
        if let errorForCode = self.error(byResponseCode: error.responseCode) {
            error = errorForCode
        }
        else if let errorForNSError = self.error(byNSErrorCode: (error as NSError).code) {
            error = errorForNSError
        }
    }

    private func error(byResponseCode code: Int?) -> Error? {
        switch code {
        case 401:
            return GeneralRequestError.noAuth
        case 403:
            return GeneralRequestError.forbidden
        case 404:
            return GeneralRequestError.notFound
        case 500:
            return GeneralRequestError.internalServerError
        case 503:
            return GeneralRequestError.serviceUnavailable
        case 504:
            return GeneralRequestError.gatewayTimeout
        default:
            return nil
        }
    }

    private func error(byNSErrorCode code: Int) -> Error? {
        switch code {
        case NSURLErrorCancelled:
            return GeneralRequestError.cancelled
        case NSURLErrorNotConnectedToInternet:
            return GeneralRequestError.noInternetConnection
        case NSURLErrorTimedOut:
            return GeneralRequestError.timedOut
        default:
            return nil
        }
    }
}
