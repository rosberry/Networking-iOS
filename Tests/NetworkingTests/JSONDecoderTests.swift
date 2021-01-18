//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Networking

final class JSONDecoderTests: XCTestCase {

    private let decoder: JSONDecoderMock = .init()

    private lazy var human: Human = .init(name: "Artem", age: 26)
    private lazy var humanData: Data = (try? JSONEncoder().encode(human)) ?? Data()

    override func tearDown() {
        super.tearDown()
        decoder.error = nil
    }

    func testDecodeSuccessResultFromData() {
        //Given
        let data = humanData
        //When
        let result: Result<Human, Error> = decoder.decodeResult(from: data)
        //Then
        XCTAssertEqual(try? result.get(), human, "Decoder must return result with decoded object.")
    }

    func testDecodeFailureResultFromData() {
        //Given
        let data = Data()
        decoder.error = NetworkingError.noData
        //When
        let result: Result<Human, Error> = decoder.decodeResult(from: data)
        //Then
        switch result {
        case .success:
            XCTFail("Result must return error.")
        case .failure(let error):
            XCTAssertEqual(error as? NetworkingError, decoder.error as? NetworkingError,
                           "Decoder must return result with decoding error.")
        }
    }

    func testDecodeSuccessResultFromSuccessResult() {
        //Given
        let result: Result<Data, Error> = .success(humanData)
        //When
        let decodedResult: Result<Human, Error> = decoder.decodeResult(result)
        //Then
        switch decodedResult {
        case .success(let decodedHuman):
            XCTAssertEqual(decodedHuman, human, "Result must return decoded object.")
        case .failure:
            XCTFail("Result must return decoded object.")
        }
    }

    func testDecodeFailureResultFromFailureResult() {
        //Given
        let error = NetworkingError.noData
        let result: Result<Data, Error> = .failure(error)
        //When
        let decodedResult: Result<Human, Error> = decoder.decodeResult(result)
        //Then
        switch decodedResult {
        case .success:
            XCTFail("Result must return error.")
        case .failure(let error):
            XCTAssertEqual(error as? NetworkingError, error as? NetworkingError, "Decoder must return result with decoding error.")
        }
    }

    func testDecodeSuccessResultFromResult() {
        //Given
        let data = Data()
        let result: Result<Data, Error> = .success(data)
        //When
        let decodedResult: Result<Human, Error> = decoder.decodeResult(result)
        //Then
        switch decodedResult {
        case .success:
            XCTFail("Result must return error.")
        case .failure(let error):
            XCTAssertEqual(error as? NetworkingError, decoder.error as? NetworkingError,
                           "Decoder must return result with decoding error.")
        }
    }
}
