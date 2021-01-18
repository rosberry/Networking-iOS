//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Foundation
import Networking

final class SessionTaskServiceTests: ResultTests {

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: configuration)
    }()

    private lazy var taskService = SessionTaskService(session: session)

    private lazy var request: URLRequest = .init(url: .init(fileURLWithPath: ""))

    // MARK: - Initialization

    func testDefaultSessionDependency() {
        //Given

        //When
        let taskService = SessionTaskService()
        //Then
        XCTAssertEqual(taskService.session, .shared, "Session must be equal to shared session by default.")
    }

    func testPassedSessionDependency() {
        //Given
        let session = URLSession(configuration: .default)
        //When
        let taskService = SessionTaskService(session: session)
        //Then
        XCTAssertTrue(taskService.session === session, "Session must be equal to passed session.")
    }

    // MARK: - Data tasks

    func testDataTaskResultCompletionReturnsData() {
        //Given
        let expectData = Data()
        URLProtocolMock.mocks = [URLMock(url: request.url, data: expectData)]
        //When
        let expectation = self.expectation(description: "data")
        let task = taskService.dataTask(with: request) { result in
            self.testResult(result, with: expectData)
            expectation.fulfill()
        }
        //Then
        test(task, with: request)
        wait(for: [expectation], timeout: 0.05)
    }

    func testDataTaskResultCompletionReturnsError() {
        //Given
        let expectError = NetworkingError.wrongURL
        URLProtocolMock.mocks = [URLMock(url: request.url, error: expectError)]
        //When
        let expectation = self.expectation(description: "error")
        let task = taskService.dataTask(with: request) { result in
            self.testResult(result, with: expectError)
            expectation.fulfill()
        }
        //Then
        test(task, with: request)
        wait(for: [expectation], timeout: 0.05)
    }

    func testDataTaskSuccessCompletionReturnsData() {
        //Given
        let expectData = Data()
        URLProtocolMock.mocks = [URLMock(url: request.url, data: expectData)]
        //When
        let expectation = self.expectation(description: "data")
        let task = taskService.dataTask(with: request, success: { data in
            self.test(data, with: expectData)
            expectation.fulfill()
        }, failure: { _ in
            XCTFail("Request must not return the error.")
        })
        //Then
        test(task, with: request)
        wait(for: [expectation], timeout: 0.05)
    }

    func testDataTaskFailureCompletionReturnsError() {
        //Given
        let expectError = NetworkingError.wrongURL
        URLProtocolMock.mocks = [URLMock(url: request.url, error: expectError)]
        //When
        let expectation = self.expectation(description: "error")
        let task = taskService.dataTask(with: request, success: { _ in
            XCTFail("Request must return the error.")
        }, failure: { error in
            self.testError(error, with: expectError)
            expectation.fulfill()
        })
        //Then
        test(task, with: request)
        wait(for: [expectation], timeout: 0.05)
    }

    // MARK: - Private

    private func test(_ task: URLSessionDataTask, with request: URLRequest) {
        XCTAssertEqual(task.state, .running, "Task state must be equal to running.")
        XCTAssertEqual(task.originalRequest, request, "Task original request must be equal to passed request.")
    }
}
