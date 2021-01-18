//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Networking

class ResultTests: XCTestCase {

    func testResult<Value: Equatable>(_ result: Result<Value, Error>, with value: Value?) {
        test(try? result.get(), with: value)
    }

    func test<Value: Equatable>(_ resultValue: Value?, with value: Value?) {
        XCTAssertEqual(resultValue, value, "Data from request must be equal to mocked data.")
    }

    func testResult<Value>(_ result: Result<Value, Error>, with error: Error?) {
        switch result {
            case .success:
                XCTFail("Request must return the error.")
            case .failure(let resultError):
                testError(resultError, with: error)
        }
    }

    func testError(_ resultError: Error, with error: Error?) {
        XCTAssertEqual(resultError as? NetworkingError, error as? NetworkingError, "Error from request must be equal to mocked error.")
    }
}
