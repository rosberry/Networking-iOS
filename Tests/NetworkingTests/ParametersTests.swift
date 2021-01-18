//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Networking

final class ParametersTests: XCTestCase {

    func testEquatable() {
        //Given
        let jsonParameters1 = Parameters.json("test1").hashValue
        let jsonParameters2 = Parameters.json("test2").hashValue
        let urlParameters = Parameters.url([:]).hashValue
        //When

        //Then
        XCTAssertTrue(jsonParameters1 == jsonParameters2, "Parameters hashes with the same type must be equal")
        XCTAssertFalse(jsonParameters1 == urlParameters, "Parameters hashes with different types must not be equal")
    }
}
