//
//  Copyright © 2020 Rosberry. All rights reserved.
//

extension Error {

    public var responseCode: Int? {
        guard let networkingError = self as? NetworkingError,
            case let NetworkingError.responseValidationFailed(responseCode) = networkingError else {
            return nil
        }
        return responseCode
    }
}
