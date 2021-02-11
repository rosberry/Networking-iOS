//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Foundation
import Networking

final class RequestServiceTests: ResultTests {

    private lazy var taskServiceMock: SessionTaskServiceMock = .init()
    private lazy var requestFactoryMock: RequestFactoryMock = .init()
    private lazy var jsonDecoderMock: JSONDecoderMock = .init()
    private lazy var service = RequestService(sessionTaskService: taskServiceMock,
                                              requestFactory: requestFactoryMock,
                                              decoder: jsonDecoderMock)
    private lazy var taskFactory: TaskFactory = .init(session: taskServiceMock.session)

    private lazy var human: Human = .init(name: "Artem", age: 26)
    private lazy var humanData: Data? = try? JSONEncoder().encode(human)

    override func tearDown() {
        super.tearDown()
        taskServiceMock.clean()
        requestFactoryMock.clean()
        jsonDecoderMock.error = nil
    }

    // MARK: - Initialization

    func testDefaultDependenciesInjection() {
        //Given

        //When
        let service = RequestService()
        //Then
        XCTAssertEqual(service.sessionTaskService.session, .shared, "Session must be equal to shared session by default.")
        // TODO: add factory check
        // TODO: add json decoder check
    }

    func testPassedDependenciesInjection() {
        //Given
        let taskService = SessionTaskService()
        let requestFactory = RequestFactory()
        let decoder = JSONDecoder()
        //When
        let service = RequestService(sessionTaskService: taskService, requestFactory: requestFactory, decoder: decoder)
        //Then
        XCTAssertTrue(service.sessionTaskService === taskService, "Task service must be equal to passed service.")
        XCTAssertTrue(service.requestFactory === requestFactory, "Request factory must be equal to passed factory.")
        XCTAssertTrue(service.decoder === decoder, "decoder must be equal to passed decoder.")
    }

    // MARK: - Decodable requests

    func testDecodableRequestResultCompletionReturnsData() {
        //Given
        taskServiceMock.dataTask = taskFactory.makeDataTask()
        taskServiceMock.responseData = humanData
        //When
        let expectation = self.expectation(description: "data")
        let task = service.request(DefaultEndpoint.test, queue: .global(qos: .background)) { (result: Result<Human, Error>) in
            self.testResult(result, with: self.human)
            expectation.fulfill()
        }
        //Then
        test(task)
        wait(for: [expectation], timeout: 1.0)
    }

    func testDecodableRequestResultCompletionReturnsError() {
        //Given
        taskServiceMock.dataTask = taskFactory.makeDataTask()
        taskServiceMock.responseData = humanData
        jsonDecoderMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.request(DefaultEndpoint.test, queue: .global(qos: .unspecified)) { (result: Result<Human, Error>) in
            self.testResult(result, with: self.jsonDecoderMock.error)
            expectation.fulfill()
        }
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    func testDecodableRequestResultCompletionReturnsRequestFactoryError() {
        //Given
        taskServiceMock.dataTask = taskFactory.makeDataTask()
        requestFactoryMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.request(DefaultEndpoint.test, queue: .global()) { (result: Result<Human, Error>) in
            self.testResult(result, with: self.requestFactoryMock.error)
            expectation.fulfill()
        }
        //Then
        XCTAssertNil(task, "Task must be nil if request factory returns error.")
        wait(for: [expectation], timeout: 0.05)
    }

    func testDecodableRequestSuccessCompletionReturnsData() {
        //Given
        taskServiceMock.dataTask = taskFactory.makeDataTask()
        taskServiceMock.responseData = humanData
        //When
        let expectation = self.expectation(description: "data")
        let task = service.request(DefaultEndpoint.test, queue: .main, success: { (responseHuman: Human) in
            self.test(responseHuman, with: self.human)
            expectation.fulfill()
        })
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    func testDecodableRequestFailureCompletionReturnsError() {
        //Given
        taskServiceMock.dataTask = taskFactory.makeDataTask()
        taskServiceMock.responseData = humanData
        jsonDecoderMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.request(DefaultEndpoint.test, queue: .global(qos: .background), success: { (_: Human) in }, failure: { error in
            self.testError(error, with: self.jsonDecoderMock.error)
            expectation.fulfill()
        })
        //Then
        test(task)
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Decodable upload requests

    func testDecodableUploadRequestResultCompletionReturnsData() {
        //Given
        let uploadData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: uploadData)
        taskServiceMock.responseData = humanData
        //When
        let expectation = self.expectation(description: "data")
        let task = service.uploadRequest(DefaultEndpoint.test, task: .data(uploadData), queue: .global(qos: .unspecified)) { (result: Result<Human, Error>) in
            self.testResult(result, with: self.human)
            expectation.fulfill()
        }
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    func testDecodableUploadRequestResultCompletionReturnsError() {
        //Given
        let uploadData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: uploadData)
        taskServiceMock.responseData = humanData
        jsonDecoderMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.uploadRequest(DefaultEndpoint.test, task: .data(uploadData), queue: .global(qos: .background)) { (result: Result<Human, Error>) in
            self.testResult(result, with: self.jsonDecoderMock.error)
            expectation.fulfill()
        }
        //Then
        test(task)
        wait(for: [expectation], timeout: 1.0)
    }

    func testDecodableUploadRequestSuccessCompletionReturnsData() {
        //Given
        let uploadData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: uploadData)
        taskServiceMock.responseData = humanData
        //When
        let expectation = self.expectation(description: "data")
        let task = service.uploadRequest(DefaultEndpoint.test, task: .data(uploadData), queue: .global(qos: .background), success: { (responseHuman: Human) in
            self.test(responseHuman, with: self.human)
            expectation.fulfill()
        })
        //Then
        test(task)
        wait(for: [expectation], timeout: 1.0)
    }

    func testDecodableUploadRequestSuccessCompletionReturnsError() {
        //Given
        let uploadData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: uploadData)
        taskServiceMock.responseData = humanData
        jsonDecoderMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.uploadRequest(DefaultEndpoint.test, task: .data(uploadData), queue: .global(qos: .userInitiated), success: { (_: Human) in }, failure: { error in
            self.testError(error, with: self.jsonDecoderMock.error)
            expectation.fulfill()
        })
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    // MARK: - Data requests

    func testRequestResultCompletionReturnsData() {
        //Given
        taskServiceMock.dataTask = taskFactory.makeDataTask()
        taskServiceMock.responseData = Data()
        //When
        let expectation = self.expectation(description: "data")
        let task = service.request(DefaultEndpoint.test) { result in
            self.testResult(result, with: self.taskServiceMock.responseData)
            expectation.fulfill()
        }
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    func testRequestResultCompletionReturnsError() {
        //Given
        taskServiceMock.dataTask = taskFactory.makeDataTask()
        taskServiceMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.request(DefaultEndpoint.test, queue: .global(qos: .unspecified)) { (result:Result<Human, Error>) in
            self.testResult(result, with: self.taskServiceMock.error)
            expectation.fulfill()
        }
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    func testRequestResultCompletionReturnsRequestFactoryError() {
        //Given
        taskServiceMock.dataTask = taskFactory.makeDataTask()
        taskServiceMock.responseData = Data()
        requestFactoryMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.request(DefaultEndpoint.test, queue: .global(qos: .userInteractive)) { (result: Result<Data, Error>) in
            self.testResult(result, with: self.requestFactoryMock.error)
            expectation.fulfill()
        }
        //Then
        XCTAssertNil(task, "Task must be nil if request factory returns error.")
        wait(for: [expectation], timeout: 0.05)
    }

    func testRequestSuccessCompletionReturnsData() {
        //Given
        taskServiceMock.dataTask = taskFactory.makeDataTask()
        taskServiceMock.responseData = Data()
        //When
        let expectation = self.expectation(description: "data")
        let task = service.request(DefaultEndpoint.test, queue: .global(qos: .utility), success: { data in
            self.test(data, with: self.taskServiceMock.responseData)
            expectation.fulfill()
        })
        //Then
        test(task)
        wait(for: [expectation], timeout: 1.0)
    }

    func testRequestFailureCompletionReturnsError() {
        //Given
        taskServiceMock.dataTask = taskFactory.makeDataTask()
        taskServiceMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.request(DefaultEndpoint.test, queue: .global(qos: .background), success: { _ in
            XCTFail("Request must return the error.")
        }, failure: { error in
            self.testError(error, with: self.taskServiceMock.error)
            expectation.fulfill()
        })
        //Then
        test(task)
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Upload requests

    func testUploadRequestWithResultPassesUploadData() {
        //Given
        let expectData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: expectData)
        //When
        service.uploadRequest(DefaultEndpoint.test, task: .data(expectData)) { _ in }
        //Then
        XCTAssertEqual(taskServiceMock.uploadData, expectData, "Upload data from service must be equal to data for upload task.")
    }

    func testUploadRequestWithResultPassesFileURL() {
        //Given
        let url = URL(fileURLWithPath: "")
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(fileURL: url)
        //When
        service.uploadRequest(DefaultEndpoint.test, task: .file(url)) { _ in }
        //Then
        XCTAssertEqual(taskServiceMock.uploadFileURL, url, "Upload data from service must be equal to data for upload task.")
    }

    func testUploadRequestResultCompletionReturnsData() {
        //Given
        let expectData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: expectData)
        taskServiceMock.responseData = Data()
        //When
        let expectation = self.expectation(description: "data")
        let task = service.uploadRequest(DefaultEndpoint.test, task: .data(expectData)) { result in
            self.testResult(result, with: self.taskServiceMock.responseData)
            expectation.fulfill()
        }
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    func testUploadRequestResultCompletionReturnsError() {
        //Given
        let expectData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: expectData)
        taskServiceMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.uploadRequest(DefaultEndpoint.test, task: .data(expectData)) { result in
            self.testResult(result, with: self.taskServiceMock.error)
            expectation.fulfill()
        }
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    func testUploadRequestResultCompletionReturnsRequestFactoryError() {
        //Given
        let expectData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: expectData)
        taskServiceMock.responseData = Data()
        requestFactoryMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.uploadRequest(DefaultEndpoint.test, task: .data(expectData)) { (result: Result<Data, Error>) in
            self.testResult(result, with: self.requestFactoryMock.error)
            expectation.fulfill()
        }
        //Then
        XCTAssertNil(task, "Task must be nil if request factory returns error.")
        wait(for: [expectation], timeout: 0.05)
    }

    func testUploadRequestSuccessCompletionReturnsData() {
        //Given
        let expectData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: expectData)
        taskServiceMock.responseData = Data()
        //When
        let expectation = self.expectation(description: "data")
        let task = service.uploadRequest(DefaultEndpoint.test, task: .data(expectData), queue: .global(qos: .default), success: { data in
            self.test(data, with: self.taskServiceMock.responseData)
            expectation.fulfill()
        })
        //Then
        test(task as? URLSessionUploadTask)
        wait(for: [expectation], timeout: 0.05)
    }

    func testUploadRequestFailureCompletionReturnsError() {
        //Given
        let expectData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: expectData)
        taskServiceMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.uploadRequest(DefaultEndpoint.test, task: .data(expectData), queue: .global(), success: { _ in
            XCTFail("Request must return the error.")
        }, failure: { error in
            self.testError(error, with: self.taskServiceMock.error)
            expectation.fulfill()
        })
        //Then
        test(task as? URLSessionUploadTask)
        wait(for: [expectation], timeout: 0.05)
    }

    func testUploadRequestFailureCompletionReturnsRequestFactoryError() {
        //Given
        let expectData = Data()
        taskServiceMock.uploadTask = taskFactory.makeUploadTask(data: expectData)
        taskServiceMock.responseData = Data()
        requestFactoryMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.uploadRequest(DefaultEndpoint.test, task: .data(expectData), queue: .global(qos: .background), success: { _ in
            XCTFail("Request must return the error.")
        }, failure: { error in
            self.testError(error, with: self.requestFactoryMock.error)
            expectation.fulfill()
        })
        //Then
        XCTAssertNil(task, "Task must be nil if request factory returns error.")
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Download requests

    func testDownloadRequestResultCompletionReturnsData() {
        //Given
        taskServiceMock.downloadTask = taskFactory.makeDownloadTask()
        taskServiceMock.responseURL = URL(fileURLWithPath: "")
        //When
        let expectation = self.expectation(description: "url")
        let task = service.downloadRequest(DefaultEndpoint.test) { result in
            self.testResult(result, with: self.taskServiceMock.responseURL)
            expectation.fulfill()
        }
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    func testDownloadRequestResultCompletionReturnsError() {
        //Given
        taskServiceMock.downloadTask = taskFactory.makeDownloadTask()
        taskServiceMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.downloadRequest(DefaultEndpoint.test) { result in
            self.testResult(result, with: self.taskServiceMock.error)
            expectation.fulfill()
        }
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    func testDownloadRequestResultCompletionReturnsRequestFactoryError() {
        //Given
        taskServiceMock.downloadTask = taskFactory.makeDownloadTask()
        requestFactoryMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.downloadRequest(DefaultEndpoint.test) { result in
            self.testResult(result, with: self.requestFactoryMock.error)
            expectation.fulfill()
        }
        //Then
        XCTAssertNil(task, "Task must be nil if request factory returns error.")
        wait(for: [expectation], timeout: 0.05)
    }

    func testDownloadRequestSuccessCompletionReturnsData() {
        //Given
        taskServiceMock.downloadTask = taskFactory.makeDownloadTask()
        taskServiceMock.responseURL = URL(fileURLWithPath: "")
        //When
        let expectation = self.expectation(description: "data")
        let task = service.downloadRequest(DefaultEndpoint.test, queue: .global(qos: .userInteractive), success: { url in
            self.test(url, with: self.taskServiceMock.responseURL)
            expectation.fulfill()
        })
        //Then
        test(task)
        wait(for: [expectation], timeout: 0.05)
    }

    func testDownloadRequestFailureCompletionReturnsError() {
        //Given
        taskServiceMock.downloadTask = taskFactory.makeDownloadTask()
        taskServiceMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.downloadRequest(DefaultEndpoint.test, queue: .global(qos: .utility), success: { _ in
            XCTFail("Request must return the error.")
        }, failure: { error in
            self.testError(error, with: self.taskServiceMock.error)
            expectation.fulfill()
        })
        //Then
        test(task)
        wait(for: [expectation], timeout: 1.0)
    }

    func testDownloadRequestFailureCompletionReturnsRequestFactoryError() {
        //Given
        taskServiceMock.downloadTask = taskFactory.makeDownloadTask()
        requestFactoryMock.error = NetworkingError.wrongURL
        //When
        let expectation = self.expectation(description: "error")
        let task = service.downloadRequest(DefaultEndpoint.test, queue: .global(qos: .userInitiated), success: { _ in
            XCTFail("Request must return the error.")
        }, failure: { error in
            self.testError(error, with: self.requestFactoryMock.error)
            expectation.fulfill()
        })
        //Then
        XCTAssertNil(task, "Task must be nil if request factory returns error.")
        wait(for: [expectation], timeout: 0.05)
    }

    // MARK: - Private

    private func test(_ task: URLSessionDataTask?) {
        XCTAssertTrue(task === taskServiceMock.dataTask, "Request service must return the same task from task service.")
    }

    private func test(_ task: URLSessionUploadTask?) {
        XCTAssertTrue(task === taskServiceMock.uploadTask, "Request service must return the same task from task service.")
    }

    private func test(_ task: URLSessionDownloadTask?) {
        XCTAssertTrue(task === taskServiceMock.downloadTask, "Request service must return the same task from task service.")
    }
}

private final class TaskFactory {

    private enum Constants {
        static let url: URL = .init(fileURLWithPath: "")
        static let request: URLRequest = .init(url: url)
    }

    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func makeDataTask() -> URLSessionDataTask {
        session.dataTask(with: Constants.url)
    }

    func makeUploadTask(data: Data) -> URLSessionUploadTask {
        session.uploadTask(with: Constants.request, from: data)
    }

    func makeUploadTask(fileURL: URL) -> URLSessionUploadTask {
        session.uploadTask(with: Constants.request, fromFile: fileURL)
    }

    func makeDownloadTask() -> URLSessionDownloadTask {
        session.downloadTask(with: Constants.url)
    }
}
